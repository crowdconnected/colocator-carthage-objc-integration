//
//  SQLiteDatabase+Get.swift
//  CCLocation
//
//  Created by Mobile Developer on 22/08/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation
import SQLite3

// Extension Get

extension SQLiteDatabase {
    
    // MARK: - Messages
    
    func popMessages(num: Int) throws -> [Data] {
        let data = try serialMessageDatabaseQueue.sync { () -> [Data] in
            
            var clientMessageData: Data
            var clientMessagesData: [Data] = [Data] ()
            var ids : [String] = [String] ()
            
            guard sqlite3_exec(dbPointer, constants.kBeginImmediateTransactionCommand, nil, nil, nil) == SQLITE_OK else  {
                throw SQLiteError.Exec(message: errorMessage)
            }
            
            let sql = "SELECT * FROM \(CCLocationTables.kMessagesTable) ORDER BY ID ASC LIMIT \(num);"
            let statement = try prepareStatement(sql: sql)
            
            while sqlite3_step(statement) == SQLITE_ROW {

                let observationBase64 = sqlite3_column_text(statement, 1)
                
                let string = String(cString: observationBase64!)
                                
                if let tempClientMessageData = Data(base64Encoded: string) {
                
                    clientMessageData = tempClientMessageData
                    clientMessagesData.append(clientMessageData)
                }

                let id = sqlite3_column_int(statement, 0)
                ids.append("\(id)")
            }
            
            sqlite3_reset(statement)
            
            let idsJoined = ids.joined(separator: ",")
            let deleteSql = "DELETE FROM \(CCLocationTables.kMessagesTable) WHERE ID IN (\(idsJoined));"
            let deleteStatement = try prepareStatement(sql: deleteSql)
            
            guard sqlite3_step(deleteStatement) == SQLITE_DONE else {
                throw SQLiteError.Step(message: errorMessage)
            }
            
            guard sqlite3_finalize(statement) == SQLITE_OK else {
                throw SQLiteError.Finalise(message: errorMessage)
            }
            
            guard sqlite3_exec(dbPointer, constants.kcommitTransaction, nil, nil, nil) == SQLITE_OK else {
                throw SQLiteError.Exec(message: errorMessage)
            }
            
            let idsRemovedCount = ids.count
            if lastCountForMessagesTable >= idsRemovedCount && idsRemovedCount != 0 {
                lastCountForMessagesTable -= idsRemovedCount
            } else {
                areMessagesCounted = false
            }
            
            return clientMessagesData
        }
        
        return data
    }
    
    // MARK: - Beacons
    
    func getAllBeacons() throws -> [Beacon]? {
        let querySql = "SELECT * FROM \(CCLocationTables.kIBeaconMessagesTable) ORDER BY ID ASC;"
        var beacons:[Beacon]?
        
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            let uuid = sqlite3_column_text(queryStatement, 1)
            let major = sqlite3_column_int(queryStatement, 2)
            let minor = sqlite3_column_int(queryStatement, 3)
            let proxomity = sqlite3_column_int(queryStatement, 4)
            let accuracy = sqlite3_column_double(queryStatement, 5)
            let rssi = sqlite3_column_int(queryStatement, 6)
            let timeInterval = sqlite3_column_double(queryStatement, 7)
            
            let beacon = Beacon(uuid: String(cString: uuid!) as NSString, major: major, minor: minor, proximity: proxomity, accuracy: accuracy, rssi: rssi, timeIntervalSinceBootTime: timeInterval)
            
            if beacons == nil {
                beacons = []
            }
            
            beacons!.append(beacon)
        }
        
        return beacons
    }
    
    // MARK: - EddyStone Beacons
    
    func getAllEddystoneBeacons() throws -> [EddystoneBeacon]? {
        let querySql = "SELECT * FROM \(CCLocationTables.kEddystoneBeaconMessagesTable) ORDER BY ID ASC;"
        var beacons:[EddystoneBeacon]?
        
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            let eid = sqlite3_column_text(queryStatement, 1)
            let tx = sqlite3_column_int(queryStatement, 2)
            let rssi = sqlite3_column_int(queryStatement, 3)
            let timeInterval = sqlite3_column_double(queryStatement, 4)
            
            let beacon = EddystoneBeacon(eid: String(cString: eid!) as NSString, rssi: rssi, tx: tx, timeIntervalSinceBootTime: timeInterval)
            
            if beacons == nil {
                beacons = []
            }
            
            beacons!.append(beacon)
        }
        
        return beacons
    }
}
