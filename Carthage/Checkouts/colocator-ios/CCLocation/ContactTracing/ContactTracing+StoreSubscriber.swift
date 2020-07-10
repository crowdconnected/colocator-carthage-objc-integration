//
//  ContactTracing+StoreSubscriber.swift
//  CCLocation
//
//  Created by TCode on 15/06/2020.
//  Copyright © 2020 Crowd Connected. All rights reserved.
//

import Foundation
import CoreBluetooth
import ReSwift

extension ContactTracing: StoreSubscriber {
    
    public func newState(state: LibraryState) {
        guard let newContactState = state.contactState?.contactBluetoothState else {
            return
        }
        
        if newContactState != currentContactState {
            if let serviceUUID = newContactState.serviceUUID {
                ContactTracingUUIDs.colocatorServiceUUID = CBUUID(string: serviceUUID)
            }
            if let scanInterval = newContactState.scanInterval {
                self.scanningInterval = Int(scanInterval)
            }
            if let scanDuration = newContactState.scanDuration {
                self.scanningPeriod = Int(scanDuration)
            }
            if let advertiseInterval = newContactState.advertiseInterval {
                self.advertisingInterval = Int(advertiseInterval)
            }
            if let advertiseDuration = newContactState.advertiseDuration {
                self.advertisingPeriod = Int(advertiseDuration)
            }
            
            Log.debug("ContactTracing: New state is: \(newContactState)")
            
            updateCurrentContactStateActivity(newState: newContactState)
            currentContactState = newContactState
            return
        } else {
            if !isRunning {
                updateCurrentContactStateActivity(newState: newContactState)
            }
        }
    }
    
    private func updateCurrentContactStateActivity(newState: ContactBluetoothState) {
        stop()
        
        if newState.isEnabled ?? false {
            start()
        }
    }
}
