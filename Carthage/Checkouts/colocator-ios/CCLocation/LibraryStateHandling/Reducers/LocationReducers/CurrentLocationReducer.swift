//
//  CurrentLocationReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 01/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

func currentLocationReducer (action: Action, state: CurrentLocationState?) -> CurrentLocationState {
    let state = CurrentLocationState(
        currentGEOState: currentGEOReducer(action: action, state: state?.currentGEOState),
        currentGeofencesMonitoringState: currentGeofencesMonitoringReducer(action: action, state: state?.currentGeofencesMonitoringState),
        currentBeaconState: currentBeaconReducer(action: action, state: state?.currentBeaconState),
        currentiBeaconMonitoringState: currentiBeaconMonitoringReducer(action: action, state: state?.currentiBeaconMonitoringState),
        wakeupState: wakeupReducer(action: action, state: state?.wakeupState)
    )
    
    return state
}

