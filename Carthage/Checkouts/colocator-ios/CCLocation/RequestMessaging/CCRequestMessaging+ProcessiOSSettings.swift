//
//  CCRequestMessaging+ProcessiOSSettings.swift
//  CCLocation
//
//  Created by Mobile Developer on 04/07/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation
import CoreLocation
import ReSwift
import CoreBluetooth

// Extension Process iOS Settings

extension CCRequestMessaging {
    
    func processIosSettings (serverMessage: Messaging_ServerMessage, store: Store<LibraryState>) {
        // When Missing Settings
        
        if serverMessage.hasIosSettings && !serverMessage.iosSettings.hasGeoSettings {
            disableGEOActions(store: store)
        }
        if serverMessage.hasIosSettings && !serverMessage.iosSettings.hasBeaconSettings {
            disableBeaconActions(store: store)
        }
        if serverMessage.hasIosSettings && !serverMessage.iosSettings.hasInertialSettings {
            disableInertialActions(store: store)
        }
        if serverMessage.hasIosSettings && !serverMessage.iosSettings.hasIOscontactSettings {
            disableContactActions(store: store)
        }
        
        // When Having Settings
        
        // GEO Settings
        if serverMessage.hasIosSettings && serverMessage.iosSettings.hasGeoSettings {
            updateAllGEOSettings(newGEOSettings: serverMessage.iosSettings.geoSettings, store: store)
        }
        
        // Beacon Settings
        if serverMessage.hasIosSettings && serverMessage.iosSettings.hasBeaconSettings {
            updateAllBeaconSettings(newBeaconSettings: serverMessage.iosSettings.beaconSettings, store: store)
        }
        
        // Inertial Settings
        if serverMessage.hasIosSettings && serverMessage.iosSettings.hasInertialSettings {
            updateInertialState(inertialSettings: serverMessage.iosSettings.inertialSettings, store: store)
        }
        
        // Contact Tracing Settings
        if serverMessage.hasIosSettings && serverMessage.iosSettings.hasIOscontactSettings {
            updateContactState(contactSettings: serverMessage.iosSettings.iOscontactSettings, store: store)
        }
    }
    
    // MARK: - Disabling Settings
    
    // Disable Settings Actions
    
    private func disableGEOActions(store: Store<LibraryState>) {
        DispatchQueue.main.async {store.dispatch(DisableBackgroundGEOAction())}
        DispatchQueue.main.async {store.dispatch(DisableForegroundGEOAction())}
        DispatchQueue.main.async {store.dispatch(IsSignificationLocationChangeAction(isSignificantLocationChangeMonitoringState: false))}
        DispatchQueue.main.async {store.dispatch(DisableCurrrentGEOAction())}
        DispatchQueue.main.async {store.dispatch(DisableGeofencesMonitoringAction())}
    }
    
    private func disableBeaconActions(store: Store<LibraryState>) {
        DispatchQueue.main.async {store.dispatch(DisableCurrentiBeaconMonitoringAction())}
        DispatchQueue.main.async {store.dispatch(DisableForegroundiBeaconAction())}
        DispatchQueue.main.async {store.dispatch(DisableBackgroundiBeaconAction())}
        DispatchQueue.main.async {store.dispatch(DisableCurrrentiBeaconAction())}
    }
    
    private func disableInertialActions(store: Store<LibraryState>) {
        DispatchQueue.main.async {store.dispatch(DisableInertialAction())}
    }
    
    private func disableContactActions(store: Store<LibraryState>) {
        DispatchQueue.main.async {store.dispatch(DisableContactBluetoothAction())}
        DispatchQueue.main.async {store.dispatch(DisableEIDAction())}
    }
    
    // MARK: - Updating Settings
    
    // Updating Geo Settings
    
    private func updateAllGEOSettings(newGEOSettings: Messaging_IosGeoSettings, store: Store<LibraryState>) {
        updateSignificantUpdatesState(geoSettings: newGEOSettings, store: store)
        updateBackgroundGEOState(geoSettings: newGEOSettings, store: store)
        updateForegroundGEOState(geoSettings: newGEOSettings, store: store)
        updateGeofencesState(geoSettings: newGEOSettings, store: store)
    }
    
