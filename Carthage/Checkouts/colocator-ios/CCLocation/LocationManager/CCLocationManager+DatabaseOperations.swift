//
//  CCLocationManager+DatabaseOperations.swift
//  CCLocation
//
//  Created by Mobile Developer on 04/07/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import CoreLocation
import Foundation

// Extension Database Operations

extension CCLocationManager {
    
    public func countBeacons() {
        
        do {
            let beaconCount = try iBeaconMessagesDB.count(table:CCLocationTables.kIBeaconMessagesTable)
            Log.debug("Process beacon table, beacon count: \(String(describing: beaconCount))")
        } catch {
            Log.error("[Colocator]  Beacon database error: \(iBeaconMessagesDB.errorMessage)")
        }
    }
    
    public func countEddystoneBeacons() {
        
        do {
            let beaconCount = try eddystoneBeaconMessagesDB.count(table:CCLocationTables.kEddystoneBeaconMessagesTable)
            Log.debug("Process Eddystone beacon table, beacon count: \(String(describing: beaconCount))")
        } catch {
            Log.error("[Colocator] Eddystone beacon database error: \(eddystoneBeaconMessagesDB.errorMessage)")
        }
    }
    
    public func getAllBeaconsAndDelete() -> [Beacon]? {
        
        var beacons: [Beacon]?
        
        do {
            try beacons = iBeaconMessagesDB.getAllBeaconsAndDelete()
        } catch {
            Log.error("[Colocator] Beacon database error: \(iBeaconMessagesDB.errorMessage)")
        }
        
        return beacons
    }
    
    public func getAllEddystoneBeaconsAndDelete() -> [EddystoneBeacon]? {
        
        var beacons: [EddystoneBeacon]?
        
        do {
            try beacons = eddystoneBeaconMessagesDB.getAllEddystoneBeaconsAndDelete()
            
        } catch {
            Log.error("[Colocator] Eddystone beacon database error: \(eddystoneBeaconMessagesDB.errorMessage)")
        }
        
        return beacons
    }
    
    // MARK:- iBeacon database handling
    
    func openIBeaconDatabase() {
        
        // Get the library directory
        let dirPaths = NSSearchPathForDirectoriesInDomains (.libraryDirectory, .userDomainMask, true)
        
        let docsDir = dirPaths[0]
        
        // Build the path to the database file
        let beaconDBPath = URL.init(string: docsDir)?.appendingPathComponent(iBeaconMessagesDBName).absoluteString
        
        guard let beaconDBPathStringUnwrapped = beaconDBPath else {
            Log.error("[Colocator] Unable to create beacon database path")
            return
        }
        
        do {
            iBeaconMessagesDB = try SQLiteDatabase.open(path: beaconDBPathStringUnwrapped)
            Log.debug("Successfully opened connection to beacon database.")
        } catch SQLiteError.OpenDatabase(let message) {
            Log.error("[Colocator] Unable to open database. \(message)")
        } catch {
            Log.error("[Colocator] An unexpected error was thrown, when trying to open a connection to beacon database")
        }
    }
    
    public func createIBeaconTable() {
        
        do {
            try iBeaconMessagesDB.createTable(table: Beacon.self)
        } catch {
            Log.error("[Colocator] Beacon database error: \(iBeaconMessagesDB.errorMessage)")
        }
    }
    
    func insert(beacon: CLBeacon) {
        
        if let timeIntervalSinceBoot = TimeHandling.getCurrentTimePeriodSince1970(stateStore: stateStore) {
            
            do {
                try iBeaconMessagesDB.insertBeacon(beacon: Beacon (
                    uuid: beacon.proximityUUID.uuidString as NSString,
                    major: beacon.major.int32Value,
                    minor: beacon.minor.int32Value,
                    proximity: Int32(beacon.proximity.rawValue),
                    accuracy: beacon.accuracy,
                    rssi: Int32(beacon.rssi),
                    timeIntervalSinceBootTime: timeIntervalSinceBoot
                ))
            } catch {
                Log.error("[Colocator] Beacon database error: \(iBeaconMessagesDB.errorMessage)")
            }
        }
    }
    
    // MARK:- Eddystone Beacon database handling
    
    func openEddystoneBeaconDatabase() {
        
        // Get the library directory
        let dirPaths = NSSearchPathForDirectoriesInDomains (.libraryDirectory, .userDomainMask, true)
        
        let docsDir = dirPaths[0]
        
        // Build the path to the database file
        let beaconDBPath = URL.init(string: docsDir)?.appendingPathComponent(eddystoneBeaconMessagesDBName).absoluteString
        
        guard let beaconDBPathStringUnwrapped = beaconDBPath else {
            Log.error("[Colocator] Unable to create beacon database path")
            return
        }
        
        do {
            eddystoneBeaconMessagesDB = try SQLiteDatabase.open(path: beaconDBPathStringUnwrapped)
            Log.debug("Successfully opened connection to Eddystone database.")
        } catch SQLiteError.OpenDatabase(let message) {
            Log.error("[Colocator] Unable to open database. \(message)")
        } catch {
            Log.error("[Colocator] An unexpected error was thrown, when trying to open a connection to Eddystone database")
        }
    }
    
    func createEddystoneBeaconTable() {
        
        do {
            try eddystoneBeaconMessagesDB.createTable(table: EddystoneBeacon.self)
        } catch {
            Log.error("[Colocator] Eddystone beacon database error: \(eddystoneBeaconMessagesDB.errorMessage)")
        }
    }
    
