//
//  BackgroundLocationReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 01/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

func backgroundLocationReducer (action: Action, state: BackgroundLocationState?) -> BackgroundLocationState {
    let state = BackgroundLocationState(
        backgroundGEOState: backgroundGEOReducer(action: action, state: state?.backgroundGEOState),
        backgroundBeaconState: backgroundiBeaconReducer(action: action, state: state?.backgroundBeaconState)
    )
    return state
}
