//
//  ContactTracing+Advertiser.swift
//  CCLocation
//
//  Created by TCode on 15/06/2020.
//  Copyright © 2020 Crowd Connected. All rights reserved.
//

import Foundation
import CoreBluetooth

class ContactAdvertiser: NSObject, CBPeripheralManagerDelegate {
    
    private let restoreIdentifierKey = "com.colocator.contacttracing.peripheral"
     
    var peripheralManager: CBPeripheralManager?
    var advertiserOn = true
    var advertiseDuration: Int? // seconds
    var advertiseInterval: Int? // seconds
    
    private var eidGenerator: EIDGeneratorManager?
    
    enum UnsentCharacteristicValue {
        case keepalive(value: Data)
        case identity(value: Data)
    }
    
    var unsentCharacteristicValue: UnsentCharacteristicValue?
    var keepaliveCharacteristic: CBMutableCharacteristic?
    var identityCharacteristic: CBMutableCharacteristic?
    
    init(eidGenerator: EIDGeneratorManager) {
        self.eidGenerator = eidGenerator
        advertiserOn = true
    }
    
    private func start() {
        if peripheralManager == nil {
            Log.warning("No PeripheralManager found when starting broadcasting. Abandom broadcasting")
            return
        }
        
        if peripheralManager?.isAdvertising ?? false {
            peripheralManager?.stopAdvertising()
        }
        
        let service = CBMutableService(type: ContactTracingUUIDs.colocatorServiceUUID, primary: true)

        identityCharacteristic = CBMutableCharacteristic(
            type: ContactTracingUUIDs.colocatorIdCharacteristicUUID,
            properties: CBCharacteristicProperties([.read, .notify]),
            value: nil,
            permissions: .readable)
        keepaliveCharacteristic = CBMutableCharacteristic(
            type: ContactTracingUUIDs.keepaliveCharacteristicUUID,
            properties: CBCharacteristicProperties([.notify]),
            value: nil,
            permissions: .readable)

        service.characteristics = [identityCharacteristic!, keepaliveCharacteristic!]
        
        peripheralManager?.removeAllServices()
        peripheralManager?.add(service)
    }
    
    private func startAdvertisingCycle() {
        peripheralManager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [ContactTracingUUIDs.colocatorServiceUUID]])
        
        if advertiseDuration != nil && advertiseInterval != nil {
            Log.verbose("Started advertising cycle for \(String(describing: advertiseDuration)) seconds")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(advertiseDuration!)) {
                self.stopAdvertisingCycle()
            }
        } else {
             Log.verbose("Started advertising for indefinite period")
        }
    }
    
    private func stopAdvertisingCycle() {
        self.peripheralManager?.stopAdvertising()
        
        Log.verbose("Stopped advertising. Start again in \(String(describing: self.advertiseInterval)) seconds")
        
        if self.advertiserOn {
            // Used 1 as backup to avoid a crash if advertiseInterval is set to nil meanwhile
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(self.advertiseInterval ?? 1)) {
                self.startAdvertisingCycle()
            }
        }
    }
    
    public func forceStopAdvertiser() {
        self.peripheralManager?.stopAdvertising()
        self.peripheralManager = nil
        advertiserOn = false
    }
    
    func sendKeepalive(value: Data) {
        guard let peripheral = self.peripheralManager else {
            Log.verbose("Cannot send keep alive. Peripheral is nil")
            return
        }
        guard let keepaliveCharacteristic = self.keepaliveCharacteristic else {
            Log.verbose("Cannot send keep alive. Keepalive characteristic is nil")
            return
        }
        
        self.unsentCharacteristicValue = .keepalive(value: value)
        
        let success = peripheral.updateValue(value, for: keepaliveCharacteristic, onSubscribedCentrals: nil)
        
        if success {
            Log.verbose("Sent keepalive value: \(value.withUnsafeBytes { $0.load(as: UInt8.self) })")
            self.unsentCharacteristicValue = nil
        }
    }
    
    func updateIdentity() {
        guard let identityCharacteristic = self.identityCharacteristic else {
            // This "shouldn't happen" in normal course of the code, but if you start the
            // app with Bluetooth off you can get here.
            Log.warning("Identity characteristic not created yet")
            return
        }
        
        guard let eidGenerator = eidGenerator else {
            Log.warning("Cannot generate ID payload since EIDGenerator is nil")
            return
        }
        
        guard let broadcastPayload = eidGenerator.generateEIDData() else {
            Log.warning("Failed to gen erate EID")
            return
        }
        
        guard let peripheral = self.peripheralManager else {
            Log.warning("Nil peripheral detected when updating identity. This shouldn't happen")
            return
        }
        
        self.unsentCharacteristicValue = .identity(value: broadcastPayload)
        let success = peripheral.updateValue(broadcastPayload, for: identityCharacteristic, onSubscribedCentrals: nil)
        if success {
            Log.info("Sent EID \(broadcastPayload) through characteristic")
            self.unsentCharacteristicValue = nil
        }
    }
    
    // MARK: - CBPeripheralManagerDelegate
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            self.peripheralManager = peripheral
            start()
        default:
            break
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        // Make changes when state s restored if needed
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        guard error == nil else {
            Log.warning("Advertiser peripheral didAddService error \(error!)")
            return
        }
        
        startAdvertisingCycle()
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        let characteristic: CBMutableCharacteristic
        let value: Data

        switch unsentCharacteristicValue {
        case nil:
            Log.verbose("No data to update through characteristics")
            return

        case .identity(let identityValue) where self.identityCharacteristic != nil:
            value = identityValue
            characteristic = self.identityCharacteristic!

        case .keepalive(let keepaliveValue) where self.keepaliveCharacteristic != nil:
            value = keepaliveValue
            characteristic = self.keepaliveCharacteristic!

        default:
            Log.verbose("Other data to update through characteristics. Shouldn't happen")
            return
        }

        let success = peripheral.updateValue(value, for: characteristic, onSubscribedCentrals: nil)
        
        if success {
            Log.verbose("Resent value \(value) through characteristic")
            self.unsentCharacteristicValue = nil
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        guard request.characteristic.uuid == ContactTracingUUIDs.colocatorIdCharacteristicUUID else {
            Log.verbose("Peripheral Manager received a read for unexpected characteristic \(request.characteristic.uuid.uuidString)")
            return
        }
        guard let eidGenerator = eidGenerator else {
            Log.warning("Cannot generate ID payload since EIDGenerator is nil")
            return
        }
        guard let broadcastPayload = eidGenerator.generateEIDData() else {
            request.value = Data()
            peripheral.respond(to: request, withResult: .success)
            return
        }
        
        request.value = broadcastPayload
        peripheral.respond(to: request, withResult: .success)
    }
}
