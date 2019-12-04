//
//  GeofencesActions.swift
//  CCLocation
//
//  Created by Mobile Developer on 20/08/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation

import ReSwift
import CoreLocation

struct EnableGeofencesMonitoringAction: Action {
    let geofences: [CLCircularRegion]?
}

struct DisableGeofencesMonitoringAction: Action {}
