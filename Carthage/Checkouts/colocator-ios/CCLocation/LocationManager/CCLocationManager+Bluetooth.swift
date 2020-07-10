//
//  CCLocationManager+RangingBeacons.swift
//  CCLocation
//
//  Created by Mobile Developer on 04/07/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import CoreBluetooth
import CoreLocation
import Foundation

// Extension Ranging Beacons

extension CCLocationManager {
    
    @objc func updateMonitoringForRegions () {
        // stop monitoring for regions
        self.stopMonitoringForBeaconRegions()
        
        // then see if we can start monitoring for new region
        Log.verbose("------- a list of monitored regions before adding iBeacons -------")
        for monitoredRegion in locationManager.monitoredRegions {
            Log.verbose("region \(monitoredRegion)")
        }
        Log.verbose("------- list end -------")
        
        for region in currentiBeaconMonitoringState.monitoringRegions {
            var regionInMonitoredRegions = false
            
            for monitoredRegion in locationManager.monitoredRegions where monitoredRegion is CLBeaconRegion {
                if (monitoredRegion as! CLBeaconRegion).proximityUUID.uuidString == region.proximityUUID.uuidString {
                    regionInMonitoredRegions = true
                }
            }
            
            if !regionInMonitoredRegions && CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                region.notifyEntryStateOnDisplay = true
                locationManager.startMonitoring(for: region)
            }
        }
    }
    
    func stopMonitoringForBeaconRegions () {
        // first check filter out all regions we are monitoring atm
        let crowdConnectedRegions = locationManager.monitoredRegions.filter {
            if $0 is CLBeaconRegion {
                return ($0 as! CLBeaconRegion).identifier.range(of: "CC") != nil
            } else {
                return false
            }
        }
        
        // second stop monitoring for beacons that are not included in the current settings
        for region in crowdConnectedRegions where !currentiBeaconMonitoringState.monitoringRegions.contains(region as! CLBeaconRegion) {
            locationManager.stopMonitoring(for: region as! CLBeaconRegion)
        }
    }
    
    @objc func startBeaconScanning() {
        // start ibeacon scanning if enabled
        if currentBeaconState.isIBeaconRangingEnabled == true {
            updateRangingIBeacons()
        }
        
        // start eddystone beacon scanning if enabled
        if currentBeaconState.isEddystoneScanningEnabled == true {
            centralManager = CBCentralManager(delegate: self,
                                              queue: nil,
                                              options: [CBCentralManagerOptionShowPowerAlertKey: false])
            
            eddystoneBeaconScanner = BeaconScanner()
            eddystoneBeaconScanner?.delegate = self
            eddystoneBeaconScanner?.startScanning()
        }
        
        // make sure timers are cleared out
        minOffTimeBeaconTimer?.invalidate()
        minOffTimeBeaconTimer = nil
        
        // make sure that scanning finishes when maxRuntime has expired
        if let maxRuntime = currentBeaconState.maxRuntime {
            Log.verbose("Cycling: setting maxRuntime timer \(maxRuntime) in startBeaconScanning()")
            
            if maxBeaconRunTimer != nil {
                maxBeaconRunTimer?.invalidate()
                maxBeaconRunTimer = nil
            }
            maxBeaconRunTimer = Timer.scheduledTimer(timeInterval: TimeInterval(maxRuntime / 1000),
                                                     target: self,
                                                     selector: #selector(self.stopRangingBeaconsFor),
                                                     userInfo: nil,
                                                     repeats: false)
        }
    }
    
    func updateRangingIBeacons() {
        Log.debug("updateRangingIBeacons");
        
        // first stop ranging for any CrowdConnected regions
        stopRangingiBeacons(forCurrentSettings: true)
        
        // Then see if we can start ranging for new region
        for region in currentBeaconState.regions {
            var regionInRangedRegions = false
            
            for rangedRegion in locationManager.rangedRegions where rangedRegion is CLBeaconRegion {
                if (rangedRegion as! CLBeaconRegion).proximityUUID.uuidString == region.proximityUUID.uuidString {
                    regionInRangedRegions = true
                }
            }
            
            if !regionInRangedRegions && CLLocationManager.isRangingAvailable() {
                locationManager.startRangingBeacons(in: region)
            }
        }
    }
    
    @objc func stopRangingBeaconsFor() {
        // stop scanning for Eddystone beacons
        eddystoneBeaconScanner?.stopScanning()
        
        // stop ranging for iBeacons
        stopRangingiBeacons(forCurrentSettings: false)
        
        // clear timer
        maxBeaconRunTimer?.invalidate()
        maxBeaconRunTimer = nil
        
        //        if currentBeaconState.isCyclingEnabled! {
        
        // check whether we have any beacons to scan for
        let isIBeaconEnabled = currentBeaconState.isIBeaconRangingEnabled
        let isEddystoneScanEnabled = currentBeaconState.isEddystoneScanningEnabled
        
        if isIBeaconEnabled != nil || isEddystoneScanEnabled != nil {
            if let minOffTime = currentBeaconState.minOffTime {
                
                Log.verbose("Cycling: setting minOffTime timer \(minOffTime)")
                
                if minOffTimeBeaconTimer != nil {
                    minOffTimeBeaconTimer?.invalidate()
                    minOffTimeBeaconTimer = nil
                }
                minOffTimeBeaconTimer = Timer.scheduledTimer(timeInterval: TimeInterval(minOffTime / 1000),
                                                             target: self,
                                                             selector: #selector(startBeaconScanning),
                                                             userInfo: nil,
                                                             repeats: false)
            }
        }
    }
    
    func stopRangingiBeacons (forCurrentSettings: Bool) {
        // iBeacon first filter for all regions we are ranging in atm
        let crowdConnectedRegions = locationManager.rangedRegions.filter {
            if $0 is CLBeaconRegion {
                return ($0 as! CLBeaconRegion).identifier.range(of: "CC") != nil
            } else {
                return false
            }
        }
        
        // iterate through all crowdConnectedRegions
        for region in crowdConnectedRegions {
            // check if we only want to stop beacons that are not included in the current settings
            if (forCurrentSettings){
                if !currentBeaconState.regions.contains(region as! CLBeaconRegion){
                    locationManager.stopRangingBeacons(in: region as! CLBeaconRegion)
                }
                // else we want to stop ranging for all beacons, because we either received new settings without ranging or the maxRuntime has expired
            } else {
                locationManager.stopRangingBeacons(in: region as! CLBeaconRegion)
            }
        }
    }
}

