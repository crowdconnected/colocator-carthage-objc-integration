//
//  ForegroundLocationReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 01/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

func foregroundLocationReducer (action: Action, state: ForegroundLocationState?) -> ForegroundLocationState {
    let state = ForegroundLocationState(
        foregroundGEOState: foregroundGEOReducer(action: action, state: state?.foregroundGEOState),
        foregroundBeaconState: foregroundBeaconReducer(action: action, state: state?.foregroundBeaconState)
    )
    
    return state
}
