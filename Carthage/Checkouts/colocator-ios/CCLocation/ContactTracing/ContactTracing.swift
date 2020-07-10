//
//  ContactTracing.swift
//  CCLocation
//
//  Created by TCode on 15/06/2020.
//  Copyright © 2020 Crowd Connected. All rights reserved.
//

import Foundation
import CoreBluetooth
import ReSwift

class ContactTracing: NSObject {
    internal var isRunning = false
    
    internal var advertisingInterval: Int?
    internal var advertisingPeriod: Int?
    internal var scanningInterval: Int?
    internal var scanningPeriod: Int?
    
    private var advertiser: ContactAdvertiser?
    private var scanner: ContactScanner?
    
    private var queue = DispatchQueue(label: "ColocatorBroadcaster")
     
    let centralRestoreIdentifier: String = "ColocatorCentralRestoreIdentifier"
    let peripheralRestoreIdentifier: String = "ColocatorPeripheralRestoreIdentifier"
       
    private var central: CBCentralManager?
    private var peripheral: CBPeripheralManager?
    
    var currentContactState: ContactBluetoothState!
    weak var stateStore: Store<LibraryState>!
    public weak var delegate: ContactScannerDelegate?
    public var eidGenerator: EIDGeneratorManager?
    
    init(stateStore: Store<LibraryState>) {
        super.init()
        
        self.stateStore = stateStore
        currentContactState = ContactBluetoothState(isEnabled: false,
                                           serviceUUID: "",
                                           scanInterval: 0,
                                           scanDuration: 0,
                                           advertiseInterval: 0,
                                           advertiseDuration: 0)
        stateStore.subscribe(self)
    }
    
    internal func start() {
        Log.info("Contact Tracing starting...")
        
        startAdvertising()
        startScanning()
    }
    
    internal func stop() {
        Log.info("Contact Tracing stopping...")
        
        isRunning = false
        peripheral?.stopAdvertising()
        central?.stopScan()
        scanner?.forceStopScanner()
        advertiser?.forceStopAdvertiser()
        
        advertiser = nil
        scanner = nil
    }
    
    private func startAdvertising() {
        guard let eidGenerator = eidGenerator else {
            Log.warning("Cannot start advertising with a nil EIDGenerator")
            isRunning = false
            return
        }
        
        advertiser = ContactAdvertiser(eidGenerator: eidGenerator)
        advertiser?.advertiseDuration = advertisingPeriod != nil ? Int(advertisingPeriod! / 1000) : nil
        advertiser?.advertiseInterval = advertisingInterval != nil ? Int(advertisingInterval! / 1000) : nil
        
        peripheral = CBPeripheralManager(delegate: advertiser,
                                         queue: queue,
                                         options: [CBPeripheralManagerOptionRestoreIdentifierKey: peripheralRestoreIdentifier])
        isRunning = true
        
        Log.info("Started advertising for Contact Tracing")
    }
    
    private func startScanning() {
        if advertiser == nil {
            Log.warning("Scanner cannot start while advertiser is nil")
            return
        }
        
        if delegate == nil {
            Log.warning("Scanner cannot start with a nil delegate")
            return
        }
        
        scanner = ContactScanner(advertiser: advertiser!, queue: queue, delegate: delegate!)
        scanner?.scanDuration = scanningPeriod != nil ? Int(scanningPeriod! / 1000) : nil
        scanner?.scanInterval = scanningInterval != nil ? Int(scanningInterval! / 1000) : nil
        
        central = CBCentralManager(delegate: scanner,
                                          queue: queue,
                                          options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(true),
                                                    CBCentralManagerOptionRestoreIdentifierKey: centralRestoreIdentifier,
                                                    CBCentralManagerOptionShowPowerAlertKey: NSNumber(false)])
        
        Log.info("Started scanning for Contact Tracing")
    }
}