// MARK: - Responding to Eddystone Beacon Discovery Events

extension CCLocationManager: BeaconScannerDelegate {
    func didFindBeacon(beaconScanner: BeaconScanner, beaconInfo: EddystoneBeaconInfo) {
        Log.verbose("Finde beacon \(beaconInfo.description)")
        
        if beaconInfo.beaconID.beaconType == BeaconID.BeaconType.EddystoneEID {
            var isFilterAvailable = false
            checkIfWindowSizeAndMaxObservationsAreAvailable(&isFilterAvailable)
            
            if isFilterAvailable {
                insert(eddystoneBeacon: beaconInfo)
            } else if let timeIntervalSinceBoot = TimeHandling.getCurrentTimePeriodSince1970(stateStore: stateStore) {
                delegate?.receivedEddystoneBeaconInfo(eid: beaconInfo.beaconID.hexBeaconID() as NSString,
                                                      tx: beaconInfo.txPower,
                                                      rssi: beaconInfo.RSSI,
                                                      timestamp: timeIntervalSinceBoot)
            }
        }
    }
    
    func didLoseBeacon(beaconScanner: BeaconScanner, beaconInfo: EddystoneBeaconInfo) {
        Log.verbose("Lost beacon \(beaconInfo.description)")
    }
    
    func didUpdateBeacon(beaconScanner: BeaconScanner, beaconInfo: EddystoneBeaconInfo) {
        Log.verbose("Update beacon \(beaconInfo.description)")
        
        if beaconInfo.beaconID.beaconType == BeaconID.BeaconType.EddystoneEID {
            var isFilterAvailable = false
            checkIfWindowSizeAndMaxObservationsAreAvailable(&isFilterAvailable)
            
            if isFilterAvailable {
                insert(eddystoneBeacon: beaconInfo)
            } else if let timeIntervalSinceBoot = TimeHandling.getCurrentTimePeriodSince1970(stateStore: stateStore) {
                delegate?.receivedEddystoneBeaconInfo(eid: beaconInfo.beaconID.hexBeaconID() as NSString,
                                                      tx: beaconInfo.txPower,
                                                      rssi: beaconInfo.RSSI,
                                                      timestamp: timeIntervalSinceBoot)
            }
        }
    }
    
