//
//  CCLocationManager.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 23/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import Foundation
import CoreLocation
import SQLite3
import ReSwift
import CoreBluetooth

enum GeofenceEventType: Int {
    case enter = 1
    case exit = 2
}

@objc protocol CCLocationManagerDelegate: class {
    func receivedGEOLocation(location: CLLocation)
    func receivedGeofenceEvent(type: Int, region: CLCircularRegion)
    func receivediBeaconInfo(proximityUUID:UUID, major:Int, minor:Int, proximity:Int, accuracy:Double, rssi:Int, timestamp: TimeInterval)
    func receivedEddystoneBeaconInfo(eid:NSString, tx:Int, rssi:Int, timestamp:TimeInterval)
}

class CCLocationManager: NSObject, CLLocationManagerDelegate, CBCentralManagerDelegate {
    
    internal let locationManager = CLLocationManager()
    internal var eddystoneBeaconScanner: BeaconScanner? = nil
    
    internal var currentGEOState: CurrentGEOState!
    internal var currentGeofencesMonitoringState: CurrentGeofencesMonitoringState!
    internal var currentBeaconState: CurrentBeaconState!
    internal var currentiBeaconMonitoringState: CurrentiBeaconMonitoringState!
    internal var wakeupState: WakeupState!
    
    internal var maxRunGEOTimer: Timer?
    internal var maxBeaconRunTimer: Timer?
    internal var minOffTimeBeaconTimer: Timer?
    internal var beaconWindowSizeDurationTimer: Timer?
    
    internal var centralManager: CBCentralManager?
    
    internal var iBeaconMessagesDB: SQLiteDatabase!
    internal let iBeaconMessagesDBName = "iBeaconMessages.db"
    
    internal var eddystoneBeaconMessagesDB: SQLiteDatabase!
    internal let eddystoneBeaconMessagesDBName = "eddystoneMessages.db"
    
    public weak var delegate: CCLocationManagerDelegate?
    
    weak var stateStore: Store<LibraryState>!
    
    // Initial value has to be true, otherwise after force quiting the app, the location manager will never start collecting all the data again
    var isWaitingForSignificantUpdates = true
    var isContinuousGEOCollectionActive = true
    
    #if DEBUG
    var areAllObservationsStopped = false
    #endif
    
    public init(stateStore: Store<LibraryState>) {
        super.init()
        
        self.stateStore = stateStore
        
        currentGEOState = CurrentGEOState(isInForeground: nil,
                                          activityType: nil,
                                          maxRuntime: nil,
                                          minOffTime: nil,
                                          desiredAccuracy: nil,
                                          distanceFilter: nil,
                                          pausesUpdates: nil,
                                          isSignificantUpdates: nil,
                                          isStandardGEOEnabled: nil)
        
        currentGeofencesMonitoringState = CurrentGeofencesMonitoringState(monitoringGeofences: [])
        currentiBeaconMonitoringState = CurrentiBeaconMonitoringState(monitoringRegions: [])
        
        currentBeaconState = CurrentBeaconState(isIBeaconEnabled: nil,
                                                isInForeground: nil,
                                                maxRuntime: nil,
                                                minOffTime: nil,
                                                regions: [],
                                                filterWindowSize: nil,
                                                filterMaxObservations: nil,
                                                filterExcludeRegions: [],
                                                offTime: nil,
                                                maxOnTimeStart: nil,
                                                eddystoneScanEnabled: false)
        
        wakeupState = WakeupState(ccWakeup: CCWakeup.idle)
        
        locationManager.delegate = self
        
        stateStore.subscribe(self) {
            $0.select {
                state in state.locationSettingsState.currentLocationState!
            }
        }
        
        // initial dispatch of location state
        DispatchQueue.main.async {
            if self.stateStore != nil {
                stateStore.dispatch(LocationAuthStatusChangedAction(locationAuthStatus: CLLocationManager.authorizationStatus()))
                stateStore.dispatch(IsLocationServicesEnabledAction(isLocationServicesEnabled: CLLocationManager.locationServicesEnabled()))
            }
        }
        
        openIBeaconDatabase()
        createIBeaconTable()
        
        openEddystoneBeaconDatabase()
        createEddystoneBeaconTable()
    }
    
    func startReceivingSignificantLocationChanges() {
        locationManager.startMonitoringSignificantLocationChanges()
        #if DEBUG
        areAllObservationsStopped = false
        #endif
    }
    
