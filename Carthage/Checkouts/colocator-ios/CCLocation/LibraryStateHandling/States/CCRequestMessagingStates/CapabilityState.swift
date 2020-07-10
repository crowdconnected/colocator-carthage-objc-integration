//
//  CapabilityState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 20/10/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation
import CoreBluetooth

public struct CapabilityState: StateType, AutoEquatable {
    var locationAuthStatus: CLAuthorizationStatus?
    var bluetoothHardware: CBCentralManagerState?
    var batteryState: UIDevice.BatteryState?
    var isLowPowerModeEnabled: Bool?
    var isLocationServicesAvailable: Bool?
    var isMotionAndFitnessAvailable: Bool?
    
    init(locationAuthStatus: CLAuthorizationStatus?,
         bluetoothHardware: CBCentralManagerState?,
         batteryState: UIDevice.BatteryState?,
         isLowPowerModeEnabled: Bool?,
         isLocationServicesEnabled: Bool?,
         isMotionAndFitnessEnabled: Bool?) {
        
        self.locationAuthStatus = locationAuthStatus
        self.bluetoothHardware = bluetoothHardware
        self.batteryState = batteryState
        self.isLowPowerModeEnabled = isLowPowerModeEnabled
        self.isLocationServicesAvailable = isLocationServicesEnabled
        self.isMotionAndFitnessAvailable = isMotionAndFitnessEnabled
    }
}
