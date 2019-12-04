//
//  BackgroundGEOReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 31/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

private struct BackgroundGEOReducerConstants {
    static let userDefaultsBackgroundGEOSettingsKey = "bGGEOSettingsKey"
}

private typealias C = BackgroundGEOReducerConstants

func backgroundGEOReducer (action: Action, state: BackgroundGEOState?) -> BackgroundGEOState {
    var bGGEOState = BackgroundGEOState(bgGEOEnabled: false, bgActivityType: nil, bgMaxRuntime: nil, bgMinOffTime: nil, bgDesiredAccuracy: nil, bgDistanceFilter: nil, bgPausesUpdates: nil)
    
    if let loadedGBGEOState = getBGGEOSettingsStateFromUserDefaults() {
        bGGEOState = loadedGBGEOState
    }
    
    var state = state ?? bGGEOState
    
    switch action {
    case let setBackgroundGEOAction as EnableBackgroundGEOAction:

        state.bgActivityType = setBackgroundGEOAction.activityType
        state.bgMinOffTime = setBackgroundGEOAction.minOffTime
        state.bgMaxRuntime = setBackgroundGEOAction.maxRuntime
        state.bgDesiredAccuracy = setBackgroundGEOAction.desiredAccuracy
        state.bgDistanceFilter = setBackgroundGEOAction.distanceFilter
        state.bgPausesUpdates = setBackgroundGEOAction.pausesUpdates
        state.bgGEOEnabled = true
        
        saveBGGEOSateToUserDefaults(geoState: state)
        
    case _ as DisableBackgroundGEOAction:
        state.bgGEOEnabled = false

        saveBGGEOSateToUserDefaults(geoState: state)
       
    default:
        break
    }
    return state
}

private func getBGGEOSettingsStateFromUserDefaults () -> BackgroundGEOState? {
    let userDefaults = UserDefaults.standard
    let dictionary = userDefaults.dictionary(forKey: C.userDefaultsBackgroundGEOSettingsKey)
    
    if dictionary != nil {
        
        var activityType: CLActivityType?
        
        if let rawActivityType = dictionary?["activityType"] {
            activityType = CLActivityType(rawValue: rawActivityType as! Int)
        }
        
        return BackgroundGEOState(bgGEOEnabled: dictionary?["bgGEOEnabled"] as? Bool , bgActivityType: activityType, bgMaxRuntime: dictionary?["maxRuntime"] as? UInt64, bgMinOffTime: dictionary?["minOffTime"] as? UInt64, bgDesiredAccuracy: dictionary?["desiredAccuracy"] as? Int32, bgDistanceFilter: dictionary?["distanceFiler"] as? Int32, bgPausesUpdates: dictionary?["pausesUpdates"] as? Bool)
    } else {
        return nil
    }
}

private func saveBGGEOSateToUserDefaults (geoState: BackgroundGEOState){
    
    let userDefaults = UserDefaults.standard
    
    var dictionary = [String:Int64]()
    
    if let activityType = geoState.bgActivityType {
        dictionary["activityType"] = Int64(activityType.rawValue)
    }

    if let maxRuntime = geoState.bgMaxRuntime {
        dictionary["maxRuntime"] = Int64(maxRuntime)
    }

    if let minOffTime = geoState.bgMinOffTime {
        dictionary["minOffTime"] = Int64(minOffTime)
    }

    if let desiredAccuracy = geoState.bgDesiredAccuracy {
        dictionary["desiredAccuracy"] = Int64(desiredAccuracy)
    }

    if let distanceFiler = geoState.bgDistanceFilter {
        dictionary["distanceFiler"] = Int64(distanceFiler)
    }
    
    if let pausesUpdates = geoState.bgPausesUpdates {
        dictionary["pausesUpdates"] = pausesUpdates ? 1 : 0
    }

    if let bgGEOEnabled = geoState.bgGEOEnabled {
        dictionary["bgGEOEnabled"] = bgGEOEnabled ? 1 : 0
    }
    
    userDefaults.set(dictionary, forKey: C.userDefaultsBackgroundGEOSettingsKey)
}
