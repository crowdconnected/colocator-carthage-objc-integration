//
//  CCRequestMessaging+StoreSubscriber.swift
//  CCLocation
//
//  Created by Mobile Developer on 04/07/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation
import ReSwift

// Extension Store Subscriber

extension CCRequestMessaging: StoreSubscriber {
    
    public func newState(state: CCRequestMessagingState) {
        Log.verbose("New RequestMessaging state is \n\(state)")
        
        if let webSocketState = state.webSocketState, webSocketState != currentWebSocketState {
            currentWebSocketState = webSocketState
                
            if webSocketState.connectionState == ConnectionState.online {
                Log.info("[Colocator] New connection has started")
                    
                //Send queued messages to server on new connection without radioSilencer delay
                sendQueuedClientMessages(firstMessage: nil)
                    
                if let aliases = UserDefaults.standard.dictionary(forKey: CCSocketConstants.kAliasKey) {
                    processAliases(aliases: aliases as! Dictionary<String, String>)
                }
            }
        }
        
        if let newTimerState = state.radiosilenceTimerState, newTimerState != currentRadioSilenceTimerState {
            updateTimerState(newState: newTimerState)
        }
        
        if let newLibraryTimeState = state.libraryTimeState, newLibraryTimeState != currentLibraryTimerState {
            currentLibraryTimerState = newLibraryTimeState
                
            if let bootTimeInterval = newLibraryTimeState.bootTimeIntervalAtLastTrueTime,
                bootTimeInterval - TimeHandling.timeIntervalSinceBoot() > 60 {
                timeHandling.fetchTrueTime()
            }
        }
        
        if let newCapabilityState = state.capabilityState, newCapabilityState != currentCapabilityState {
            currentCapabilityState = newCapabilityState
            
            processIOSCapability(locationAuthStatus: newCapabilityState.locationAuthStatus,
                                 bluetoothHardware: newCapabilityState.bluetoothHardware,
                                 batteryState: newCapabilityState.batteryState,
                                 isLowPowerModeEnabled: newCapabilityState.isLowPowerModeEnabled,
                                 isLocationServicesEnabled: newCapabilityState.isLocationServicesAvailable,
                                 isMotionAndFitnessEnabled: newCapabilityState.isMotionAndFitnessAvailable)
        }
    }
    
    public func updateTimerState(newState: TimerState) {
        currentRadioSilenceTimerState = newState
        
        // Covers case were app starts from terminated and no timer is available yet
        if timeBetweenSendsTimer == nil && timeHandling.isRebootTimeSame(stateStore: stateStore, ccSocket: ccSocket) {
            Log.verbose("RadioSilence timeBetweenSendsTimer is nil, scheduling new timer")
            
            DispatchQueue.main.async {
                if self.stateStore != nil {
                    self.stateStore.dispatch(ScheduleSilencePeriodTimerAction())
                }
            }
        }
        
        if newState.timer == .schedule {
            scheduleTimerWithNewTimerInterval(newState: newState)
        }
        if newState.timer == .running {
            Log.verbose("RadioSilence timer running")
        }
        if newState.timer == .invalidate {
            Log.verbose("RadioSilence timer invalidated")
            
            timeBetweenSendsTimer?.invalidate()
            timeBetweenSendsTimer = nil
            
            DispatchQueue.main.async {
                if self.stateStore != nil {
                    self.stateStore.dispatch(TimerStoppedAction())
                }
            }
        }
    }
    
    public func scheduleTimerWithNewTimerInterval(newState: TimerState) {
        if timeBetweenSendsTimer?.isValid == true {
            timeBetweenSendsTimer?.invalidate()
        }
        
        guard let newTimeInterval = newState.timeInterval else {
            return
        }
        
        if let radioSilenceTimerState = newState.startTimeInterval {
            let intervalForLastTimer = TimeHandling.timeIntervalSinceBoot() - radioSilenceTimerState
            Log.verbose("RadioSilence intervalForLastTimer = \(intervalForLastTimer)")
            
            if intervalForLastTimer < Double(Double(newTimeInterval) / 1000) {
                timeBetweenSendsTimer = Timer.scheduledTimer(timeInterval: TimeInterval(intervalForLastTimer),
                                                             target: self,
                                                             selector: #selector(self.sendQueuedClientMessagesTimerFiredOnce),
                                                             userInfo: nil,
                                                             repeats: false)
                DispatchQueue.main.async {
                    if self.stateStore != nil {
                        self.stateStore.dispatch(TimerRunningAction(startTimeInterval: nil))
                    }
                }
                return
            }
        }
        
        // Case intervalForLastTimer > newTimeInterval or there's no new startTimeInterval
        setTimeBetweenSendsAndAction(interval: newTimeInterval)
    }
    
    private func setTimeBetweenSendsAndAction(interval: UInt64) {
        timeBetweenSendsTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Double(interval) / 1000),
                                                     target: self,
                                                     selector: #selector(self.sendQueuedClientMessagesTimerFired),
                                                     userInfo: nil,
                                                     repeats: true)
        DispatchQueue.main.async {
            if self.stateStore != nil {
                self.stateStore.dispatch(TimerRunningAction(startTimeInterval: TimeHandling.timeIntervalSinceBoot()))
            }
        }
    }
}
