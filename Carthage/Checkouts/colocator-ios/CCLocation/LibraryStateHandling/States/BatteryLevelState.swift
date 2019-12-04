//
//  BatteryState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 13/10/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

public struct BatteryLevelState: StateType, AutoEquatable {
    var batteryLevel: UInt32?
    var isNewBatteryLevel: Bool?
    
    init(batteryLevel: UInt32?,
         isNewBatteryLevel: Bool?) {
        
        self.batteryLevel = batteryLevel
        self.isNewBatteryLevel = isNewBatteryLevel
    }
}

