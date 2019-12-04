//
//  TimerState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

enum CCTimer : UInt {
    case running = 1
    case stopped = 2
    case invalidate = 3
    case schedule = 4
}

public struct TimerState: StateType, AutoEquatable {
    var timer: CCTimer?
    var timeInterval : UInt64?
    var startTimeInterval: TimeInterval?
    
    init(timer:CCTimer?,
         timeInterval:UInt64?,
         startTimeInterval:TimeInterval?) {

        self.timer = timer
        self.timeInterval = timeInterval
        self.startTimeInterval = startTimeInterval
    }
}

