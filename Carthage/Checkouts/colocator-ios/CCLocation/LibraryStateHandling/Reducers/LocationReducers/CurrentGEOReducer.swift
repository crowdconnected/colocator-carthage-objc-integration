//
//  CurrentGEOSettingsReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

struct CurrentGEOReducerConstants {
    static let userDefaultsCurrentGEOKey = "currentGEOSettingsKey"
    static let activityType = "activityType"
    static let maxRuntime = "maxRuntime"
    static let minOffTime = "minOffTime"
    static let desiredAccuracy = "desiredAccuracy"
    static let distanceFilter = "distanceFilter"
    static let pausesUpdates = "pausesUpdates"
    static let isStandardGEOEnabled = "isStandardGEOEnabled"
    static let isSignificantUpdates = "isSignificantUpdates"
    static let isInForeground = "isInForeground"
}

private typealias C = CurrentGEOReducerConstants

func currentGEOReducer (action: Action, state: CurrentGEOState?) -> CurrentGEOState {
    
    var currentGEOState = CurrentGEOState(isInForeground: nil, activityType: nil, maxRuntime: nil, minOffTime: nil, desiredAccuracy: nil, distanceFilter: nil, pausesUpdates: nil, isSignificantUpdates: nil, isStandardGEOEnabled: nil)
    
    if let loadedCurrentGEOState = getCurrentGEOStateFromUserDefaults() {
        currentGEOState = loadedCurrentGEOState
    }
    
    var state = state ?? currentGEOState
    
    switch action {
        
    case let significantLocationSettingsAction as IsSignificationLocationChangeAction:
        state.isSignificantLocationChangeMonitoringState = significantLocationSettingsAction.isSignificantLocationChangeMonitoringState
        saveCurrentGEOSateToUserDefaults(geoState: state)
    
    case let offTime as SetGEOOffTimeEnd:
        state.offTime = offTime.offTimeEnd
        saveCurrentGEOSateToUserDefaults(geoState: state)
        
    case _ as DisableCurrrentGEOAction:
        state.isStandardGEOEnabled = false
        
        saveCurrentGEOSateToUserDefaults(geoState: state)

    default:
        break
    }
    return state
}

func getCurrentGEOStateFromUserDefaults () -> CurrentGEOState? {
    let userDefaults = UserDefaults.standard
    let dictionary = userDefaults.dictionary(forKey: C.userDefaultsCurrentGEOKey)
    
    if dictionary != nil {
        
        var activityType: CLActivityType?
        
        if let rawActivityType = dictionary?[C.activityType] {
            activityType = CLActivityType(rawValue: rawActivityType as! Int)
        }
        
        return CurrentGEOState(isInForeground: dictionary?[C.isInForeground] as? Bool, activityType: activityType, maxRuntime: dictionary?[C.maxRuntime] as? UInt64, minOffTime: dictionary?[C.minOffTime] as? UInt64, desiredAccuracy: dictionary?[C.desiredAccuracy] as? Int32, distanceFilter: dictionary?[C.distanceFilter] as? Int32, pausesUpdates: dictionary?[C.pausesUpdates] as? Bool, isSignificantUpdates: dictionary?[C.isSignificantUpdates] as? Bool, isStandardGEOEnabled: dictionary?[C.isStandardGEOEnabled] as? Bool)
    } else {
        return nil
    }
}

func saveCurrentGEOSateToUserDefaults (geoState: CurrentGEOState?){
    
    guard let geoState = geoState else {
        return
    }
    
    let userDefaults = UserDefaults.standard
    
    var dictionary = [String:Int64]()
    
    if let activityType = geoState.activityType {
        dictionary[C.activityType] = Int64(activityType.rawValue)
    }
    
    if let maxRuntime = geoState.maxRuntime {
        dictionary[C.maxRuntime] = Int64(maxRuntime)
    }
    
    if let minOffTime = geoState.minOffTime {
        dictionary[C.minOffTime] = Int64(minOffTime)
    }
    
    if let desiredAccuracy = geoState.desiredAccuracy {
        dictionary[C.desiredAccuracy] = Int64(desiredAccuracy)
    }
    
    if let distanceFilter = geoState.distanceFilter {
        dictionary[C.distanceFilter] = Int64(distanceFilter)
    }
    
    if let pausesUpdates = geoState.pausesUpdates {
        dictionary[C.pausesUpdates] = pausesUpdates ? 1 : 0
    }
    
    if let isSignificantUpdates = geoState.isSignificantLocationChangeMonitoringState {
        dictionary[C.isSignificantUpdates] = isSignificantUpdates ? 1 : 0
    }
    
    if let isStandardUpdates = geoState.isStandardGEOEnabled {
        dictionary[C.isStandardGEOEnabled] = isStandardUpdates ? 1 : 0
    }

    if let isInForeground = geoState.isInForeground {
        dictionary[C.isInForeground] = isInForeground ? 1 : 0
    }

    
    userDefaults.set(dictionary, forKey: C.userDefaultsCurrentGEOKey)
}
