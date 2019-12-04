//
//  LocationSettingsReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

func locationSettingsReducer (action: Action, state: LocationSettingsState?) -> LocationSettingsState {
    var state = LocationSettingsState (
        currentLocationState: currentLocationReducer(action: action, state: state?.currentLocationState),
        foregroundLocationState: foregroundLocationReducer(action: action, state: state?.foregroundLocationState),
        backgroundLocationState: backgroundLocationReducer(action: action, state: state?.backgroundLocationState)
    )
    
    switch action {
    case let lifeCycleAction as LifeCycleAction:
        if lifeCycleAction.lifecycleState == LifeCycle.foreground {
            updateForegroundLocationState(state: &state)
        }
        if lifeCycleAction.lifecycleState == LifeCycle.background {
            updateBackgroundLocationState(state: &state)
        }
        saveCurrentGeoAndBeaconStatesInUserDefaults(state: state)
    default:
        break
    }
    
    return state
}

func updateForegroundLocationState(state: inout LocationSettingsState) {
    state.currentLocationState?.currentGEOState?.isStandardGEOEnabled = false
    
    if let foregroundLocationStateUnwrapped = state.foregroundLocationState {
        if let foregroundGEOStateUnwrapped = foregroundLocationStateUnwrapped.foregroundGEOState,
            let isStandardGEOEnabled = foregroundGEOStateUnwrapped.fgGEOEnabled,
            isStandardGEOEnabled {
            updateStateWithForegroundGEOSettings(newGEOstate: foregroundGEOStateUnwrapped, state: &state)
        }
        if let foregroundBeaconStateUnwrapped = foregroundLocationStateUnwrapped.foregroundBeaconState {
            updateStateWithForegroundBeaconSettings(newBeaconState: foregroundBeaconStateUnwrapped, state: &state)
        }
    }
}

func updateBackgroundLocationState(state: inout LocationSettingsState) {
    state.currentLocationState?.currentGEOState?.isStandardGEOEnabled = false
    
    if let backgroundLocationStateUnwrapped = state.backgroundLocationState {
        if let backgroundGEOStateUnwrapped = backgroundLocationStateUnwrapped.backgroundGEOState,
            let isStandardGEOEnabled = backgroundGEOStateUnwrapped.bgGEOEnabled,
            isStandardGEOEnabled {
            updateStateWithBackgroundGEOSettings(newGEOstate: backgroundGEOStateUnwrapped, state: &state)
        }
        if let backgroundBeaconStateUnwrapped = backgroundLocationStateUnwrapped.backgroundBeaconState {
            updateStateWithBackgroundBeaconSettings(newBeaconState: backgroundBeaconStateUnwrapped, state: &state)
        }
    }
}

func updateStateWithForegroundGEOSettings(newGEOstate: ForegroundGEOState, state: inout LocationSettingsState) {
    state.currentLocationState?.currentGEOState?.activityType = newGEOstate.fgActivityType
    state.currentLocationState?.currentGEOState?.maxRuntime = newGEOstate.fgMaxRuntime
    state.currentLocationState?.currentGEOState?.minOffTime = newGEOstate.fgMinOffTime
    state.currentLocationState?.currentGEOState?.desiredAccuracy = newGEOstate.fgDesiredAccuracy
    state.currentLocationState?.currentGEOState?.distanceFilter = newGEOstate.fgDistanceFilter
    state.currentLocationState?.currentGEOState?.pausesUpdates = newGEOstate.fgPausesUpdates
    state.currentLocationState?.currentGEOState?.isStandardGEOEnabled = true
    state.currentLocationState?.currentGEOState?.isInForeground = true
}

func updateStateWithForegroundBeaconSettings(newBeaconState: BeaconState, state: inout LocationSettingsState) {
    state.currentLocationState?.currentBeaconState?.isIBeaconRangingEnabled = newBeaconState.isIBeaconRangingEnabled
    state.currentLocationState?.currentBeaconState?.isEddystoneScanningEnabled = newBeaconState.isEddystoneScanningEnabled
    state.currentLocationState?.currentBeaconState?.maxRuntime = newBeaconState.maxRuntime
    state.currentLocationState?.currentBeaconState?.minOffTime = newBeaconState.minOffTime
    
    if let regions = state.foregroundLocationState?.foregroundBeaconState?.regions {
        state.currentLocationState?.currentBeaconState?.regions = regions
    }
    
    state.currentLocationState?.currentBeaconState?.filterWindowSize = newBeaconState.filterWindowSize
    state.currentLocationState?.currentBeaconState?.filterMaxObservations = newBeaconState.filterMaxObservations
    
    if let filterExcludeRegions = state.foregroundLocationState?.foregroundBeaconState?.filterExcludeRegions {
        state.currentLocationState?.currentBeaconState?.filterExcludeRegions = filterExcludeRegions
    }
    state.currentLocationState?.currentBeaconState?.isInForeground = true
}

func updateStateWithBackgroundGEOSettings(newGEOstate: BackgroundGEOState, state: inout LocationSettingsState) {
    state.currentLocationState?.currentGEOState?.activityType = newGEOstate.bgActivityType
    state.currentLocationState?.currentGEOState?.maxRuntime = newGEOstate.bgMaxRuntime
    state.currentLocationState?.currentGEOState?.minOffTime = newGEOstate.bgMinOffTime
    state.currentLocationState?.currentGEOState?.desiredAccuracy = newGEOstate.bgDesiredAccuracy
    state.currentLocationState?.currentGEOState?.distanceFilter = newGEOstate.bgDistanceFilter
    state.currentLocationState?.currentGEOState?.pausesUpdates = newGEOstate.bgPausesUpdates
    state.currentLocationState?.currentGEOState?.isStandardGEOEnabled = true
    state.currentLocationState?.currentGEOState?.isInForeground = false
}

func updateStateWithBackgroundBeaconSettings(newBeaconState: BeaconState, state: inout LocationSettingsState) {
    state.currentLocationState?.currentBeaconState?.isIBeaconRangingEnabled = newBeaconState.isIBeaconRangingEnabled
    state.currentLocationState?.currentBeaconState?.isEddystoneScanningEnabled = newBeaconState.isEddystoneScanningEnabled
    state.currentLocationState?.currentBeaconState?.maxRuntime = newBeaconState.maxRuntime
    state.currentLocationState?.currentBeaconState?.minOffTime = newBeaconState.minOffTime
    
    if let regions = state.backgroundLocationState?.backgroundBeaconState?.regions {
        state.currentLocationState?.currentBeaconState?.regions = regions
    }
    
    state.currentLocationState?.currentBeaconState?.filterWindowSize = newBeaconState.filterWindowSize
    state.currentLocationState?.currentBeaconState?.filterMaxObservations = newBeaconState.filterMaxObservations
    
    if let filterExcludeRegions = state.backgroundLocationState?.backgroundBeaconState?.filterExcludeRegions {
        state.currentLocationState?.currentBeaconState?.filterExcludeRegions = filterExcludeRegions
    }
    state.currentLocationState?.currentBeaconState?.isInForeground = false
}

func saveCurrentGeoAndBeaconStatesInUserDefaults(state: LocationSettingsState) {
    saveCurrentGEOSateToUserDefaults(geoState: state.currentLocationState?.currentGEOState)
    saveCurrentiBeaconStateToUserDefaults(currentiBeaconState: state.currentLocationState?.currentBeaconState)
}
