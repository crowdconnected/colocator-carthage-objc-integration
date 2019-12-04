//
//  BackgroundiBeaconReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 01/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

private struct BackgroundiBeaconReducerConstants {
    static let userDefaultsBackgroundiBeaconKey = "bGiBeaconKey"
    static let userDefaultsBackgroundiBeaconRegionsKey = "bGiBeaconRegionsKey"
    static let userDefaultsBackgroundiBeaconFilterRegionsKey = "bGiBeaconFilterRegionsKey"
}

private typealias C = BackgroundiBeaconReducerConstants

func backgroundiBeaconReducer(action: Action, state: BeaconState?) -> BeaconState {
    var bGiBeaconState = BeaconState.emptyInit()
    
    if let loadedbGiBeaconState = getBackgroundiBeaconStateFromUserDefaults() {
        bGiBeaconState = loadedbGiBeaconState
    }
    
    var state = state ?? bGiBeaconState
    
    switch action {
    case let enableBackgroundiBeaconAction as EnableBackgroundiBeaconAction:
        
        state.maxRuntime = enableBackgroundiBeaconAction.maxRuntime
        state.minOffTime = enableBackgroundiBeaconAction.minOffTime
       
        state.regions = enableBackgroundiBeaconAction.regions
        
        state.filterWindowSize = enableBackgroundiBeaconAction.filterWindowSize
        state.filterMaxObservations = enableBackgroundiBeaconAction.filterMaxObservations
        
        state.filterExcludeRegions = enableBackgroundiBeaconAction.filterExcludeRegions

        state.isEddystoneScanningEnabled = enableBackgroundiBeaconAction.isEddystoneScanningEnabled
        
        state.isIBeaconRangingEnabled = enableBackgroundiBeaconAction.isIBeaconRangingEnabled
        
        saveBackgroundiBeaconStateToUserDefaults(iBeaconState: state)
        
    case _ as DisableBackgroundiBeaconAction:
        state.isIBeaconRangingEnabled = false

        saveBackgroundiBeaconStateToUserDefaults(iBeaconState: state)
        
    default:
        break
    }
    return state
}

private func getBackgroundiBeaconStateFromUserDefaults() -> BeaconState? {
    let userDefaults = UserDefaults.standard
    
    var bGIBeaconState: BeaconState?
    
    if let iBeaconDictionary = userDefaults.dictionary(forKey: C.userDefaultsBackgroundiBeaconKey) {
        
        if bGIBeaconState == nil {
            bGIBeaconState = BeaconState.emptyInit()
        }
        
        bGIBeaconState?.maxRuntime = iBeaconDictionary["maxRuntime"] as? UInt64
        bGIBeaconState?.minOffTime = iBeaconDictionary["minOffTime"] as? UInt64
        bGIBeaconState?.filterWindowSize = iBeaconDictionary["filterWindowSize"] as? UInt64
        bGIBeaconState?.filterMaxObservations = iBeaconDictionary["filterMaxObservations"] as? UInt32
        bGIBeaconState?.isEddystoneScanningEnabled = iBeaconDictionary["isEddystoneScanningEnabled"] as? Bool
        bGIBeaconState?.isIBeaconRangingEnabled = iBeaconDictionary["isIBeaconRangingEnabled"] as? Bool
    }
    
    if let decoded = userDefaults.object(forKey: C.userDefaultsBackgroundiBeaconRegionsKey) as? Data {
        if bGIBeaconState == nil {
            bGIBeaconState = BeaconState.emptyInit()
        }
        
        let decodediBeaconRegions = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [CLBeaconRegion]
                                    ?? [CLBeaconRegion] ()
        
        bGIBeaconState?.regions = decodediBeaconRegions
    }
    
    if let decoded = userDefaults.object(forKey: C.userDefaultsBackgroundiBeaconFilterRegionsKey) as? Data {
        if bGIBeaconState == nil {
            bGIBeaconState = BeaconState.emptyInit()
        }
        
        let decodediBeaconFilteredRegions = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [CLBeaconRegion]
                                            ?? [CLBeaconRegion] ()
        
        bGIBeaconState?.filterExcludeRegions = decodediBeaconFilteredRegions
    }
    
    return bGIBeaconState
}

private func saveBackgroundiBeaconStateToUserDefaults(iBeaconState: BeaconState?) {
    guard let iBeaconState = iBeaconState else {
        return
    }
    
    let userDefaults = UserDefaults.standard
    
    let dictionary = setupCommonBeaconDictionary(forBeaconState: iBeaconState)
  
    userDefaults.set(dictionary, forKey: C.userDefaultsBackgroundiBeaconKey)
    
    let encodedRegions = NSKeyedArchiver.archivedData(withRootObject: iBeaconState.regions)
    
    userDefaults.set(encodedRegions, forKey: C.userDefaultsBackgroundiBeaconRegionsKey)
    
    let encodedFilterRegions = NSKeyedArchiver.archivedData(withRootObject: iBeaconState.filterExcludeRegions)
    
    userDefaults.set(encodedFilterRegions, forKey: C.userDefaultsBackgroundiBeaconFilterRegionsKey)
    
    userDefaults.synchronize()
}

func setupCommonBeaconDictionary(forBeaconState iBeaconState: BeaconState) -> Dictionary<String, Int64> {
    var dictionary = [String:Int64]()
    
    if let maxRuntime = iBeaconState.maxRuntime {
        dictionary["maxRuntime"] = Int64(maxRuntime)
    }
    
    if let minOffTime = iBeaconState.minOffTime {
        dictionary["minOffTime"] = Int64(minOffTime)
    }
    
    if let filterWindowSize = iBeaconState.filterWindowSize {
        dictionary["filterWindowSize"] = Int64(filterWindowSize)
    }
    
    if let filterMaxObservations = iBeaconState.filterMaxObservations {
        dictionary["filterMaxObservations"] = Int64(filterMaxObservations)
    }
    
    if let eddystoneScan = iBeaconState.isEddystoneScanningEnabled {
        dictionary["isEddystoneScanningEnabled"] = eddystoneScan ? 1 : 0
    }
    
    if let iBeaconRangingEnabled = iBeaconState.isIBeaconRangingEnabled {
        dictionary["isIBeaconRangingEnabled"] = iBeaconRangingEnabled ? 1 : 0
    }
    
    return dictionary
}
