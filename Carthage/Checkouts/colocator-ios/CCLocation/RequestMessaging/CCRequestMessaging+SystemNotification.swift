//
//  CCRequestMessaging+SystemNotification.swift
//  CCLocation
//
//  Created by Mobile Developer on 23/08/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation

extension CCRequestMessaging {
    
    // MARK: - APPLICATION STATE HANDLING FUNCTIONS
    
    @objc func applicationWillResignActive() {
        Log.debug("[APP STATE] applicationWillResignActive")
    }
    
    @objc func applicationDidEnterBackground() {
        Log.debug("[APP STATE] applicationDidEnterBackground")
        
        DispatchQueue.main.async {self.stateStore.dispatch(LifeCycleAction(lifecycleState: LifeCycle.background))}
    }
    
    @objc func applicationWillEnterForeground() {
        Log.debug("[APP STATE] applicationWillEnterForeground")
    }
    
    @objc func applicationDidBecomeActive() {
        Log.debug("[APP STATE] applicationDidBecomeActive")
        
        DispatchQueue.main.async {self.stateStore.dispatch(LifeCycleAction(lifecycleState: LifeCycle.foreground))}
    }
    
    @objc func applicationWillTerminate() {
        Log.debug("[APP STATE] applicationWillTerminate")
    }
    
    // MARK: - SYSTEM NOTIFICATIONS
    
    func setupApplicationNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(applicationWillResignActive),
                                               name:UIApplication.willResignActiveNotification,
                                               object:nil)
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(applicationDidEnterBackground),
                                               name:UIApplication.didEnterBackgroundNotification,
                                               object:nil)
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(applicationWillEnterForeground),
                                               name:UIApplication.willEnterForegroundNotification,
                                               object:nil)
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(applicationDidBecomeActive),
                                               name:UIApplication.didBecomeActiveNotification,
                                               object:nil)
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(applicationWillTerminate),
                                               name:UIApplication.willTerminateNotification,
                                               object:nil)
    }
        
    func setupBatteryStateAndLevelNotifcations() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(batteryLevelDidChange),
                                               name: UIDevice.batteryLevelDidChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(batteryStateDidChange),
                                               name: UIDevice.batteryStateDidChangeNotification,
                                               object: nil)
        if #available(iOS 9.0, *) {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(powerModeDidChange),
                                                   name: NSNotification.Name.NSProcessInfoPowerStateDidChange,
                                                   object: nil)
        }
    }
        
    @objc func batteryLevelDidChange(notification: Notification) {
        let batteryLevel = UIDevice.current.batteryLevel
        
        DispatchQueue.main.async {self.stateStore.dispatch(BatteryLevelChangedAction(batteryLevel: UInt32(batteryLevel * 100)))}
    }
    
    @objc func batteryStateDidChange(notification: Notification) {
        let batteryState = UIDevice.current.batteryState
        
        DispatchQueue.main.async {
            if self.stateStore != nil {
                self.stateStore.dispatch(BatteryStateChangedAction(batteryState: batteryState))
            }
        }
    }
        
    @objc func powerModeDidChange(notification: Notification) {
        if #available(iOS 9.0, *) {
            let isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
            
            DispatchQueue.main.async {self.stateStore.dispatch(IsLowPowerModeEnabledAction(isLowPowerModeEnabled: isLowPowerMode))}
        }
    }
}
