//
//  WakeupState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 18/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

enum CCWakeup {
    case notifyWakeup
    case idle
}


public struct WakeupState: StateType, AutoEquatable {
    var ccWakeup: CCWakeup = CCWakeup.idle
}
