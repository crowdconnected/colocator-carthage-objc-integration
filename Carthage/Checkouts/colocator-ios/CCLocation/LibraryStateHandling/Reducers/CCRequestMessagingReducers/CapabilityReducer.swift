//
//  CapabilityReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 20/10/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreBluetooth
import CoreLocation

struct CapabilityReducerConstants {
    static let userDefaultsCapabilityKey = "userDefaultsCapabilityKey"
    static let locationAuthStatus = "locationAuthStatus"
    static let bluetoothHardware = "bluetoothHardware"
    static let batteryState = "batteryState"
    static let isLowPowerModeEnabled = "isLowPowerModeEnabled"
    static let isLocationServicesEnabled = "isLocationServicesEnabled"
    static let isMotionAndFitnessEnabled = "isMotionAndFitnessEnabled"
}

private typealias C = CapabilityReducerConstants

func capabilityReducer (action: Action, state: CapabilityState?) -> CapabilityState {
    
    var state = CapabilityState(locationAuthStatus: CLAuthorizationStatus.notDetermined, bluetoothHardware: CBCentralManagerState.unknown, batteryState: UIDevice.BatteryState.unknown, isLowPowerModeEnabled: false, isLocationServicesEnabled: false, isMotionAndFitnessEnabled: nil)
    
    if let loadedCapabilityState = getCapabilityStateFromUserDefaults() {
        state = loadedCapabilityState
    }
    
    switch action {
    case let batteryStateChangedAction as BatteryStateChangedAction:
        state.batteryState = batteryStateChangedAction.batteryState
        
    case let locationAuthStatusChangedAction as LocationAuthStatusChangedAction:
        state.locationAuthStatus = locationAuthStatusChangedAction.locationAuthStatus
        
    case let bluetoothHardwareChangedAction as BluetoothHardwareChangedAction:
        state.bluetoothHardware = bluetoothHardwareChangedAction.bluetoothHardware
        
    case let isLowPowerModeEnabledAction as IsLowPowerModeEnabledAction:
        state.isLowPowerModeEnabled = isLowPowerModeEnabledAction.isLowPowerModeEnabled
        
    case let isLocationServicesEnabledAction as IsLocationServicesEnabledAction:
        state.isLocationServicesAvailable = isLocationServicesEnabledAction.isLocationServicesEnabled
        
    case let isMotionAndFitnessEnabled as IsMotionAndFitnessEnabledAction:
        state.isMotionAndFitnessAvailable = isMotionAndFitnessEnabled.isMotionAndFitnessEnabled
    default: break
    }

    saveCapabilityStateToUserDefaults(capabilityState: state)
    
    return state
}

func getCapabilityStateFromUserDefaults () -> CapabilityState? {
    
    let userDefaults = UserDefaults.standard
    let dictionary = userDefaults.dictionary(forKey: C.userDefaultsCapabilityKey)
    
    if dictionary != nil {
        
        var locationAuthStatus:CLAuthorizationStatus?
        var bluetoothHardware:CBCentralManagerState?
        var batteryState:UIDevice.BatteryState?
        
        if let authStateRaw = dictionary?[C.locationAuthStatus] {
            locationAuthStatus = CLAuthorizationStatus(rawValue: authStateRaw as! Int32)
        }

        if let bluetoothHardwareRaw = dictionary?[C.bluetoothHardware] {
            bluetoothHardware = CBCentralManagerState(rawValue: bluetoothHardwareRaw as! Int)
        }
        if let batteryStateRaw = dictionary?[C.batteryState] {
            batteryState = UIDevice.BatteryState(rawValue: batteryStateRaw as! Int)
        }

        return CapabilityState(locationAuthStatus: locationAuthStatus, bluetoothHardware: bluetoothHardware, batteryState: batteryState, isLowPowerModeEnabled: dictionary?[C.isLowPowerModeEnabled] as? Bool, isLocationServicesEnabled: dictionary?[C.isLocationServicesEnabled] as? Bool, isMotionAndFitnessEnabled: dictionary?[C.isMotionAndFitnessEnabled] as? Bool)
    } else {
        return nil
    }
}

func saveCapabilityStateToUserDefaults (capabilityState: CapabilityState?){
    
    guard let capabilityState = capabilityState else {
        return
    }
    
    let userDefaults = UserDefaults.standard
    
    var dictionary = [String:Int32]()
    
    if let isLowPowerModeEnabled = capabilityState.isLowPowerModeEnabled {
        dictionary[C.isLowPowerModeEnabled] = isLowPowerModeEnabled ? 1 : 0
    }

    if let isLocationServicesAvailable = capabilityState.isLocationServicesAvailable {
        dictionary[C.isLocationServicesEnabled] = isLocationServicesAvailable ? 1 : 0
    }
    
    if let isMotionAndFitnessAvailable = capabilityState.isMotionAndFitnessAvailable {
        dictionary[C.isMotionAndFitnessEnabled] = isMotionAndFitnessAvailable ? 1 : 0
    }
    
    if let batteryState = capabilityState.batteryState {
        dictionary[C.batteryState] = Int32(batteryState.rawValue)
    }
    
    if let bluetoothHardware = capabilityState.bluetoothHardware {
        dictionary[C.bluetoothHardware] = Int32(bluetoothHardware.rawValue)
    }
    
    if let locationAuthStatus = capabilityState.locationAuthStatus {
        dictionary[C.locationAuthStatus] = locationAuthStatus.rawValue
    }
    
    userDefaults.set(dictionary, forKey: C.userDefaultsCapabilityKey)
}

