//
//  CurrentGEOState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

public struct CurrentGEOState: StateType, AutoEquatable {
    // settings currently applied to geo handling by library
    
    var isInForeground: Bool?
    
    var isSignificantLocationChangeMonitoringState: Bool?
    var isStandardGEOEnabled: Bool?
    var activityType: CLActivityType?
    var maxRuntime: UInt64?
    var minOffTime: UInt64?
    var desiredAccuracy: Int32?
    var distanceFilter: Int32?
    var pausesUpdates: Bool?
    
    var offTime: Date?
    
    init(isInForeground: Bool?,
         activityType: CLActivityType?,
         maxRuntime: UInt64?,
         minOffTime: UInt64?,
         desiredAccuracy: Int32?,
         distanceFilter: Int32?,
         pausesUpdates: Bool?,
         isSignificantUpdates: Bool?,
         isStandardGEOEnabled: Bool?) {

        self.isInForeground = isInForeground
        self.activityType = activityType
        self.maxRuntime = maxRuntime
        self.minOffTime = minOffTime
        self.desiredAccuracy = desiredAccuracy
        self.distanceFilter = distanceFilter
        self.pausesUpdates = pausesUpdates
        self.isSignificantLocationChangeMonitoringState = isSignificantUpdates
        self.isStandardGEOEnabled = isStandardGEOEnabled
    }
}