    private func updateSignificantUpdatesState(geoSettings: Messaging_IosGeoSettings, store: Store<LibraryState>) {
        if geoSettings.hasSignificantUpates && geoSettings.significantUpates {
            DispatchQueue.main.async {
                store.dispatch(IsSignificationLocationChangeAction(isSignificantLocationChangeMonitoringState: true))
            }
        } else {
            DispatchQueue.main.async {
                store.dispatch(IsSignificationLocationChangeAction(isSignificantLocationChangeMonitoringState: false))
            }
        }
    }
    
    private func updateBackgroundGEOState(geoSettings: Messaging_IosGeoSettings, store: Store<LibraryState>) {
        if geoSettings.hasBackgroundGeo {
            configureBackgroundGEOSettings(geoSettings: geoSettings, store: store)
        } else {
            DispatchQueue.main.async {store.dispatch(DisableBackgroundGEOAction())}
        }
    }
    
    private func updateForegroundGEOState(geoSettings: Messaging_IosGeoSettings, store: Store<LibraryState>) {
        if geoSettings.hasForegroundGeo {
            configureForegroundGEOSettings(geoSettings: geoSettings, store: store)
        } else {
            DispatchQueue.main.async {store.dispatch(DisableForegroundGEOAction())}
        }
    }
    
    private func updateGeofencesState(geoSettings: Messaging_IosGeoSettings, store: Store<LibraryState>) {
        if !geoSettings.iosCircularGeoFences.isEmpty {
            configureCircularGeoFencesSettings(geoSettings: geoSettings, store: store)
        } else {
            DispatchQueue.main.async {store.dispatch(DisableGeofencesMonitoringAction()) }
        }
    }
    
    // Updating Beacon Settings
    
    private func updateAllBeaconSettings(newBeaconSettings: Messaging_IosBeaconSettings, store: Store<LibraryState>) {
        updateBeaconMonitoringState(beaconSettings: newBeaconSettings, store: store)
        updateForegroundBeaconRangingState(beaconSettings: newBeaconSettings, store: store)
        updateBackgroundBeaconRangingState(beaconSettings: newBeaconSettings, store: store)
    }
    
    private func  updateBeaconMonitoringState(beaconSettings: Messaging_IosBeaconSettings, store: Store<LibraryState>) {
        if beaconSettings.hasMonitoring {
            configureMonitoringRegions(beaconSettings: beaconSettings, store: store)
        } else {
            DispatchQueue.main.async {store.dispatch(DisableCurrentiBeaconMonitoringAction())}
        }
    }
    
    private func  updateForegroundBeaconRangingState(beaconSettings: Messaging_IosBeaconSettings, store: Store<LibraryState>) {
        if beaconSettings.hasForegroundRanging {
            configureBeaconRanging(forAppState: .foreground, beaconSettings: beaconSettings, store: store)
        } else {
            DispatchQueue.main.async {store.dispatch(DisableForegroundiBeaconAction())}
        }
    }
    
    private func  updateBackgroundBeaconRangingState(beaconSettings: Messaging_IosBeaconSettings, store: Store<LibraryState>) {
        if beaconSettings.hasBackgroundRanging {
            configureBeaconRanging(forAppState: .background, beaconSettings: beaconSettings, store: store)
        } else {
            DispatchQueue.main.async {self.stateStore.dispatch(DisableBackgroundiBeaconAction())}
        }
    }
    
    // Updating Inertial Settings
    
    private func updateInertialState(inertialSettings: Messaging_IosInertialSettings, store: Store<LibraryState>) {
        var isInertialEnable: Bool?
        var interval: UInt32?
        
        if inertialSettings.hasEnabled {
            isInertialEnable = inertialSettings.enabled
        }
       
        if inertialSettings.hasInterval {
            interval = inertialSettings.interval
        }
       
        DispatchQueue.main.async {self.stateStore.dispatch(InertialStateChangedAction(isEnabled: isInertialEnable,
                                                                                                 interval: interval))}
    }
    
    // Updating Contact Settings
    
