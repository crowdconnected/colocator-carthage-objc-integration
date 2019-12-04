//
//  TimerAction.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

struct TimeBetweenSendsTimerReceivedAction: Action {
    let timeInMilliseconds: UInt64?
}

struct ScheduleSilencePeriodTimerAction: Action {}

struct TimerRunningAction : Action {
    let startTimeInterval: TimeInterval?
}

struct TimerStoppedAction : Action {}
