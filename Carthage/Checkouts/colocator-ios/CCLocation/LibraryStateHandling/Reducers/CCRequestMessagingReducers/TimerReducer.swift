//
//  TimerReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

struct TimerReducerConstants {
    static let userDefaultsTimerReducerKey = "timerReducerKey"
    static let timerInterval = "timerInterval"
    static let timer = "timer"
    static let startTimeInterval = "startTimeInterval"
}

private typealias T = TimerReducerConstants

func timerReducer (action: Action, state: TimerState?) -> TimerState {
    
    var timerState = TimerState(timer: CCTimer.stopped, timeInterval: nil, startTimeInterval: nil)
    
    if let loadedTimerState = getTimerStateFromUserDefaults () {
        timerState = loadedTimerState
    }
    
    let state = state ?? timerState
    
    return state
}

private func getTimerStateFromUserDefaults () -> TimerState? {
    
    let userDefaults = UserDefaults.standard
    let dictionary = userDefaults.dictionary(forKey: T.userDefaultsTimerReducerKey)
    
    if dictionary != nil {
        
        var timer:CCTimer?
        
        if let timerRawValue = dictionary?[T.timer] {
            timer = CCTimer(rawValue: timerRawValue as! UInt)
        }
        
        return TimerState(timer: timer, timeInterval: dictionary?[T.timerInterval] as? UInt64, startTimeInterval: dictionary?[T.startTimeInterval] as? Double)
    } else {
        return nil
    }
}

public func saveTimerStateToUserDefaults (timerState: TimerState?) {
    
    guard let timerState = timerState else {
        return
    }
    
    let userDefaults = UserDefaults.standard
    
    var dictionary = [String:Double]()
    
    if let timer = timerState.timer {
        dictionary[T.timer] = Double(timer.rawValue)
    }
    
    if let timeInterval = timerState.timeInterval {
        dictionary[T.timerInterval] = Double(timeInterval)
    }
    
    if let startTimeInterval = timerState.startTimeInterval {
        dictionary[T.startTimeInterval] = startTimeInterval
    }
    
    userDefaults.set(dictionary, forKey: T.userDefaultsTimerReducerKey)
}