    private func updateContactState(contactSettings: Messaging_iOSContactSettings, store: Store<LibraryState>) {
        if contactSettings.hasIOscontactBtsettings {
            let contactBTSettings = contactSettings.iOscontactBtsettings
       
            var serviceUUID: String?
            var scanInterval: UInt64?
            var scanDuration: UInt64?
            var advertiseInterval: UInt64?
            var advertiseDuration: UInt64?
            
            if contactBTSettings.hasServiceUuid {
                serviceUUID = contactBTSettings.serviceUuid
            }
            if contactBTSettings.hasScanInterval {
                scanInterval = contactBTSettings.scanInterval
            }
            if contactBTSettings.hasScanDuration {
                scanDuration = contactBTSettings.scanDuration
            }
            if contactBTSettings.hasAdvertiseInterval {
                advertiseInterval = contactBTSettings.advertiseInterval
            }
            if contactBTSettings.hasAdvertiseDuration {
                advertiseDuration = contactBTSettings.advertiseDuration
            }
            
            DispatchQueue.main.async {store.dispatch(ContactBluetoothStateChangedAction(isEnabled: true,
                                                                                        serviceUUID: serviceUUID,
                                                                                        scanInterval: scanInterval,
                                                                                        scanDuration: scanDuration,
                                                                                        advertiseInterval: advertiseInterval,
                                                                                        advertiseDuration: advertiseDuration))}
            
            
        } else {
             DispatchQueue.main.async {store.dispatch(DisableContactBluetoothAction())}
        }
        
        if contactSettings.hasEid {
            let eidSettings = contactSettings.eid
            updateEIDState(eidSettings: eidSettings, store: store)
        } else {
            //Probably not necessary
//            DispatchQueue.main.async {store.dispatch(DisableEIDAction())}
        }
    }
    
    // Updating Contact Settings
    
    private func updateEIDState(eidSettings: Messaging_EID, store: Store<LibraryState>) {
        var secret: String?
        var k: UInt32?
        var clockOffSet: UInt32?
        
        if eidSettings.hasSecret {
            secret = String(decoding: eidSettings.secret, as: UTF8.self)
        }
        if eidSettings.hasK {
            k = eidSettings.k
        }
        if eidSettings.hasClockOffset {
            clockOffSet = eidSettings.clockOffset
        }
        
        DispatchQueue.main.async { store.dispatch(EIDStateChangedAction(secret: secret, k: k, clockOffset: clockOffSet))}
    }
    
    // MARK: - Configurating GEO Settings
    
    public func configureBackgroundGEOSettings(geoSettings: Messaging_IosGeoSettings, store: Store<LibraryState>) {
        var desiredAccuracy: Int32?
        var distanceFilter: Int32?
        var pausesUpdates: Bool?
        var activityType: CLActivityType?
        
        var maxRuntime: UInt64?
        var minOffTime: UInt64?
        
        if geoSettings.backgroundGeo.hasDistanceFilter {
            distanceFilter = geoSettings.backgroundGeo.distanceFilter
        }
        if geoSettings.backgroundGeo.hasDesiredAccuracy {
            desiredAccuracy = geoSettings.backgroundGeo.desiredAccuracy
        }
        if geoSettings.backgroundGeo.hasPausesUpdates {
            pausesUpdates = geoSettings.backgroundGeo.pausesUpdates
        }
        if geoSettings.backgroundGeo.hasActivityType {
           activityType = getActivityTypeFromSettings(geoSettings.backgroundGeo)
        }
        
        if geoSettings.backgroundGeo.hasMaxRunTime && geoSettings.backgroundGeo.maxRunTime > 0 {
            maxRuntime = geoSettings.backgroundGeo.maxRunTime
        }
       
        if geoSettings.backgroundGeo.hasMinOffTime && geoSettings.backgroundGeo.minOffTime > 0 {
            minOffTime = geoSettings.backgroundGeo.minOffTime
        }
        
        let enableBackgroundGEOAction = EnableBackgroundGEOAction(activityType: activityType,
                                                                  maxRuntime: maxRuntime,
                                                                  minOffTime: minOffTime,
                                                                  desiredAccuracy: desiredAccuracy,
                                                                  distanceFilter: distanceFilter,
                                                                  pausesUpdates: pausesUpdates)
        
        DispatchQueue.main.async {store.dispatch(enableBackgroundGEOAction)}
    }
    
