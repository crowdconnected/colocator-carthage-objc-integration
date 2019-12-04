//
//  InertialActions.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 07/06/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import ReSwift

struct InertialStateChangedAction: Action {
    let isEnabled: Bool?
    let interval: UInt32?
}

struct DisableInertialAction: Action {}
