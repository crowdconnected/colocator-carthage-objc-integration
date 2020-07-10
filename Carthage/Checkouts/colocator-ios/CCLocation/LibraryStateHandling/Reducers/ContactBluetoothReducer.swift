//
//  ContactReducer.swift
//  CCLocation
//
//  Created by TCode on 15/06/2020.
//  Copyright © 2020 Crowd Connected. All rights reserved.
//

import ReSwift

struct ContactBluetoothReducerConstants {
    static let userDefaultsContactKey = "userDefaultsContactKey"
    static let isContactEnabledKey = "isContactEnabled"
    static let serviceUUIDKey = "ContactTracingserviceUUID"
    static let scanIntervalKey = "scanInterval"
    static let scanDurationKey = "scanDuration"
    static let advertiseIntervalKey = "advertiseInterval"
    static let advertiseDurationKey = "advertiseDuration"
}

private typealias C = ContactBluetoothReducerConstants

func contactBluetoothReducer (action: Action, state: ContactBluetoothState?) -> ContactBluetoothState {
    var state = ContactBluetoothState(isEnabled: false,
                             serviceUUID: nil,
                             scanInterval: nil,
                             scanDuration: nil,
                             advertiseInterval: nil,
                             advertiseDuration: nil)
    if let loadedContactState = getContactBluetoothStateFromUserDefaults() {
        state = loadedContactState
    }
    
    switch action {
        case let contactStateChangedAction as ContactBluetoothStateChangedAction:
            state.isEnabled = contactStateChangedAction.isEnabled
            state.serviceUUID = contactStateChangedAction.serviceUUID
            state.scanInterval = contactStateChangedAction.scanInterval
            state.scanDuration = contactStateChangedAction.scanDuration
            state.advertiseInterval = contactStateChangedAction.advertiseInterval
            state.advertiseDuration = contactStateChangedAction.advertiseDuration
            
            saveContactBluetoothStateToUserDefaults(contactState: state)
        
        case _ as DisableContactBluetoothAction:
            state.isEnabled = false
        
            saveContactBluetoothStateToUserDefaults(contactState: state)
        
        default: break
    }
    
    return state
}

func getContactBluetoothStateFromUserDefaults() -> ContactBluetoothState? {
    let userDefaults = UserDefaults.standard
    let dictionary = userDefaults.dictionary(forKey: C.userDefaultsContactKey)

    if dictionary != nil {
        return ContactBluetoothState(isEnabled: dictionary?[C.isContactEnabledKey] as? Bool,
                            serviceUUID: userDefaults.value(forKey: C.serviceUUIDKey) as? String,
                            scanInterval: dictionary?[C.scanIntervalKey] as? UInt64,
                            scanDuration: dictionary?[C.scanDurationKey] as? UInt64,
                            advertiseInterval: dictionary?[C.advertiseIntervalKey] as? UInt64,
                            advertiseDuration: dictionary?[C.advertiseDurationKey] as? UInt64)
    } else {
       return nil
    }
}

func saveContactBluetoothStateToUserDefaults(contactState: ContactBluetoothState?) {
    guard let contactState = contactState else {
        return
    }
    
    let userDefaults = UserDefaults.standard
    
    var dictionary = [String:UInt64]()
    
    if let isContactEnabled = contactState.isEnabled {
        dictionary[C.isContactEnabledKey] = isContactEnabled ? 1 : 0
    }
    
    if let serviceUUID = contactState.serviceUUID {
          userDefaults.set(serviceUUID, forKey: C.serviceUUIDKey)
    }
    
    if let scanInterval = contactState.scanInterval {
        dictionary[C.scanIntervalKey] = scanInterval
    }
    if let scanDuration = contactState.scanDuration {
        dictionary[C.scanDurationKey] = scanDuration
    }
    if let advertiseInterval = contactState.advertiseInterval {
        dictionary[C.advertiseIntervalKey] = advertiseInterval
    }
    if let advertiseDuration = contactState.advertiseDuration {
        dictionary[C.advertiseDurationKey] = advertiseDuration
    }
    if let scanInterval = contactState.scanInterval {
        dictionary[C.scanIntervalKey] = scanInterval
    }
    
    userDefaults.set(dictionary, forKey: C.userDefaultsContactKey)
}
