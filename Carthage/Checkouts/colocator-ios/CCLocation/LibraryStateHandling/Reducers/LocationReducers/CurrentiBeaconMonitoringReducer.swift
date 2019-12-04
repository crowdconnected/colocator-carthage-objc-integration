//
//  CurrentiBeaconMonitoringReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 02/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

private struct CurrentiBeaconMonitorinReducerConstants {
    static let userDefaultsCurrentiBeaconMonitoringKey = "currentiBeaconMonitoringKey"
}

private typealias C = CurrentiBeaconMonitorinReducerConstants

func currentiBeaconMonitoringReducer (action: Action, state: CurrentiBeaconMonitoringState?) -> CurrentiBeaconMonitoringState {
    let state = state ?? CurrentiBeaconMonitoringState(monitoringRegions: [])
    
    return state
}

private func getCurrentStateFromUserDefaults () -> CurrentiBeaconMonitoringState? {
    let userDefaults = UserDefaults.standard
    let value = userDefaults.string(forKey: C.userDefaultsCurrentiBeaconMonitoringKey)
    
    if value != nil {
        return CurrentiBeaconMonitoringState(monitoringRegions: [])
    } else {
        return nil
    }
}

private func saveCurrentStateToUserDefaults (currentGEOState: CurrentiBeaconMonitoringState) {
    // Beacon monitoring is not saved in UserDefaults at the moment
}
