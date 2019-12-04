//
//  ForegroundiBeaconActions.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 01/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

struct EnableForegroundBeaconAction: Action {
    
    let maxRuntime: UInt64?
    let minOffTime: UInt64?
    var regions: [CLBeaconRegion] = []
    
    let filterWindowSize: UInt64?
    let filterMaxObservations: UInt32?
    var filterExcludeRegions: [CLBeaconRegion] = []
    
    let isEddystoneScanningEnabled: Bool?
    let isIBeaconRangingEnabled: Bool?
    
    init(maxRuntime: UInt64?,
         minOffTime: UInt64?,
         regions: [CLBeaconRegion]?,
         filterWindowSize: UInt64?,
         filterMaxObservations: UInt32?,
         filterExcludeRegions: [CLBeaconRegion]?,
         isEddystoneScanEnabled: Bool?,
         isIBeaconRangingEnabled: Bool?) {
                
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
        
        self.isEddystoneScanningEnabled = isEddystoneScanEnabled
        self.isIBeaconRangingEnabled = isIBeaconRangingEnabled
    }

}

struct DisableForegroundiBeaconAction: Action {}
