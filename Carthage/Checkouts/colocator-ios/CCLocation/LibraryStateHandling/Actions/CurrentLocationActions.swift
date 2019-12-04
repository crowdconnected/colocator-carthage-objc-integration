//
//  CurrentLocationActions.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 02/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import Foundation

import ReSwift
import CoreLocation

struct EnableCurrentiBeaconMonitoringAction: Action {
    let monitoringRegions: [CLBeaconRegion]?
}

struct DisableCurrentiBeaconMonitoringAction: Action {}
