//
//  ForegroundGEOState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

struct ForegroundGEOState: StateType, AutoEquatable {
    var fgGEOEnabled: Bool?
    var fgActivityType: CLActivityType?
    var fgMaxRuntime: UInt64?
    var fgMinOffTime: UInt64?
    var fgDesiredAccuracy: Int32?
    var fgDistanceFilter: Int32?
    var fgPausesUpdates: Bool?
    
    init(fgGEOEnabled:Bool?,
         fgActivityType: CLActivityType?,
         fgMaxRuntime: UInt64?,
         fgMinOffTime: UInt64?,
         fgDesiredAccuracy: Int32?,
         fgDistanceFilter: Int32?,
         fgPausesUpdates: Bool?) {
        
        self.fgGEOEnabled = fgGEOEnabled
        self.fgActivityType = fgActivityType
        self.fgMaxRuntime = fgMaxRuntime
        self.fgMinOffTime = fgMinOffTime
        self.fgDesiredAccuracy = fgDesiredAccuracy
        self.fgDistanceFilter = fgDistanceFilter
        self.fgPausesUpdates = fgPausesUpdates
    }
}