    public func configureForegroundGEOSettings(geoSettings: Messaging_IosGeoSettings, store: Store<LibraryState>) {
        var desiredAccuracy:Int32?
        var distanceFilter:Int32?
        var pausesUpdates:Bool?
        var activityType: CLActivityType?
        
        var maxRuntime:UInt64?
        var minOffTime:UInt64?
        
        if geoSettings.foregroundGeo.hasDistanceFilter {
            distanceFilter = geoSettings.foregroundGeo.distanceFilter
        }
        if geoSettings.foregroundGeo.hasDesiredAccuracy {
            desiredAccuracy = geoSettings.foregroundGeo.desiredAccuracy
        }
        if geoSettings.foregroundGeo.hasPausesUpdates {
            pausesUpdates = geoSettings.foregroundGeo.pausesUpdates
        }
        if geoSettings.foregroundGeo.hasActivityType {
            activityType = getActivityTypeFromSettings(geoSettings.foregroundGeo)
        }
        
        if geoSettings.foregroundGeo.hasMaxRunTime && geoSettings.foregroundGeo.maxRunTime > 0 {
            maxRuntime = geoSettings.foregroundGeo.maxRunTime
        }
        
        if geoSettings.foregroundGeo.hasMinOffTime && geoSettings.foregroundGeo.minOffTime > 0 {
            minOffTime = geoSettings.foregroundGeo.minOffTime
        }
        
        let enableForegroundGEOAction = EnableForegroundGEOAction(activityType: activityType,
                                                                  maxRuntime: maxRuntime,
                                                                  minOffTime: minOffTime,
                                                                  desiredAccuracy: desiredAccuracy,
                                                                  distanceFilter: distanceFilter,
                                                                  pausesUpdates: pausesUpdates)
        
        DispatchQueue.main.async {store.dispatch(enableForegroundGEOAction)}
    }
    
    private func getActivityTypeFromSettings(_ settings: Messaging_IosStandardGeoSettings) -> CLActivityType {
        switch settings.activityType {
        case Messaging_IosStandardGeoSettings.Activity.other: return .other
        case Messaging_IosStandardGeoSettings.Activity.auto: return .automotiveNavigation
        case Messaging_IosStandardGeoSettings.Activity.fitness: return .fitness
        case Messaging_IosStandardGeoSettings.Activity.navigation: return .otherNavigation
        }
    }
    
    // MARK: - Configurating Geofences Settings
    
    public func configureCircularGeoFencesSettings(geoSettings: Messaging_IosGeoSettings, store: Store<LibraryState>) {
        let geoFenceSettings = geoSettings.iosCircularGeoFences
        var geoFences = [CLCircularRegion]()
        
        for geofence in geoFenceSettings {
            if let clCircularRegion = extractGeofenceFromSettings(geofence) {
                geoFences.append(clCircularRegion)
            }
        }
        
        DispatchQueue.main.async {
            let sortedGeoFences = geoFences.sorted(by: {$0.identifier < $1.identifier})
            store.dispatch(EnableGeofencesMonitoringAction(geofences: sortedGeoFences))
        }
    }
       
     // MARK: - Configurating Beacon Regions Settings
    
    public func configureMonitoringRegions(beaconSettings: Messaging_IosBeaconSettings, store: Store<LibraryState>) {
        let monitoringSettings = beaconSettings.monitoring
        var monitoringRegions: [CLBeaconRegion] = []
        
        for region in monitoringSettings.regions {
            let extractedRegions = extractBeaconRegionsFrom(region: region)
            monitoringRegions.append(contentsOf: extractedRegions)
        }
        
        DispatchQueue.main.async {
            let sortedMonitoringRegions = monitoringRegions.sorted(by: {$0.identifier < $1.identifier})
            store.dispatch(EnableCurrentiBeaconMonitoringAction(monitoringRegions: sortedMonitoringRegions))
        }
    }
    
    // MARK: - Configurating Beacon Ranging Settings
    
