//
//  WakeupStateReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 18/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

func wakeupReducer (action: Action, state: WakeupState?) -> WakeupState {
    var state = state ?? WakeupState(ccWakeup: CCWakeup.idle)
    
    switch action {
    case let notifyWakeupAction as NotifyWakeupAction:
                
        if notifyWakeupAction.ccWakeup != state.ccWakeup{
            state.ccWakeup = notifyWakeupAction.ccWakeup
        }
        
    default: break
    }
    return state
}
