//
//  ForegroundGEOState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

struct BackgroundGEOState: StateType, AutoEquatable {
    var bgGEOEnabled: Bool?
    var bgActivityType: CLActivityType?
    var bgMaxRuntime: UInt64?
    var bgMinOffTime: UInt64?
    var bgDesiredAccuracy: Int32?
    var bgDistanceFilter: Int32?
    var bgPausesUpdates: Bool?
    
    init(bgGEOEnabled: Bool?,
         bgActivityType: CLActivityType?,
         bgMaxRuntime: UInt64?,
         bgMinOffTime: UInt64?,
         bgDesiredAccuracy: Int32?,
         bgDistanceFilter: Int32?,
         bgPausesUpdates: Bool?) {
        
        self.bgGEOEnabled = bgGEOEnabled
        self.bgActivityType = bgActivityType
        self.bgMaxRuntime = bgMaxRuntime
        self.bgMinOffTime = bgMinOffTime
        self.bgDesiredAccuracy = bgDesiredAccuracy
        self.bgDistanceFilter = bgDistanceFilter
        self.bgPausesUpdates = bgPausesUpdates
    }
}
