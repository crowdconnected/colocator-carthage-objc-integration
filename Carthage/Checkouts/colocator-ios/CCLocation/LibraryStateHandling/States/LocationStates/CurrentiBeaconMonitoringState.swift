//
//  CurrentiBeaconMonitoringState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 02/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

public struct CurrentiBeaconMonitoringState: StateType, AutoEquatable {
    var monitoringRegions: [CLBeaconRegion] = []
    
    init(monitoringRegions: [CLBeaconRegion]?) {
        if let monitoringRegions = monitoringRegions {
            self.monitoringRegions = monitoringRegions
        }
    }
}
