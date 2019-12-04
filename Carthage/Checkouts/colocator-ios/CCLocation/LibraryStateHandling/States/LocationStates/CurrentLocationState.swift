//
//  CurrentLocationState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 01/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

public struct CurrentLocationState: StateType, AutoEquatable {
    var currentGEOState: CurrentGEOState?
    var currentGeofencesMonitoringState: CurrentGeofencesMonitoringState?
    var currentBeaconState: CurrentBeaconState?
    var currentiBeaconMonitoringState: CurrentiBeaconMonitoringState?
    var wakeupState: WakeupState?
}
