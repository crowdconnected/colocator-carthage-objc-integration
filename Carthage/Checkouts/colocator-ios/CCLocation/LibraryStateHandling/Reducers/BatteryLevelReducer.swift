//
//  BatteryLevelReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 13/10/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

struct BatteryLevelReducerConstants {
    static let userDefaultsBatteryLevelKey = "userDefaultsBatteryLevelKey"
    static let batteryLevelKey = "batteryLevelKey"
    static let isNewBatteryLevelKey = "newBatteryLevel"
}

private typealias B = BatteryLevelReducerConstants

func batteryLevelReducer (action: Action, state: BatteryLevelState?) -> BatteryLevelState {
    var state = BatteryLevelState(batteryLevel: 0, isNewBatteryLevel: false)
    
    if let loadedBatteryLevelState = getBatteryLevelStateFromUserDefaults() {
        state = loadedBatteryLevelState
    }
    
    switch action {
        case let batteryLevelChangedAction as BatteryLevelChangedAction:
            state.isNewBatteryLevel = true
            state.batteryLevel = batteryLevelChangedAction.batteryLevel
        
            saveBatteryLevelStateToUserDefaults(batteryLevelState: state)
        
        case _ as BatteryLevelReportedAction:
            state.isNewBatteryLevel = false
        
            saveBatteryLevelStateToUserDefaults(batteryLevelState: state)
        
        default: break
    }
    
    return state
}

func getBatteryLevelStateFromUserDefaults () -> BatteryLevelState? {
    let userDefaults = UserDefaults.standard
    let dictionary = userDefaults.dictionary(forKey: B.userDefaultsBatteryLevelKey)
    
    if dictionary != nil {
        
        return BatteryLevelState(batteryLevel: dictionary?[B.batteryLevelKey] as? UInt32, isNewBatteryLevel: dictionary?[B.isNewBatteryLevelKey] as? Bool)
    } else {
        return nil
    }
}

func saveBatteryLevelStateToUserDefaults (batteryLevelState: BatteryLevelState?){
    
    guard let batteryLevelState = batteryLevelState else {
        return
    }
    
    let userDefaults = UserDefaults.standard
    
    var dictionary = [String:UInt32]()
    
    if let isNewBatteryLevel = batteryLevelState.isNewBatteryLevel {
        dictionary[B.isNewBatteryLevelKey] = isNewBatteryLevel ? 1 : 0
    }
    
    if let batteryLevel = batteryLevelState.batteryLevel {
        dictionary[B.batteryLevelKey] = batteryLevel
    }
    
    userDefaults.set(dictionary, forKey: B.userDefaultsBatteryLevelKey)
}

