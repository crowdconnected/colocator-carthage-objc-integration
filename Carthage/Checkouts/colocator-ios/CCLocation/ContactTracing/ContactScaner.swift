//
//  ContactTracing+Scaner.swift
//  CCLocation
//
//  Created by TCode on 15/06/2020.
//  Copyright © 2020 Crowd Connected. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol ContactScannerDelegate: class {
    func newContact(EID: String, RSSI: Int, timestamp: Double)
}

class ContactScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var delegate: ContactScannerDelegate?
    var scannerOn = true
    var scanDuration: Int? // seconds
    var scanInterval: Int? // seconds
    
    private var advertiser: ContactAdvertiser
    private let queue: DispatchQueue
    
    // comfortably less than the ~10s background processing time Core Bluetooth gives us when it wakes us up
    private let keepaliveInterval: TimeInterval = 8.0
    
    private var lastKeepaliveDate: Date = Date.distantPast
    private var keepaliveValue: UInt8 = 0
    private var keepaliveTimer: DispatchSourceTimer?
    
    private var peripherals: [UUID: CBPeripheral] = [:]
    private var peripheralsEIDs: [UUID: String] = [:]
    
    init(advertiser: ContactAdvertiser, queue: DispatchQueue, delegate: ContactScannerDelegate) {
        self.advertiser = advertiser
        self.queue = queue
        self.delegate = delegate
        scannerOn = true
    }
    
    private var centralManager: CBCentralManager?
    
    private func startScanningCycle() {
        let services = [ContactTracingUUIDs.colocatorServiceUUID]
        let options = [CBCentralManagerScanOptionAllowDuplicatesKey : true]
        centralManager?.scanForPeripherals(withServices: services, options: options)
        
        if scanDuration != nil && scanInterval != nil {
            Log.verbose("Started scanning cycle for \(String(describing: scanDuration)) seconds")
                    
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(scanDuration!)) {
                self.stopScanningCycle()
            }
            
        } else {
            Log.verbose("Started scanning cycle for indefinite period")
        }
    }
    
    private func stopScanningCycle() {
        self.centralManager?.stopScan()
        
        Log.verbose("Stopped scanning. Start again in \(String(describing: self.scanInterval)) seconds")
        
        if self.scannerOn {
            // Used 1 as backup to avoid a crash if scanInterval is set to nil meanwhile
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(self.scanInterval ?? 1)) {
                self.startScanningCycle()
            }
        }
    }
    
    public func forceStopScanner() {
        self.centralManager?.stopScan()
        self.centralManager = nil
        scannerOn = false
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        // Make changes when state s restored if needed
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            for peripheral in peripherals.values {
                central.connect(peripheral)
            }
            
            centralManager = central
            startScanningCycle()
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data { // Most probably Android Device
            if let deviceEID = extractEIDFromManufacturerData(manufacturerData) {
                handleAndroidContactWith(deviceEID: deviceEID, RSSI: RSSI)
            } else {
                // Ignore. Probably a device not advertising through Colocator
            }
            
        } else { // Most probably iOS device. Connect to it
            if peripherals[peripheral.identifier] == nil || peripherals[peripheral.identifier]!.state != .connected {
                peripherals[peripheral.identifier] = peripheral
                central.connect(peripheral)
            }
            handleiOSContactWith(peripheral, RSSI: RSSI)
        }
    }
    
    func getEIDForPeripheral(_ peripheral: CBPeripheral) -> String? {
        return peripheralsEIDs[peripheral.identifier]
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.readRSSI()
        peripheral.discoverServices([ContactTracingUUIDs.colocatorServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.connect(peripheral)
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) { }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            Log.warning("Scanner didDiscoverServices got unknown error")
            return
        }
        
        guard let services = peripheral.services, services.count > 0 else { return }
        guard let colocatorIDService = services.colocatorIdService() else { return }
        
        let characteristics = [ContactTracingUUIDs.colocatorIdCharacteristicUUID, ContactTracingUUIDs.keepaliveCharacteristicUUID]
        peripheral.discoverCharacteristics(characteristics, for: colocatorIDService)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            Log.warning("Scanner didDiscoverCharacteristicsFor service \(service) got unknown error")
            return
        }
        
        guard let characteristics = service.characteristics, characteristics.count > 0 else { return }
        
        if let colocatorIdCharacteristic = characteristics.colocatorIdCharacteristic() {
            peripheral.readValue(for: colocatorIdCharacteristic)
            peripheral.setNotifyValue(true, for: colocatorIdCharacteristic)
        }
        
        if let keepaliveCharacteristic = characteristics.keepaliveCharacteristic() {
            peripheral.setNotifyValue(true, for: keepaliveCharacteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            Log.warning("Scanner didUpdateValueFor characteristic \(characteristic) got unknown error")
            return
        }
        
        switch characteristic.value {
            
        case (let data?) where characteristic.uuid == ContactTracingUUIDs.colocatorIdCharacteristicUUID:
            extractEIDFromCharacteristicData(data, peripheral: peripheral)
            peripheral.readRSSI()
            
        case (let data?) where characteristic.uuid == ContactTracingUUIDs.keepaliveCharacteristicUUID:
            guard data.count == 1 else {
                Log.warning("Received invalid keepalive value: \(data)")
                return
            }
            
            let keepaliveValue = data.withUnsafeBytes { $0.load(as: UInt8.self) }
            Log.info("Received keepalive value \(keepaliveValue)")
            readRSSIAndSendKeepalive()
            
        case .none:
            Log.verbose("characteristic \(characteristic) has no data")
            
        default:
            Log.verbose("Characteristic \(characteristic) has unknown uuid \(characteristic.uuid)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        guard error == nil else {
            Log.warning("Scanner didReadRSSI got unknown error")
            return
        }
        
        readRSSIAndSendKeepalive()
        handleiOSContactWith(peripheral, RSSI: RSSI)
    }
    
    private func readRSSIAndSendKeepalive() {
        guard Date().timeIntervalSince(lastKeepaliveDate) > keepaliveInterval else {
            return
        }
        
        for peripheral in peripherals.values {
            peripheral.readRSSI()
        }
        
        lastKeepaliveDate = Date()
        keepaliveValue = keepaliveValue &+ 1 // note "&+" overflowing add operator, this is required
        let value = Data(bytes: &self.keepaliveValue, count: MemoryLayout.size(ofValue: self.keepaliveValue))
        
        keepaliveTimer = DispatchSource.makeTimerSource(queue: queue)
        keepaliveTimer?.setEventHandler {
            self.advertiser.sendKeepalive(value: value)
        }
        keepaliveTimer?.schedule(deadline: DispatchTime.now() + keepaliveInterval)
        keepaliveTimer?.resume()
    }
    
    func handleiOSContactWith(_ peripheral: CBPeripheral, RSSI: NSNumber) {
        let time = Date().timeIntervalSince1970
        
        if let deviceEID = getEIDForPeripheral(peripheral) {
            DispatchQueue.main.async {
                self.delegate?.newContact(EID: deviceEID, RSSI: Int(truncating: RSSI), timestamp: time)
            }
        } else {
            Log.debug("No EID found for peripheral identifier \(peripheral.identifier)")
        }
    }
    
    func handleAndroidContactWith(deviceEID: String, RSSI: NSNumber) {
        let time = Date().timeIntervalSince1970
        DispatchQueue.main.async {
            self.delegate?.newContact(EID: deviceEID, RSSI: Int(truncating: RSSI), timestamp: time)
        }
    }
    
    func extractEIDFromCharacteristicData(_ data: Data, peripheral: CBPeripheral) {
        if data.count == EIDGeneratorManager.eidLength {
            let EIDString = String(data: data, encoding: .utf8) ?? "undecoded"
            peripheralsEIDs.updateValue(EIDString, forKey: peripheral.identifier)
        } else {
            Log.warning("Received EID with unexpected length: \(data.count). It should be \(EIDGeneratorManager.eidLength)")
        }
    }
    
    func extractEIDFromManufacturerData(_ data: Data) -> String? {
        let eidData = data.subdata(in: 2..<18) //The EID is on 8 bytes, first is a flag (added by the OS ??)
        return String(data: eidData, encoding: .utf8)
    }
}
