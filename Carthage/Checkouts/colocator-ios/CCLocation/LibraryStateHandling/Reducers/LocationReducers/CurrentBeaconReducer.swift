//
//  CurrentiBeaconReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 01/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

private struct CurrentBeaconReducerConstants {
    static let userDefaultsCurrentiBeaconKey = "currentiBeaconKey"
    static let userDefaultsCurrentiBeaconRegionsKey = "currentiBeaconRegionsKey"
    static let userDefaultsCurrentiBeaconFilterRegionsKey = "currentiBeaconFilterRegionsKey"
}

private typealias C = CurrentBeaconReducerConstants

func currentBeaconReducer (action: Action, state: CurrentBeaconState?) -> CurrentBeaconState {
    var currentiBeaconState = CurrentBeaconState(isIBeaconEnabled: nil, isInForeground: nil, maxRuntime: nil, minOffTime: nil, regions: [], filterWindowSize: nil, filterMaxObservations: nil, filterExcludeRegions: [], offTime: nil, maxOnTimeStart: nil, eddystoneScanEnabled: false)
    
    if let loadedCurrentiBeaconState = getCurrentiBeaconStateFromUserDefaults() {
        currentiBeaconState = loadedCurrentiBeaconState
    }

    var state = state ?? currentiBeaconState
    
    switch action {

    case let offTime as SetiBeaconOffTimeEndAction:
        state.offTime = offTime.offTimeEnd
        saveCurrentiBeaconStateToUserDefaults(currentiBeaconState: state)

    case let SetMaxOnTimeStartAction as SetiBEaconMaxOnTimeStartAction:
        state.maxOnTimeStart = SetMaxOnTimeStartAction.maxOnTimeStart
        saveCurrentiBeaconStateToUserDefaults(currentiBeaconState: state)
        
    case _ as DisableCurrrentiBeaconAction:
        state.isIBeaconRangingEnabled = false
        
        saveCurrentiBeaconStateToUserDefaults(currentiBeaconState: state)
        
    default:
        break
    }

    return state
}

func getCurrentiBeaconStateFromUserDefaults () -> CurrentBeaconState? {
    let userDefaults = UserDefaults.standard

    var currentIBeaconState:CurrentBeaconState?
    
    if let iBeaconDictionary = userDefaults.dictionary(forKey: CurrentBeaconReducerConstants.userDefaultsCurrentiBeaconKey){
        
        if currentIBeaconState == nil {
            currentIBeaconState = CurrentBeaconState(isIBeaconEnabled: false, isInForeground: nil, maxRuntime: nil, minOffTime: nil, regions: [], filterWindowSize: nil, filterMaxObservations: nil, filterExcludeRegions: [], offTime: nil, maxOnTimeStart: nil, eddystoneScanEnabled: false)
        }
        
        currentIBeaconState?.isIBeaconRangingEnabled = iBeaconDictionary["isIBeaconRangingEnabled"] as? Bool
        currentIBeaconState?.maxRuntime = iBeaconDictionary["maxRuntime"] as? UInt64
        currentIBeaconState?.minOffTime = iBeaconDictionary["minOffTime"] as? UInt64
        currentIBeaconState?.filterWindowSize = iBeaconDictionary["filterWindowSize"] as? UInt64
        currentIBeaconState?.filterMaxObservations = iBeaconDictionary["filterMaxObservations"] as? UInt32
        currentIBeaconState?.isEddystoneScanningEnabled = iBeaconDictionary["isEddystoneScanningEnabled"] as? Bool
        currentIBeaconState?.isInForeground = iBeaconDictionary["isInForeground"] as? Bool
        
        if let offTime = iBeaconDictionary["offTime"] as? UInt64 {
            currentIBeaconState?.offTime = Date(timeIntervalSince1970: TimeInterval(offTime))
        }

        if let maxOnTimeStart = iBeaconDictionary["maxOnTimeStart"] as? UInt64 {
            currentIBeaconState?.maxOnTimeStart = Date(timeIntervalSince1970: TimeInterval(maxOnTimeStart))
        }
    }

    if let decoded = userDefaults.object(forKey: CurrentBeaconReducerConstants.userDefaultsCurrentiBeaconRegionsKey) as? Data {

        if currentIBeaconState == nil {
            currentIBeaconState = CurrentBeaconState(isIBeaconEnabled: false, isInForeground: nil, maxRuntime: nil, minOffTime: nil, regions: [], filterWindowSize: nil, filterMaxObservations: nil, filterExcludeRegions: [], offTime: nil, maxOnTimeStart: nil, eddystoneScanEnabled: false)
        }
        
        let decodediBeaconRegions = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [CLBeaconRegion] ?? [CLBeaconRegion]()
        
        currentIBeaconState?.regions = decodediBeaconRegions
    }

    if let decoded = userDefaults.object(forKey: CurrentBeaconReducerConstants.userDefaultsCurrentiBeaconFilterRegionsKey) as? Data {

        if currentIBeaconState == nil {
            currentIBeaconState = CurrentBeaconState(isIBeaconEnabled: false, isInForeground: nil, maxRuntime: nil, minOffTime: nil, regions: [], filterWindowSize: nil, filterMaxObservations: nil, filterExcludeRegions: [], offTime: nil, maxOnTimeStart: nil, eddystoneScanEnabled: false)
        }
        
        let decodediBeaconFilteredRegions = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [CLBeaconRegion] ?? [CLBeaconRegion]()
        
        currentIBeaconState?.filterExcludeRegions = decodediBeaconFilteredRegions
    }

    return currentIBeaconState
}

