//
//  CurrentGEOSettingsState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

struct IsSignificationLocationChangeAction: Action {
    let isSignificantLocationChangeMonitoringState: Bool
}

struct SetGEOOffTimeEnd: Action {
    let offTimeEnd: Date?
}

struct DisableCurrrentGEOAction: Action {}
