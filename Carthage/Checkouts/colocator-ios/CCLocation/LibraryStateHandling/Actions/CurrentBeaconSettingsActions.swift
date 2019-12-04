//
//  CurrentiBeaconSettingsActions.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 04/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

struct SetiBeaconOffTimeEndAction: Action {
    let offTimeEnd: Date?
}

struct SetiBEaconMaxOnTimeStartAction: Action {
    let maxOnTimeStart: Date?
}

struct DisableCurrrentiBeaconAction: Action {}
