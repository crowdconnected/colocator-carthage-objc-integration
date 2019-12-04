//
//  LocationState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

public struct LocationSettingsState: StateType {
    var currentLocationState: CurrentLocationState?
    let foregroundLocationState: ForegroundLocationState?
    let backgroundLocationState: BackgroundLocationState?
}