    func insert(eddystoneBeacon: EddystoneBeaconInfo) {
        
        if let timeIntervalSinceBoot = TimeHandling.getCurrentTimePeriodSince1970(stateStore: stateStore) {
            
            do {
                try eddystoneBeaconMessagesDB.insertEddystoneBeacon(eddystoneBeacon: EddystoneBeacon (
                    eid: eddystoneBeacon.beaconID.hexBeaconID() as NSString,
                    rssi: Int32(eddystoneBeacon.RSSI),
                    tx: Int32(eddystoneBeacon.txPower),
                    timeIntervalSinceBootTime: timeIntervalSinceBoot
                ))
            } catch {
                Log.error("[Colocator] Eddystone beacon database error: \(eddystoneBeaconMessagesDB.errorMessage)")
            }
        }
    }
    
    // MARK: - PROCESS BEACON AND EDDYBEACON TABLES
       
       @objc func processBeaconTables() {
           processiBeaconTable()
           processEddystoneBeaconTable()
       }
       
       func processiBeaconTable() {
           
           countBeacons()
           guard let beaconsUnwrapped = getAllBeaconsAndDelete() else {
               return
           }
           
           // create a key / value list that creates a unquiqe key for each beacon.
           var newBeacons: [[String:Beacon]] = []
           
           for beacon in beaconsUnwrapped {
               
               var newBeacon: [String:Beacon] = [:]
               
               newBeacon["\(beacon.uuid):\(beacon.major):\(beacon.minor)"] = beacon
               
               newBeacons.append(newBeacon)
           }
           
           // group all identical beacons under the unique key
           let groupedBeacons = newBeacons.group(by: {$0.keys.first!})
           
           var youngestBeaconInWindow: Beacon?
           var beaconsPerWindow : [Beacon] = []
           
           for beaconGroup in groupedBeacons {
               
               let sortedBeaconGroup = beaconGroup.value.sorted(by: {
                   
                   let value1 = $0.first!.value
                   let value2 = $1.first!.value
                   
                   return value1.timeIntervalSinceBootTime < value2.timeIntervalSinceBootTime
               })
               
               youngestBeaconInWindow = sortedBeaconGroup[0].values.first
               
               beaconsPerWindow.append(youngestBeaconInWindow!)
           }
           
           if let maxObservations = stateStore.state.locationSettingsState.currentLocationState?.currentBeaconState?.filterMaxObservations {
               
               var sortedValues = beaconsPerWindow.sorted(by: {$0.rssi > $1.rssi})
               
               if (sortedValues.count > Int(maxObservations)) {
                   sortedValues = Array(sortedValues.prefix(Int(maxObservations)))
               }
               
               for beacon in sortedValues {
                   
                   delegate?.receivediBeaconInfo(proximityUUID: UUID(uuidString: beacon.uuid as String)!,
                                                 major: Int(beacon.major),
                                                 minor: Int(beacon.minor),
                                                 proximity: Int(beacon.proximity),
                                                 accuracy: beacon.accuracy,
                                                 rssi: Int(beacon.rssi),
                                                 timestamp: beacon.timeIntervalSinceBootTime)
               }
           }
       }
       
       func processEddystoneBeaconTable() {
           
           countEddystoneBeacons()
           
           guard let beaconsUnwrapped = getAllEddystoneBeaconsAndDelete() else {
               return
           }
           
           Log.debug("\(beaconsUnwrapped.count) fetched from Eddystone beacons table")
           
           // create a key / value list that creates a unquiqe key for each beacon.
           var newBeacons: [[String:EddystoneBeacon]] = []
           
           for beacon in beaconsUnwrapped {
               
               var newBeacon: [String:EddystoneBeacon] = [:]
               
               newBeacon["\(beacon.eid)"] = beacon
               
               newBeacons.append(newBeacon)
           }
           
           // group all identical beacons under the unique key
           let groupedBeacons = newBeacons.group(by: {$0.keys.first!})
           
           var youngestBeaconInWindow: EddystoneBeacon?
           var beaconsPerWindow : [EddystoneBeacon] = []
           
           for beaconGroup in groupedBeacons {
               
               let sortedBeaconGroup = beaconGroup.value.sorted(by: {
                   
                   let value1 = $0.first!.value
                   let value2 = $1.first!.value
                   
                   return value1.timeIntervalSinceBootTime < value2.timeIntervalSinceBootTime
               })
               
               youngestBeaconInWindow = sortedBeaconGroup[0].values.first
               
               beaconsPerWindow.append(youngestBeaconInWindow!)
               Log.verbose("Youngest beacon in window: \(String(describing: youngestBeaconInWindow))")
           }
           
           if let maxObservations = stateStore.state.locationSettingsState.currentLocationState?.currentBeaconState?.filterMaxObservations {
               
               var sortedValues = beaconsPerWindow.sorted(by: {$0.rssi > $1.rssi})
               
               if (sortedValues.count > Int(maxObservations)) {
                   sortedValues = Array(sortedValues.prefix(Int(maxObservations)))
               }
               
               for beacon in sortedValues {
                   delegate?.receivedEddystoneBeaconInfo(eid: beacon.eid, tx: Int(beacon.tx), rssi: Int(beacon.rssi), timestamp: beacon.timeIntervalSinceBootTime)
               }
           }
       }
}
