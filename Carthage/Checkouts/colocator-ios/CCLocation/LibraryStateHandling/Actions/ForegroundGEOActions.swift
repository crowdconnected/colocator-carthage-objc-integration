//
//  ForegroundGEOActions.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

struct EnableForegroundGEOAction: Action {
    let activityType: CLActivityType?
    let maxRuntime: UInt64?
    let minOffTime: UInt64?
    let desiredAccuracy: Int32?
    let distanceFilter: Int32?
    let pausesUpdates: Bool?
    
    init(activityType: CLActivityType?,
         maxRuntime: UInt64?,
         minOffTime: UInt64?,
         desiredAccuracy: Int32?,
         distanceFilter: Int32?,
         pausesUpdates: Bool?) {
        
        self.activityType = activityType
        self.maxRuntime = maxRuntime
        self.minOffTime = minOffTime
        self.desiredAccuracy = desiredAccuracy
        self.distanceFilter = distanceFilter
        self.pausesUpdates = pausesUpdates
    }
}

struct DisableForegroundGEOAction: Action {}