    func stopReceivingSignificantLocationChanges() {
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    @objc func stopLocationUpdates() {
        Log.info("[Colocator] Stop collecting GEO")
        
        locationManager.stopUpdatingLocation()
        
        Log.debug("Waiting for significant updates only")
        
        isWaitingForSignificantUpdates = true
        isContinuousGEOCollectionActive = false
        
        if maxRunGEOTimer != nil {
            maxRunGEOTimer?.invalidate()
            maxRunGEOTimer = nil
        }
        
        if let minOffTime = currentGEOState.minOffTime {
            if minOffTime > 0 {
                let offTimeEnd = Date().addingTimeInterval(TimeInterval(minOffTime / 1000))
                
                DispatchQueue.main.async {
                    if self.stateStore == nil { return }
                    self.stateStore.dispatch(SetGEOOffTimeEnd(offTimeEnd: offTimeEnd))
                }
            } else {
                DispatchQueue.main.async {
                    if self.stateStore == nil { return }
                    self.stateStore.dispatch(SetGEOOffTimeEnd(offTimeEnd: nil))
                }
            }
        }
    }
    
    func updateMonitoringGeofences() {
        stopMonitoringRemovedGeofences()
        
        Log.debug("Update monitored geofences")
        
        Log.verbose("------- List of monitored geofences before adding new ones -------")
        for monitoredGeofence in locationManager.monitoredRegions {
            Log.verbose("Geofence \(monitoredGeofence)")
        }
        Log.verbose("------- List end -------")
        
        for geofence in currentGeofencesMonitoringState.monitoringGeofences {
            var geofenceInMonitoredRegions = false
            
            for monitoredGeofence in locationManager.monitoredRegions where monitoredGeofence is CLCircularRegion {
                if (monitoredGeofence as! CLCircularRegion).identifier == geofence.identifier {
                    geofenceInMonitoredRegions = true
                }
            }
            
            if !geofenceInMonitoredRegions &&
                CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                
                geofence.notifyOnEntry = true
                geofence.notifyOnExit = true
                locationManager.startMonitoring(for: geofence)
            }
        }
    }
    
    func stopMonitoringRemovedGeofences() {
        Log.debug("Stop monitoring previous geofences")
        
        let crowdConnectedGeofences = locationManager.monitoredRegions.filter {
            return $0 is CLCircularRegion ? (($0 as! CLCircularRegion).identifier.range(of: "CC") != nil) : false
        }
        
        for geofence in crowdConnectedGeofences
            where !currentGeofencesMonitoringState.monitoringGeofences.contains(geofence as! CLCircularRegion) {
            locationManager.stopMonitoring(for: geofence as! CLCircularRegion)
        }
    }
    
    func getCurrentGeofences() -> [CLCircularRegion] {
          var geofences = [CLCircularRegion]()
          
          for monitoredGeofence in locationManager.monitoredRegions where monitoredGeofence is CLCircularRegion {
              geofences.append(monitoredGeofence as! CLCircularRegion)
          }
          
          return geofences
      }
    
    func stopTimers() {
        if maxRunGEOTimer != nil {
            maxRunGEOTimer?.invalidate()
            maxRunGEOTimer = nil
        }
        
        if maxBeaconRunTimer != nil {
            maxBeaconRunTimer?.invalidate()
            maxBeaconRunTimer = nil
        }
        
        if minOffTimeBeaconTimer != nil {
            minOffTimeBeaconTimer?.invalidate()
            minOffTimeBeaconTimer = nil
        }
        
        if beaconWindowSizeDurationTimer != nil {
            beaconWindowSizeDurationTimer?.invalidate()
            beaconWindowSizeDurationTimer = nil
        }
    }
    
    public func stopAllLocationObservations () {
        #if DEBUG
        areAllObservationsStopped = true
        #endif
        locationManager.stopUpdatingLocation()
        stopReceivingSignificantLocationChanges()
        stopRangingiBeacons(forCurrentSettings: false)
        stopMonitoringForBeaconRegions()
    }
    
    public func updateGEOAndBeaconStatesWithoutObservations() {
        currentGEOState.isStandardGEOEnabled = false
        currentGEOState.isSignificantLocationChangeMonitoringState = false
        saveCurrentGEOSateToUserDefaults(geoState: currentGEOState)
        
        currentBeaconState.isIBeaconRangingEnabled = false
        currentBeaconState.regions = []
        saveCurrentiBeaconStateToUserDefaults(currentiBeaconState: currentBeaconState)
    }
    
    private func removeLocationManagers() {
        locationManager.delegate = nil
        centralManager?.delegate = nil
        centralManager = nil
    }
    
    public func stop() {
        stopTimers()
        
        iBeaconMessagesDB.close()
        eddystoneBeaconMessagesDB.close()
        
        iBeaconMessagesDB = nil
        eddystoneBeaconMessagesDB = nil
        
        stateStore.unsubscribe(self)
        stopAllLocationObservations()
        removeLocationManagers()
    }
}

// MARK:- Responding to Location Events

extension CCLocationManager {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Log.debug("Received \(locations.count) location(s)")
        
        #if DEBUG
        areAllObservationsStopped = false
        #endif
        
        for location in locations {
            Log.verbose("Geolocation information: \(location.description)")
            delegate?.receivedGEOLocation(location: location)
        }
        
