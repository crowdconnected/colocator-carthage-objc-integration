//
//  ForegroundiBeaconReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 01/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift
import CoreLocation

private struct ForegroundBeaconReducerConstants {
    static let userDefaultsForegroundiBeaconKey = "fGiBeaconKey"
    static let userDefaultsForegroundiBeaconRegionsKey = "fGiBeaconRegionsKey"
    static let userDefaultsForegroundiBeaconFilterRegionsKey = "fGiBeaconFilterRegionsKey"
}

private typealias C = ForegroundBeaconReducerConstants

func foregroundBeaconReducer(action: Action, state: BeaconState?) -> BeaconState {
    var fGiBeaconState = BeaconState.emptyInit()
    
    if let loadedfGiBeaconState = getForegroundiBeaconStateFromUserDefaults() {
        fGiBeaconState = loadedfGiBeaconState
    }
    
    var state = state ?? fGiBeaconState
    
    switch action {
    case let enableForegroundBeaconAction as EnableForegroundBeaconAction:
        
        state.maxRuntime = enableForegroundBeaconAction.maxRuntime
        state.minOffTime = enableForegroundBeaconAction.minOffTime
        
        state.regions = enableForegroundBeaconAction.regions
        
        state.filterWindowSize = enableForegroundBeaconAction.filterWindowSize
        state.filterMaxObservations = enableForegroundBeaconAction.filterMaxObservations
        
        state.filterExcludeRegions = enableForegroundBeaconAction.filterExcludeRegions
        
        state.isEddystoneScanningEnabled = enableForegroundBeaconAction.isEddystoneScanningEnabled
        
        state.isIBeaconRangingEnabled = enableForegroundBeaconAction.isIBeaconRangingEnabled

        saveForegroundiBeaconStateToUserDefaults(iBeaconState: state)
        
    case _ as DisableForegroundiBeaconAction:
        state.isIBeaconRangingEnabled = false
        
        saveForegroundiBeaconStateToUserDefaults(iBeaconState: state)
        
    default:
        break
    }
    return state
}

private func getForegroundiBeaconStateFromUserDefaults () -> BeaconState? {
    let userDefaults = UserDefaults.standard
    
    var fgIBeaconState:BeaconState?
    
    if let iBeaconDictionary = userDefaults.dictionary(forKey: C.userDefaultsForegroundiBeaconKey) {
        if fgIBeaconState == nil {
            fgIBeaconState = BeaconState.emptyInit()
        }
        
        fgIBeaconState?.maxRuntime = iBeaconDictionary["maxRuntime"] as? UInt64
        fgIBeaconState?.minOffTime = iBeaconDictionary["minOffTime"] as? UInt64
        fgIBeaconState?.filterWindowSize = iBeaconDictionary["filterWindowSize"] as? UInt64
        fgIBeaconState?.filterMaxObservations = iBeaconDictionary["filterMaxObservations"] as? UInt32
        fgIBeaconState?.isEddystoneScanningEnabled = iBeaconDictionary["isEddystoneScanningEnabled"] as? Bool
        fgIBeaconState?.isIBeaconRangingEnabled = iBeaconDictionary["isIBeaconRangingEnabled"] as? Bool
    }
    
    if let decoded = userDefaults.object(forKey: C.userDefaultsForegroundiBeaconRegionsKey) as? Data {
        if fgIBeaconState == nil {
            fgIBeaconState = BeaconState.emptyInit()
        }
        
        let decodediBeaconRegions = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [CLBeaconRegion]
                                    ?? [CLBeaconRegion]()
        
        fgIBeaconState?.regions = decodediBeaconRegions
    }
    
    if let decoded = userDefaults.object(forKey: C.userDefaultsForegroundiBeaconFilterRegionsKey) as? Data {
        if fgIBeaconState == nil {
            fgIBeaconState = BeaconState.emptyInit()
        }
        
        let decodediBeaconFilteredRegions = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [CLBeaconRegion]
                                            ?? [CLBeaconRegion]()
        
        fgIBeaconState?.filterExcludeRegions = decodediBeaconFilteredRegions
    }
    
    return fgIBeaconState
}

private func saveForegroundiBeaconStateToUserDefaults(iBeaconState: BeaconState?) {
    guard let iBeaconState = iBeaconState else {
        return
    }
    
    let userDefaults = UserDefaults.standard
    
    let dictionary = setupCommonBeaconDictionary(forBeaconState: iBeaconState)
    
    userDefaults.set(dictionary, forKey: C.userDefaultsForegroundiBeaconKey)
    
    let encodedRegions = NSKeyedArchiver.archivedData(withRootObject: iBeaconState.regions)
    
    userDefaults.set(encodedRegions, forKey: C.userDefaultsForegroundiBeaconRegionsKey)
    
    let encodedFilterRegions = NSKeyedArchiver.archivedData(withRootObject: iBeaconState.filterExcludeRegions)
    
    userDefaults.set(encodedFilterRegions, forKey: C.userDefaultsForegroundiBeaconFilterRegionsKey)
    
    userDefaults.synchronize()
    
}