public func saveCurrentiBeaconStateToUserDefaults (currentiBeaconState: CurrentBeaconState?) {
    
    guard let currentiBeaconState = currentiBeaconState else {
        return
    }
    
    let userDefaults = UserDefaults.standard
    
    var dictionary = [String:Int64]()
    
    if let maxRuntime = currentiBeaconState.maxRuntime {
        dictionary["maxRuntime"] = Int64(maxRuntime)
    }
    
    if let minOffTime = currentiBeaconState.minOffTime {
        dictionary["minOffTime"] = Int64(minOffTime)
    }
    
    if let filterWindowSize = currentiBeaconState.filterWindowSize {
        dictionary["filterWindowSize"] = Int64(filterWindowSize)
    }
    
    if let filterMaxObservations = currentiBeaconState.filterMaxObservations {
        dictionary["filterMaxObservations"] = Int64(filterMaxObservations)
    }
    
    if let offTime = currentiBeaconState.offTime {
        dictionary["offTime"] = Int64(offTime.timeIntervalSince1970)
    }
    
    if let isInForeground = currentiBeaconState.isInForeground {
        dictionary["isInForeground"] = isInForeground ? 1 : 0
    }

    if let isIBeaconEnabled = currentiBeaconState.isIBeaconRangingEnabled {
        dictionary["isIBeaconRangingEnabled"] = isIBeaconEnabled ? 1 : 0
    }
    
    if let isEddystoneBeaconEnabled = currentiBeaconState.isEddystoneScanningEnabled {
        dictionary["isEddystoneScanningEnabled"] = isEddystoneBeaconEnabled ? 1 : 0
    }

    if let maxOnTimeStart = currentiBeaconState.maxOnTimeStart {
        dictionary["maxOnTimeStart"] = Int64(maxOnTimeStart.timeIntervalSince1970)
    }

    userDefaults.set(dictionary, forKey: CurrentBeaconReducerConstants.userDefaultsCurrentiBeaconKey)
    
    let encodedRegions = NSKeyedArchiver.archivedData(withRootObject: currentiBeaconState.regions)

    userDefaults.set(encodedRegions, forKey: CurrentBeaconReducerConstants.userDefaultsCurrentiBeaconRegionsKey)

    let encodedFilterRegions = NSKeyedArchiver.archivedData(withRootObject: currentiBeaconState.filterExcludeRegions)
    
    userDefaults.set(encodedFilterRegions, forKey: CurrentBeaconReducerConstants.userDefaultsCurrentiBeaconFilterRegionsKey)
    
    userDefaults.synchronize()

}
