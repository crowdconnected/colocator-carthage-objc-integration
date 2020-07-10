//
//  CapabilityActions.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 22/10/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation
import CoreBluetooth

struct BatteryStateChangedAction : Action {
    let batteryState : UIDevice.BatteryState
}

struct LocationAuthStatusChangedAction : Action {
    let locationAuthStatus: CLAuthorizationStatus?
}

struct BluetoothHardwareChangedAction : Action {
    let bluetoothHardware: CBCentralManagerState?
}

struct IsLowPowerModeEnabledAction : Action {
    let isLowPowerModeEnabled: Bool?
}

struct IsLocationServicesEnabledAction : Action {
    let isLocationServicesEnabled: Bool?
}

struct IsMotionAndFitnessEnabledAction : Action {
    let isMotionAndFitnessEnabled: Bool?
}
