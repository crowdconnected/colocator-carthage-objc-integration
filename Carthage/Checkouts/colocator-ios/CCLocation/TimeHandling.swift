//
//  TimeHandling.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 09/03/2018.
//  Copyright © 2018 Crowd Connected. All rights reserved.
//

import Foundation
import ReSwift
import TrueTime

public protocol TimeHandlingDelegate: class {
    func newTrueTimeAvailable(trueTime: Date, timeIntervalSinceBootTime: TimeInterval, systemTime: Date, lastRebootTime: Date)
}

class TimeHandling {

    public weak var delegate: TimeHandlingDelegate?

    let trueTimeClient: TrueTimeClient
    var isFetchingTrueTime: Bool = false

    init() {
        trueTimeClient = TrueTimeClient.sharedInstance
        trueTimeClient.start()
    }
    
    public static let shared: TimeHandling = {
        let instance = TimeHandling()
        return instance
    }()
    
    static func getCurrentTimePeriodSince1970(stateStore: Store<LibraryState>) -> TimeInterval? {
        let currentTime = timeIntervalSinceBoot()
        let libraryTimeState = stateStore.state.ccRequestMessagingState.libraryTimeState
        
        if let bootTimeAtLastTrueTime = libraryTimeState?.bootTimeIntervalAtLastTrueTime,
            let timeSince1970 = libraryTimeState?.lastTrueTime?.timeIntervalSince1970 {
            
            let timeIntervalPast = currentTime - bootTimeAtLastTrueTime
            let currentTimePeriodSince1970 = timeSince1970 + timeIntervalPast
            return currentTimePeriodSince1970
        }
        return nil
    }
    
    static func timeIntervalSinceBoot() -> TimeInterval {
        let timeIntervalSinceBoot = ProcessInfo.processInfo.systemUptime
        return timeIntervalSinceBoot
    }
    
    func fetchTrueTime() {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let self = self else {
                return
            }
            self.fetchTrueTimeInBackground()
        }
    }
    
    func fetchTrueTimeInBackground() {
        guard !isFetchingTrueTime else {
            return
        }
        isFetchingTrueTime = true
            
        trueTimeClient.fetchIfNeeded(success: { referenceTime in
            NSLog("[Colocator] True time: " + referenceTime.now().description)
            
            let lastRebootTime = referenceTime.now().addingTimeInterval(TimeHandling.timeIntervalSinceBoot())
            
            self.delegate?.newTrueTimeAvailable(trueTime: referenceTime.now(),
                                                timeIntervalSinceBootTime: TimeHandling.timeIntervalSinceBoot(),
                                                systemTime: Date(),
                                                lastRebootTime: lastRebootTime)
                
            self.isFetchingTrueTime = false
        }, failure: { (error) in
            NSLog("[Colocator] Truetime error! \(error.description)")
            self.isFetchingTrueTime = false
        })
    }

    func isRebootTimeSame (stateStore: Store<LibraryState>, ccSocket: CCSocket?) -> Bool {
        guard !isFetchingTrueTime else {
            return false
        }
        guard let lastBootTimeInterval = stateStore.state.ccRequestMessagingState.libraryTimeState?.bootTimeIntervalAtLastTrueTime else {
            return false
        }
        guard let lastSystemTime = stateStore.state.ccRequestMessagingState.libraryTimeState?.systemTimeAtLastTrueTime else {
            return false
        }
        
        let currentBootTimeInterval = TimeHandling.timeIntervalSinceBoot()
        let currentTime = Date()
        let beetweenBootsTimeInterval = currentBootTimeInterval - lastBootTimeInterval
        let beetweenSystemsTimeInterval = currentTime.timeIntervalSince(lastSystemTime)
        
        let absDifference = abs(beetweenBootsTimeInterval - beetweenSystemsTimeInterval)
        let isSame = absDifference < TimerHandlingConstants.kMaxDifferenceAllowedBetweenSystemTimeAndBootTime
        
        Log.verbose("""
            Comparing bootTimeIntervalDiff \(String(describing: beetweenBootsTimeInterval))
            With systemTimeInterval        \(String(describing: beetweenSystemsTimeInterval))
            Result = \(isSame)
            """)
        
        if !isSame {
            fetchTrueTime()
        }
        return isSame
    }
}
