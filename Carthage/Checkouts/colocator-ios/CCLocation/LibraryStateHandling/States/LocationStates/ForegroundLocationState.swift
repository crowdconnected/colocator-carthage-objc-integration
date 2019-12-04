//
//  ForegroundLocationState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 01/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

public struct ForegroundLocationState: StateType, AutoEquatable {
    let foregroundGEOState: ForegroundGEOState?
    let foregroundBeaconState: BeaconState?
}