    private func configureBeaconRanging(forAppState state: LifeCycle,
                                        beaconSettings: Messaging_IosBeaconSettings,
                                        store: Store<LibraryState>) {
        let beaconRanging = state == .foreground ? beaconSettings.foregroundRanging : beaconSettings.backgroundRanging
        
        var excludeRegions: [CLBeaconRegion] = []
        var rangingRegions: [CLBeaconRegion] = []
        
        var maxRuntime: UInt64?
        var minOffTime: UInt64?
        var filterWindowSize: UInt64?
        var maxObservations: UInt32?
        
        var eddystoneScan: Bool?
        
        for region in beaconRanging.regions {
            let extractedRegions = extractBeaconRegionsFrom(region: region)
            rangingRegions.append(contentsOf: extractedRegions)
        }
        
        for region in beaconRanging.filter.excludeRegions {
            let extractedRegions = extractBeaconRegionsFrom(region: region)
            excludeRegions.append(contentsOf: extractedRegions)
        }
        
        if beaconRanging.hasMaxRunTime && beaconRanging.maxRunTime > 0 {
            maxRuntime = beaconRanging.maxRunTime
        }
        if beaconRanging.hasMinOffTime && beaconRanging.minOffTime > 0 {
            minOffTime = beaconRanging.minOffTime
        }
        updateFilters(windowSize: &filterWindowSize, maxObservations: &maxObservations, for: beaconRanging)
       
        if beaconRanging.hasEddystoneScan {
            eddystoneScan = beaconRanging.eddystoneScan
        }
        
        let isIBeaconRangingEnabled = rangingRegions.count > 0
        
        DispatchQueue.main.async {
            switch state {
            case .background:
                store.dispatch(EnableBackgroundiBeaconAction(maxRuntime: maxRuntime,
                                                             minOffTime: minOffTime,
                                                             regions: rangingRegions.sorted(by: {$0.identifier < $1.identifier}),
                                                             filterWindowSize: filterWindowSize,
                                                             filterMaxObservations: maxObservations,
                                                             filterExcludeRegions: excludeRegions.sorted(by: {$0.identifier < $1.identifier}),
                                                             eddystoneScanEnabled: eddystoneScan,
                                                             isIBeaconRangingEnabled: isIBeaconRangingEnabled))
            case .foreground:
                store.dispatch(EnableForegroundBeaconAction(maxRuntime: maxRuntime,
                                                            minOffTime: minOffTime,
                                                            regions: rangingRegions.sorted(by: {$0.identifier < $1.identifier}),
                                                            filterWindowSize: filterWindowSize,
                                                            filterMaxObservations: maxObservations,
                                                            filterExcludeRegions: excludeRegions.sorted(by: {$0.identifier < $1.identifier}),
                                                            isEddystoneScanEnabled: eddystoneScan,
                                                            isIBeaconRangingEnabled: isIBeaconRangingEnabled))
            }
        }
    }
    
    private func updateFilters(windowSize: inout UInt64?,
                               maxObservations: inout UInt32?,
                               for beaconRanging: Messaging_BeaconRanging) {
        if beaconRanging.hasFilter {
            let filter = beaconRanging.filter
            
            if filter.hasWindowSize && filter.windowSize > 0 {
                windowSize = filter.windowSize
            }
            
            if filter.hasMaxObservations && filter.maxObservations > 0 {
                maxObservations = filter.maxObservations
            }
        }
    }
    
    // MARK: - Extract Regions From Settings
    
    public func extractGeofenceFromSettings(_ geofenceRegion: Messaging_IosCircularGeoFence) -> CLCircularRegion? {
        if geofenceRegion.hasLatitude &&
            geofenceRegion.hasLongitude &&
            geofenceRegion.hasRadius {
            
            let coordinates = CLLocationCoordinate2D(latitude: geofenceRegion.latitude,
                                                     longitude: geofenceRegion.longitude)
            
            //TODO add identifier here
            let identifier = "CC_geofence_\(UUID())"
            
            let geofence = CLCircularRegion(center: coordinates,
                                            radius: geofenceRegion.radius,
                                            identifier: identifier)
            geofence.notifyOnEntry = true
            geofence.notifyOnExit = true
            
            return geofence
        }
      return nil
    }
    
    public func extractBeaconRegionsFrom(region: Messaging_BeaconRegion) -> [CLBeaconRegion] {
        var extractedRegions = [CLBeaconRegion]()
        
        if !region.hasUuid {
            return [CLBeaconRegion]()
        }
        
        if region.hasMajor {
            if region.hasMinor, let uuid = UUID(uuidString: region.uuid) {
                let newBeaconRegion = CLBeaconRegion(proximityUUID: uuid,
                                                     major: CLBeaconMajorValue(region.major),
                                                     minor: CLBeaconMinorValue(region.minor),
                                                     identifier: "CC \(region.uuid):\(region.major):\(region.minor)")
                extractedRegions.append(newBeaconRegion)
                
            } else if let uuid = UUID(uuidString: region.uuid) {
                let newBeaconRegion = CLBeaconRegion(proximityUUID: uuid,
                                                     major: CLBeaconMajorValue(region.major),
                                                     identifier: "CC \(region.uuid):\(region.major)")
                extractedRegions.append(newBeaconRegion)
            }
        }
        else if let uuid = UUID(uuidString: region.uuid) {
            let newBeaconRegion = CLBeaconRegion(proximityUUID: uuid,
                                                 identifier: "CC \(region.uuid)")
            extractedRegions.append(newBeaconRegion)
        }
        return extractedRegions
    }
}
