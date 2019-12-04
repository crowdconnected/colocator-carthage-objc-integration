//
//  ForegroundGEOReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

private struct ForegroundGEOReducerConstants {
    static let userDefaultsForegroundGEOSettingsKey = "fgGEOSettingsKey"
}

private typealias C = ForegroundGEOReducerConstants

func foregroundGEOReducer (action: Action, state: ForegroundGEOState?) -> ForegroundGEOState {
    var fGGEOState = ForegroundGEOState(fgGEOEnabled: false, fgActivityType: nil, fgMaxRuntime: nil, fgMinOffTime: nil, fgDesiredAccuracy: nil, fgDistanceFilter: nil, fgPausesUpdates: nil)
    
    if let loadedFGGEOState = getFGGEOSettingsStateFromUserDefaults() {
        fGGEOState = loadedFGGEOState
    }
    
    var state = state ?? fGGEOState
    
    switch action {
    case let enableForegroundGEOAction as EnableForegroundGEOAction:
        state.fgActivityType = enableForegroundGEOAction.activityType
        state.fgMaxRuntime = enableForegroundGEOAction.maxRuntime
        state.fgMinOffTime = enableForegroundGEOAction.minOffTime
        state.fgDesiredAccuracy = enableForegroundGEOAction.desiredAccuracy
        state.fgDistanceFilter = enableForegroundGEOAction.distanceFilter
        state.fgPausesUpdates = enableForegroundGEOAction.pausesUpdates
        state.fgGEOEnabled = true
        
        saveFGGEOSateToUserDefaults(geoState: state)
        
    case _ as DisableForegroundGEOAction:
        state.fgGEOEnabled = false

        saveFGGEOSateToUserDefaults(geoState: state)

    default:
        break
    }
    return state
}

private func getFGGEOSettingsStateFromUserDefaults () -> ForegroundGEOState? {
    let userDefaults = UserDefaults.standard

    if let dictionary = userDefaults.dictionary(forKey: C.userDefaultsForegroundGEOSettingsKey){
    
        var activityType: CLActivityType?
        
        if let rawActivityType = dictionary["activityType"] {
            activityType = CLActivityType(rawValue: rawActivityType as! Int)
        }
        
        let fgGEOState = ForegroundGEOState(fgGEOEnabled: dictionary["fgGEOEnabled"] as? Bool, fgActivityType: activityType, fgMaxRuntime: dictionary["maxRuntime"] as? UInt64, fgMinOffTime: dictionary["minOffTime"] as? UInt64, fgDesiredAccuracy: dictionary["desiredAccuracy"] as? Int32, fgDistanceFilter: dictionary["distanceFiler"] as? Int32, fgPausesUpdates: dictionary["pausesUpdates"] as? Bool)

        return fgGEOState
    } else {
        return nil
    }
}

private func saveFGGEOSateToUserDefaults (geoState: ForegroundGEOState){
    
    let userDefaults = UserDefaults.standard
    
    var dictionary = [String:Int64]()
    
    if let activityType = geoState.fgActivityType {
        dictionary["activityType"] = Int64(activityType.rawValue)
    } 
    
    if let maxRuntime = geoState.fgMaxRuntime {
        dictionary["maxRuntime"] = Int64(maxRuntime)
    }
    
    if let minOffTime = geoState.fgMinOffTime {
        dictionary["minOffTime"] = Int64(minOffTime)
    }
    
    if let desiredAccuracy = geoState.fgDesiredAccuracy {
        dictionary["desiredAccuracy"] = Int64(desiredAccuracy)
    }
    
    if let distanceFiler = geoState.fgDistanceFilter {
        dictionary["distanceFiler"] = Int64(distanceFiler)
    }
    
    if let pausesUpdates = geoState.fgPausesUpdates {
        dictionary["pausesUpdates"] = Int64(pausesUpdates ? 1 : 0)
    }
    
    if let fgGEOEnabled = geoState.fgGEOEnabled {
        dictionary["fgGEOEnabled"] = Int64(fgGEOEnabled ? 1 : 0)
    }
    
    userDefaults.set(dictionary, forKey: C.userDefaultsForegroundGEOSettingsKey)
}

