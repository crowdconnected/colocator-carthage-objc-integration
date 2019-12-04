//
//  InertialReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 07/06/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import ReSwift

struct InertialReducerConstants {
    static let userDefaultsInertialKey = "userDefaultsInertialKey"
    static let isInertialEnabledKey = "isInertialEnabled"
    static let intervalKey = "interval"
}

private typealias I = InertialReducerConstants

func inertialReducer (action: Action, state: InertialState?) -> InertialState {
    var state = InertialState(isEnabled: false, interval: 0)
    
    if let loadedInertialState = getInertialStateFromUserDefaults() {
        state = loadedInertialState
    }
    
    switch action {
        case let inertialStateChangedAction as InertialStateChangedAction:
            state.isEnabled = inertialStateChangedAction.isEnabled
            state.interval = inertialStateChangedAction.interval
            
            saveInertialStateToUserDefaults(inertialState: state)
        
        case _ as DisableInertialAction:
            state.isEnabled = false
        
            saveInertialStateToUserDefaults(inertialState: state)
        
        default: break
    }
    
    return state
}

func getInertialStateFromUserDefaults () -> InertialState? {
    let userDefaults = UserDefaults.standard
    let dictionary = userDefaults.dictionary(forKey: I.userDefaultsInertialKey)

    if dictionary != nil {
        return InertialState(isEnabled: dictionary?[I.isInertialEnabledKey] as? Bool,
                             interval: dictionary?[I.intervalKey] as? UInt32)
    } else {
       return nil
    }
}

func saveInertialStateToUserDefaults (inertialState: InertialState?) {
    guard let inertialState = inertialState else {
        return
    }
    
    let userDefaults = UserDefaults.standard

    var dictionary = [String:UInt32]()
    
    if let isInertialEnabled = inertialState.isEnabled {
        dictionary[I.isInertialEnabledKey] = isInertialEnabled ? 1 : 0
    }
    
    if let inertialInterval = inertialState.interval {
        dictionary[I.intervalKey] = inertialInterval
    }
    
    userDefaults.set(dictionary, forKey: I.userDefaultsInertialKey)

}