    func didObserveURLBeacon(beaconScanner: BeaconScanner, URL: NSURL, RSSI: Int) {
        Log.verbose("URL SEEN: \(URL), RSSI: \(RSSI)")
    }
}

// MARK: - Responding to Ranging Events

extension CCLocationManager {
    
    fileprivate func checkIfWindowSizeAndMaxObservationsAreAvailable(_ isFilterAvailable: inout Bool) {
        if stateStore == nil { return }
        
        guard let currentBeaconState = stateStore.state.locationSettingsState.currentLocationState?.currentBeaconState else {
            return
        }
        
        if let windowSize = currentBeaconState.filterWindowSize,
            let maxObservations = currentBeaconState.filterMaxObservations {
            if windowSize > 0 && maxObservations > 0 {
                isFilterAvailable = true
            }
        }
    }
    
    fileprivate func checkRegionBelonging(_ region: CLBeaconRegion, beacon: CLBeacon) -> Bool {
        if region.proximityUUID.uuidString == beacon.proximityUUID.uuidString {
            if let major = region.major {
                if major == beacon.major {
                    return compareMinor(forBeacon: beacon, andRegion: region)
                }
            } else {
                return true
            }
        }
        return false
    }
    
    private func compareMinor(forBeacon beacon: CLBeacon, andRegion region: CLBeaconRegion) -> Bool {
        if let minor = region.minor {
            if minor == beacon.minor {
                return true
            }
        } else {
            return true
        }
        
        return false
    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        guard !beacons.isEmpty else {
            return
        }
   
        for beacon in beacons where beacon.rssi < 0 {
            Log.verbose("""
                Ranged beacon with UUID \(beacon.proximityUUID.uuidString)
                MAJOR: \(beacon.major)
                MINOR: \(beacon.minor)
                RSSI: \(beacon.rssi)
                """)
            
            var isFilterAvailable: Bool = false
            checkIfWindowSizeAndMaxObservationsAreAvailable(&isFilterAvailable)
            
            let extractedCurrentBeaconState = stateStore.state.locationSettingsState.currentLocationState?.currentBeaconState
            
            if let excludeRegions = extractedCurrentBeaconState?.filterExcludeRegions {
                checkBeaconInExcludedRegions(beacon: beacon,
                                             excludedregions: excludeRegions,
                                             filter: isFilterAvailable)
            } else {
                if isFilterAvailable {
                    insert(beacon: beacon)
                } else {
                    sendBeaconInfoToDelegate(beacon)
                }
            }
        }
    }
    
    private func checkBeaconInExcludedRegions(beacon: CLBeacon, excludedregions: [CLBeaconRegion], filter: Bool) {
        let results = Array(excludedregions.filter { region in
            return checkRegionBelonging(region, beacon: beacon)
        })
       
        if results.count > 0 {
            Log.verbose("Beacon is in exclude regions")
        } else {
            Log.verbose("Beacon is input to reporting")
           
            if filter {
                insert(beacon: beacon)
            } else {
                sendBeaconInfoToDelegate(beacon)
            }
        }
    }
    
    private func sendBeaconInfoToDelegate(_ beacon: CLBeacon) {
        if let timeIntervalSinceBoot = TimeHandling.getCurrentTimePeriodSince1970(stateStore: stateStore) {
            delegate?.receivediBeaconInfo(proximityUUID: beacon.proximityUUID,
                                          major: Int(truncating: beacon.major),
                                          minor: Int(truncating: beacon.minor),
                                          proximity: beacon.proximity.rawValue,
                                          accuracy: beacon.accuracy,
                                          rssi: Int(beacon.rssi),
                                          timestamp: timeIntervalSinceBoot)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        Log.error("[Colocator] Ranging failed for region with UUID: \(region.proximityUUID.uuidString)")
    }
}

// CBCentralManagerDelegate
extension CCLocationManager {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            if self.stateStore == nil { return }
            self.stateStore.dispatch(BluetoothHardwareChangedAction(bluetoothHardware: central.centralManagerState))
        }
    }
}

extension CBCentralManager {
    internal var centralManagerState: CBCentralManagerState {
        get {
            return CBCentralManagerState(rawValue: state.rawValue) ?? .unknown
        }
    }
}
