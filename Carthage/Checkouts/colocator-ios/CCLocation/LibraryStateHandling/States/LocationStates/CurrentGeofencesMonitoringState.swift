//
//  CurrentGeofencesMonitoringState.swift
//  CCLocation
//
//  Created by Mobile Developer on 20/08/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

public struct CurrentGeofencesMonitoringState: StateType, AutoEquatable {
    var monitoringGeofences: [CLCircularRegion] = []
    
    init(monitoringGeofences: [CLCircularRegion]?) {
        if let monitoringGeofences = monitoringGeofences {
            self.monitoringGeofences = monitoringGeofences
        }
    }
}

