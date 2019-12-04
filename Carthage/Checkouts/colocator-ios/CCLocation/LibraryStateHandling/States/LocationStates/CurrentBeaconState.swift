//
//  CurrentiBeaconState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 01/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

public struct CurrentBeaconState: StateType, AutoEquatable {
    
    var isIBeaconRangingEnabled: Bool?
    var isInForeground: Bool?
    var maxRuntime: UInt64?
    var minOffTime: UInt64?
    var regions: [CLBeaconRegion] = []
    
    var filterWindowSize: UInt64?
    var filterMaxObservations: UInt32?
    var filterExcludeRegions: [CLBeaconRegion] = []
    
    var offTime: Date?
    var maxOnTimeStart: Date?
//    var isCyclingEnabled: Bool?
    
    var isEddystoneScanningEnabled: Bool?
    
    init(isIBeaconEnabled: Bool?,
         isInForeground: Bool?,
         maxRuntime: UInt64?,
         minOffTime: UInt64?,
         regions: [CLBeaconRegion]?,
         filterWindowSize: UInt64?,
         filterMaxObservations: UInt32?,
         filterExcludeRegions: [CLBeaconRegion]?,
         offTime: Date?,
         maxOnTimeStart: Date?,
//         isCyclingEnabled: Bool?,
         eddystoneScanEnabled: Bool?) {
        
        self.isIBeaconRangingEnabled = isIBeaconEnabled
        self.isInForeground = isInForeground
        self.maxRuntime = maxRuntime
        self.minOffTime = minOffTime
        
        if let regions = regions{
            self.regions = regions
        }
        
        self.filterWindowSize = filterWindowSize
        self.filterMaxObservations = filterMaxObservations
        
        if let filterExcludeRegions = filterExcludeRegions{
            self.filterExcludeRegions = filterExcludeRegions
        }
        
        self.offTime = offTime
        self.maxOnTimeStart = maxOnTimeStart
//        self.isCyclingEnabled = isCyclingEnabled
        
        self.isEddystoneScanningEnabled = eddystoneScanEnabled
    }
}
