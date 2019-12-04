//
//  CurrentGeofencesMonitoringReducer.swift
//  CCLocation
//
//  Created by Mobile Developer on 20/08/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import ReSwift

private struct CurrentGeofencesMonitorinReducerConstants {
    static let userDefaultsCurrentGeofencesMonitoringKey = "currentGeofencesMonitoringKey"
}

private typealias C = CurrentGeofencesMonitorinReducerConstants

func currentGeofencesMonitoringReducer (action: Action, state: CurrentGeofencesMonitoringState?) -> CurrentGeofencesMonitoringState {
    var state = state ?? CurrentGeofencesMonitoringState(monitoringGeofences: [])
   
    switch action {
        
    case let newGeofencesAction as EnableGeofencesMonitoringAction:
        state.monitoringGeofences = newGeofencesAction.geofences ?? []
        
    case _ as DisableGeofencesMonitoringAction:
        state.monitoringGeofences = []
        
    default:
        break
    }
    
    return state
}

private func getCurrentStateFromUserDefaults () -> CurrentGeofencesMonitoringState? {
    let userDefaults = UserDefaults.standard
    let value = userDefaults.string(forKey: C.userDefaultsCurrentGeofencesMonitoringKey)
    
    if value != nil {
        return CurrentGeofencesMonitoringState(monitoringGeofences: [])
    } else {
        return nil
    }
}

private func saveCurrentStateToUserDefaults(currentGEOState: CurrentGeofencesMonitoringState) {
    // Monitored circular regions and beacon regions are not saved into UserDefaults
}
