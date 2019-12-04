//
//  ForegroundiBeaconState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 01/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

public struct BeaconState: StateType, AutoEquatable {
    var isIBeaconRangingEnabled: Bool?
    
    var maxRuntime: UInt64?
    var minOffTime: UInt64?
    var regions: [CLBeaconRegion] = []
    
    var filterWindowSize: UInt64?
    var filterMaxObservations: UInt32?
    var filterExcludeRegions: [CLBeaconRegion] = []
    
    var isEddystoneScanningEnabled: Bool?
    
    init(beaconRangingEnabled: Bool,
         maxRuntime: UInt64?,
         minOffTime: UInt64?,
         regions: [CLBeaconRegion]?,
         filterWindowSize: UInt64?,
         filterMaxObservations: UInt32?,
         filterExcludeRegions: [CLBeaconRegion]?,
         eddystoneScanEnabled: Bool?) {
        
        self.isIBeaconRangingEnabled = beaconRangingEnabled
        
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
        
        self.isEddystoneScanningEnabled = eddystoneScanEnabled
    }
    
    static func emptyInit() -> BeaconState {
        return self.init(beaconRangingEnabled: false,
                         maxRuntime: nil,
                         minOffTime: nil,
                         regions: [],
                         filterWindowSize: nil,
                         filterMaxObservations: nil,
                         filterExcludeRegions: [],
                         eddystoneScanEnabled: false)
    }
}
