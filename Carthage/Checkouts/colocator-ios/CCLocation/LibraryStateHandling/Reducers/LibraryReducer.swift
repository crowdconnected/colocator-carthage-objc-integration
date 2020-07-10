//
//  WebSocketReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 18/06/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

func libraryReducer(action: Action, state: LibraryState?) -> LibraryState {
    var state = LibraryState (
        lifecycleState: lifecycleReducer(action: action, state: state?.lifecycleState),
        ccRequestMessagingState: ccRequestMessagingReducer(action: action, state: state?.ccRequestMessagingState),
        locationSettingsState: locationSettingsReducer(action: action, state: state?.locationSettingsState),
        batteryLevelState: batteryLevelReducer(action: action, state: state?.batteryLevelState),
        intertialState: inertialReducer(action: action, state: state?.intertialState),
        contactState: contactReducer(action: action, state: state?.contactState)
    )
    
    switch action {
    case _ as ReSwiftInit:
        break
        
    case let setForegroundGEOAction as EnableForegroundGEOAction:
        
        if (state.lifecycleState.lifecycleState == LifeCycle.foreground){
            
            state.locationSettingsState.currentLocationState?.currentGEOState?.isStandardGEOEnabled = true
            state.locationSettingsState.currentLocationState?.currentGEOState?.activityType = setForegroundGEOAction.activityType
            state.locationSettingsState.currentLocationState?.currentGEOState?.maxRuntime = setForegroundGEOAction.maxRuntime
            state.locationSettingsState.currentLocationState?.currentGEOState?.minOffTime = setForegroundGEOAction.minOffTime
            state.locationSettingsState.currentLocationState?.currentGEOState?.desiredAccuracy = setForegroundGEOAction.desiredAccuracy
            state.locationSettingsState.currentLocationState?.currentGEOState?.distanceFilter = setForegroundGEOAction.distanceFilter
            state.locationSettingsState.currentLocationState?.currentGEOState?.pausesUpdates = setForegroundGEOAction.pausesUpdates
            
            saveCurrentGEOSateToUserDefaults(geoState: state.locationSettingsState.currentLocationState?.currentGEOState)
        }
        
    case let setBackgroundGEOAction as EnableBackgroundGEOAction:
        
        if (state.lifecycleState.lifecycleState == LifeCycle.background){
            
            state.locationSettingsState.currentLocationState?.currentGEOState?.isStandardGEOEnabled = true
            state.locationSettingsState.currentLocationState?.currentGEOState?.activityType = setBackgroundGEOAction.activityType
            state.locationSettingsState.currentLocationState?.currentGEOState?.maxRuntime = setBackgroundGEOAction.maxRuntime
            state.locationSettingsState.currentLocationState?.currentGEOState?.minOffTime = setBackgroundGEOAction.minOffTime
            state.locationSettingsState.currentLocationState?.currentGEOState?.desiredAccuracy = setBackgroundGEOAction.desiredAccuracy
            state.locationSettingsState.currentLocationState?.currentGEOState?.distanceFilter = setBackgroundGEOAction.distanceFilter
            state.locationSettingsState.currentLocationState?.currentGEOState?.pausesUpdates = setBackgroundGEOAction.pausesUpdates
            saveCurrentGEOSateToUserDefaults(geoState: state.locationSettingsState.currentLocationState?.currentGEOState)
        }
        
    case let enableGeofencesMonitoringAction as EnableGeofencesMonitoringAction:
        state.locationSettingsState.currentLocationState?.currentGeofencesMonitoringState?.monitoringGeofences = enableGeofencesMonitoringAction.geofences!
        
    case let enableiBeaconMonitoringAction as EnableCurrentiBeaconMonitoringAction:
        state.locationSettingsState.currentLocationState?.currentiBeaconMonitoringState?.monitoringRegions = enableiBeaconMonitoringAction.monitoringRegions!
        
    case let enableForegroundiBeaconAction as EnableForegroundBeaconAction:

        if (state.lifecycleState.lifecycleState == LifeCycle.foreground){
            state.locationSettingsState.currentLocationState?.currentBeaconState?.maxRuntime = enableForegroundiBeaconAction.maxRuntime
            state.locationSettingsState.currentLocationState?.currentBeaconState?.minOffTime = enableForegroundiBeaconAction.minOffTime
            state.locationSettingsState.currentLocationState?.currentBeaconState?.regions = enableForegroundiBeaconAction.regions
            state.locationSettingsState.currentLocationState?.currentBeaconState?.filterWindowSize = enableForegroundiBeaconAction.filterWindowSize
            state.locationSettingsState.currentLocationState?.currentBeaconState?.filterMaxObservations = enableForegroundiBeaconAction.filterMaxObservations
            state.locationSettingsState.currentLocationState?.currentBeaconState?.filterExcludeRegions = enableForegroundiBeaconAction.filterExcludeRegions
            state.locationSettingsState.currentLocationState?.currentBeaconState?.isIBeaconRangingEnabled = enableForegroundiBeaconAction.isIBeaconRangingEnabled
            state.locationSettingsState.currentLocationState?.currentBeaconState?.isEddystoneScanningEnabled = enableForegroundiBeaconAction.isEddystoneScanningEnabled
            
            saveCurrentiBeaconStateToUserDefaults(currentiBeaconState: state.locationSettingsState.currentLocationState?.currentBeaconState)
        }

    case let enableBackgroundiBeaconAction as EnableBackgroundiBeaconAction:
        
        if (state.lifecycleState.lifecycleState == LifeCycle.background){
            state.locationSettingsState.currentLocationState?.currentBeaconState?.maxRuntime = enableBackgroundiBeaconAction.maxRuntime
            state.locationSettingsState.currentLocationState?.currentBeaconState?.minOffTime = enableBackgroundiBeaconAction.minOffTime
            state.locationSettingsState.currentLocationState?.currentBeaconState?.regions = enableBackgroundiBeaconAction.regions
            state.locationSettingsState.currentLocationState?.currentBeaconState?.filterWindowSize = enableBackgroundiBeaconAction.filterWindowSize
            state.locationSettingsState.currentLocationState?.currentBeaconState?.filterMaxObservations = enableBackgroundiBeaconAction.filterMaxObservations
            state.locationSettingsState.currentLocationState?.currentBeaconState?.filterExcludeRegions = enableBackgroundiBeaconAction.filterExcludeRegions
            state.locationSettingsState.currentLocationState?.currentBeaconState?.isIBeaconRangingEnabled = enableBackgroundiBeaconAction.isIBeaconRangingEnabled
            state.locationSettingsState.currentLocationState?.currentBeaconState?.isEddystoneScanningEnabled = enableBackgroundiBeaconAction.isEddystoneScanningEnabled

            saveCurrentiBeaconStateToUserDefaults(currentiBeaconState: state.locationSettingsState.currentLocationState?.currentBeaconState)
        }
        
    default:
        break
    }
    
    return state
}

