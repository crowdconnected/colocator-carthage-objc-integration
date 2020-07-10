//
//  LibraryState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 18/06/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

protocol AutoEquatable {}

public struct LibraryState: StateType {
    let lifecycleState: LifecycleState
    var ccRequestMessagingState: CCRequestMessagingState
    var locationSettingsState: LocationSettingsState
    var batteryLevelState: BatteryLevelState
    var intertialState: InertialState?
    var contactState: ContactState?
}