        // Significant updates doesn't trigger a wake up state
        // If GEO data collection is not continuously, then check current state and update location manager behavior
        if isWaitingForSignificantUpdates {
            if isContinuousGEOCollectionActive == false {
                Log.verbose("Renew current GEO state at significant update")
                
                updateGEOState(currentGEOState)
                if isContinuousGEOCollectionActive {
                    isWaitingForSignificantUpdates = false
                }
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        switch (error) {
        case CLError.headingFailure:
            Log.error("[Colocator] LocationManager didFailWithError kCLErrorHeadingFailure: \(error.localizedDescription)")
            //LocationUnknown error occures when the location service is unable to retrieve a location right away, but keeps trying, simply to ignore and wait for new event
        case CLError.locationUnknown:
            Log.error("[Colocator] LocationManager didFailWithError kCLErrorLocationUnknown: \(error.localizedDescription)")
            //Denied error occures when the user denies location services, if that happens we should stop location services
        case CLError.denied:
            Log.error("[Colocator] LocationManager didFailWithError kCLErrorDenied: \(error.localizedDescription)")
            // According to API reference on denied error occures, when users stops location services, so we should stop them as well here
            // If the next lines are uncommented, location updates won't start automatically in background if the user choose "Never" then "Always" from the settings menu
            
            // TODO: wrap into stop function to stop everything
            //            self.locationManager.stopUpdatingLocation()
            //            self.locationManager.stopMonitoringSignificantLocationChanges()
        default:
            Log.error("[Colocator] LocationManager didFailWithError Unknown: \(error.localizedDescription)")
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        Log.error("[Colocator] Did finish deferred updates with error \(error?.localizedDescription ?? "nil"))")
    }
}

// MARK: - Responding to Region Events

extension CCLocationManager {
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let isBeaconRegion = region is CLBeaconRegion
        let isCCGeofence = region is CLCircularRegion && region.identifier.contains("CC")
        
        if isBeaconRegion || isCCGeofence {
            triggerWakeUpAction()
        }
        
        if isCCGeofence {
            Log.debug("User entered geofence with identifier: \(region.identifier)")
            delegate?.receivedGeofenceEvent(type: GeofenceEventType.enter.rawValue, region: region as! CLCircularRegion)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let isBeaconRegion = region is CLBeaconRegion
        let isCCGeofence = region is CLCircularRegion && region.identifier.contains("CC")
               
        if isBeaconRegion || isCCGeofence {
            triggerWakeUpAction()
        }
        
        if isCCGeofence {
            Log.debug("User exited geofence with identifier: \(region.identifier)")
            delegate?.receivedGeofenceEvent(type: GeofenceEventType.exit.rawValue, region: region as! CLCircularRegion)
        }
    }
    
    private func triggerWakeUpAction() {
        DispatchQueue.main.async {
            if self.stateStore == nil { return }
            self.stateStore.dispatch(NotifyWakeupAction(ccWakeup: CCWakeup.idle))
            self.stateStore.dispatch(NotifyWakeupAction(ccWakeup: CCWakeup.notifyWakeup))
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            Log.verbose(String(format: "Inside region: %@", region.identifier))
        case .outside:
            Log.verbose(String(format: "Outside region: %@", region.identifier))
        case .unknown:
            Log.verbose(String(format: "Unkown region state: %@", region.identifier))
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        guard let region = region else {
            return
        }
        
        Log.error(String(format:"[Colocator] Monitoring did fail for Region: %@", region.identifier))
    }
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            Log.verbose("""
                Did start monitoring for region \(beaconRegion.identifier)
                uuid: \(beaconRegion.proximityUUID)
                major: \(String(describing: beaconRegion.major))
                minor: \(String(describing: beaconRegion.minor))
                """)
        }
    }
}

// MARK: - Responding to Authorization Changes

extension CCLocationManager {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Log.debug("Changed authorization status")
        
        DispatchQueue.main.async {
            if self.stateStore != nil {
                self.stateStore.dispatch(LocationAuthStatusChangedAction(locationAuthStatus: status))
                self.stateStore.dispatch(IsLocationServicesEnabledAction(isLocationServicesEnabled: CLLocationManager.locationServicesEnabled()))
            }
        }
        
        switch (status) {
        case .notDetermined:
            Log.info("[Colocator] CLLocationManager authorization status not determined")
        case .restricted:
            Log.info("[Colocator] CLLocationManager authorization status restricted, can not use location services")
            
            if #available(iOS 9.0, *) {
                locationManager.allowsBackgroundLocationUpdates = false
            } else {
                // Fallback on earlier versions
            }
        case .denied:
            Log.info("[Colocator] CLLocationManager authorization status denied in user settings, can not use location services, until user enables them")
            // might consider here to ask a question to the user to enable location services again
            
            if #available(iOS 9.0, *) {
                locationManager.allowsBackgroundLocationUpdates = false
            } else {
                // Fallback on earlier versions
            }
        case .authorizedAlways:
            Log.info("[Colocator] CLLocationManager authorization status set to always authorized, we are ready to go")
            
            if #available(iOS 9.0, *) {
                locationManager.allowsBackgroundLocationUpdates = true
            } else {
                // Fallback on earlier versions
            }
        case .authorizedWhenInUse:
            Log.info("[Colocator] CLLocationManager authorization status set to in use, no background updates enabled")
        
            if #available(iOS 9.0, *) {
                locationManager.allowsBackgroundLocationUpdates = false
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
