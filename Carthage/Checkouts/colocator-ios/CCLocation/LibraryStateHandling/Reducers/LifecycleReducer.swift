//
//  LifecycleReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

func lifecycleReducer (action: Action, state: LifecycleState?) -> LifecycleState {
    var state = state ?? LifecycleState()
    
    if let lifeCycleAction = action as? LifeCycleAction {
        state.lifecycleState = lifeCycleAction.lifecycleState
    }

    return state
}
