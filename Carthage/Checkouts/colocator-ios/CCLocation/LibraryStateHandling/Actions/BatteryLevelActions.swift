//
//  BatteryLevelActions.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 13/10/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

struct BatteryLevelChangedAction : Action {
    let batteryLevel: UInt32
}

struct BatteryLevelReportedAction : Action {}

