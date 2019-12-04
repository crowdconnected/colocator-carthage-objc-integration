//
//  LifecycleState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

enum LifeCycle {
    case background
    case foreground
}

public struct LifecycleState: StateType, AutoEquatable {
    var lifecycleState: LifeCycle
    
    init() {
        lifecycleState = LifeCycle.foreground
    }
}
