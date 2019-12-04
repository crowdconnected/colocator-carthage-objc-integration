//
//  CCRquestMessagingReducers.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 06/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

func ccRequestMessagingReducer(action: Action, state: CCRequestMessagingState?) -> CCRequestMessagingState {
    
    var state = CCRequestMessagingState (
        webSocketState: webSocketReducer(action: action, state: state?.webSocketState),
        radiosilenceTimerState: timerReducer(action: action, state: state?.radiosilenceTimerState),
        libraryTimeState: libraryTimeReducer(action: action, state: state?.libraryTimeState),
        capabilityState: capabilityReducer(action: action, state: state?.capabilityState)
    )
   
    switch action {
    case _ as ReSwiftInit:
        break

    // Handling timer events
    case let radioSilenceTimerAction as TimeBetweenSendsTimerReceivedAction:
        if let timeInterval = radioSilenceTimerAction.timeInMilliseconds {
            updateRadioSilenceTimeInterval(forState: &state, withValue: timeInterval)
        } else {
            resetAndInvalidateRadioSilenceTimer(forState: &state)
        }
                
        saveTimerStateToUserDefaults(timerState: state.radiosilenceTimerState)
        break
        
    case let timerRunningAction as TimerRunningAction:
        state.radiosilenceTimerState?.timer = CCTimer.running

        // Only set a new timer when the start time interval is nil, this is an intentional case for the starttimer
        if timerRunningAction.startTimeInterval != nil {
            state.radiosilenceTimerState?.startTimeInterval = timerRunningAction.startTimeInterval
        } else {
            state.radiosilenceTimerState?.startTimeInterval = nil
        }
        break
        
    case _ as TimerStoppedAction:
        state.radiosilenceTimerState?.timer = CCTimer.stopped
        break
        
    case _ as ScheduleSilencePeriodTimerAction:
        
        // Only schedule if we actually have a time interval available
        if state.radiosilenceTimerState?.timeInterval != nil {
            state.radiosilenceTimerState?.timer = CCTimer.schedule
        }
        break
        
    default:
        break
    }

    return state
}

func updateRadioSilenceTimeInterval(forState state: inout CCRequestMessagingState, withValue newValue: UInt64) {
    
    if state.radiosilenceTimerState!.timeInterval != newValue {
        
        state.radiosilenceTimerState!.timeInterval = newValue
        state.radiosilenceTimerState!.timer = CCTimer.invalidate
        
        if state.radiosilenceTimerState!.timeInterval != nil {
            state.radiosilenceTimerState!.timer = CCTimer.schedule
        }
    }
}

func resetAndInvalidateRadioSilenceTimer(forState state: inout CCRequestMessagingState) {
    
    state.radiosilenceTimerState?.timer = CCTimer.invalidate
    state.radiosilenceTimerState?.timeInterval = nil
    state.radiosilenceTimerState?.startTimeInterval = nil
}
