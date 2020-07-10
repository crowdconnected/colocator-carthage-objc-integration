//
//  SQLiteDatabase.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 08/03/2018.
//  Copyright © 2018 Crowd Connected. All rights reserved.
//

import Foundation
import SQLite3

protocol SQLTable {
    static var createStatement: String { get }
}

struct SQLiteConstants {
    static let kBeginImmediateTransactionCommand = "BEGIN IMMEDIATE TRANSACTION"
    static let kcommitTransaction = "COMMIT TRANSACTION"
    static let kFailedDeleteMessage = "Failed to delete message record from database"
}

class SQLiteDatabase {
    
    var messagesBuffer : [CCMessage] = [CCMessage] ()
    var eddystoneBeaconBuffer : [EddystoneBeacon] = [EddystoneBeacon] ()
    var ibeaconBeaconBuffer : [Beacon] = [Beacon] ()
    
    weak var messagesBufferClearTimer : Timer?
    let constants = SQLiteConstants.self
    
    let serialMessageDatabaseQueue = DispatchQueue(label: "com.crowdConnected.serielMessageDatabaseQueue")
    let serialiBeaconDatabaseQueue = DispatchQueue(label: "com.crowdConnected.serieliBeaconDatabaseQueue")
    let serialEddystoneDatabaseQueue = DispatchQueue(label: "com.crowdConnected.EddystoneDatabaseQueue")
    
    let dbPointer: OpaquePointer?
    
    var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    public var areMessagesCounted = false
    public var lastCountForMessagesTable = -2
    
    fileprivate init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
        messagesBufferClearTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1),
                                                        target: self,
                                                        selector: #selector(clearBuffers),
                                                        userInfo: nil,
                                                        repeats: true)
    }
    
    deinit {
        if messagesBufferClearTimer != nil {
            messagesBufferClearTimer?.invalidate()
            messagesBufferClearTimer = nil
        }
        sqlite3_close(dbPointer)
    }
    
    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer? = nil
        if sqlite3_open_v2(path, &db, SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, nil) == SQLITE_OK {
            return SQLiteDatabase(dbPointer: db)
        } else {
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String.init(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
    
    func close() {
        if messagesBufferClearTimer != nil {
            messagesBufferClearTimer?.invalidate()
            messagesBufferClearTimer = nil
        }
        sqlite3_close(dbPointer)
    }
    
    @objc func clearBuffers() throws {
        try insertBundlediBeacons()
        try insertBundledMessages()
        try insertBundledEddystoneBeacons()
    }
}

// MARK: - Prepare & Create

extension SQLiteDatabase {
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        return statement
    }

    func createTable(table: SQLTable.Type) throws {
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        
        defer {
            sqlite3_finalize(createTableStatement)
        }
        
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
}

//MARK: - Get Beacons & Delete

extension SQLiteDatabase {
    
    func getAllBeaconsAndDelete() throws -> [Beacon]? {
        let resultBeacons = try serialiBeaconDatabaseQueue.sync { () -> [Beacon]? in
            var beacons:[Beacon]?
            
            do {
                beacons = try getAllBeacons()
            } catch SQLiteError.Prepare(let message) {
                throw SQLiteError.Prepare(message: message)
            }
            
            do {
                try deleteBeacons(beaconTable: CCLocationTables.kIBeaconMessagesTable)
            } catch SQLiteError.Prepare(let message) {
                throw SQLiteError.Prepare(message: message)
            }
            
            return beacons
        }
        return resultBeacons
    }

    func getAllEddystoneBeaconsAndDelete() throws -> [EddystoneBeacon]? {
        let resultBeacons = try serialEddystoneDatabaseQueue.sync { () -> [EddystoneBeacon]? in
            var beacons:[EddystoneBeacon]?
            
            do {
                beacons = try getAllEddystoneBeacons()
            } catch SQLiteError.Prepare(let message) {
                throw SQLiteError.Prepare(message: message)
            }
             
            do {
                try deleteBeacons(beaconTable: CCLocationTables.kEddystoneBeaconMessagesTable)
            } catch SQLiteError.Prepare(let message) {
                throw SQLiteError.Prepare(message: message)
            }
            
            return beacons
        }
        
        return resultBeacons
    }
}

// MARK: - Count & Increment

extension SQLiteDatabase {
    
    func count(table: String) throws -> Int {
        if table == CCLocationTables.kMessagesTable && areMessagesCounted {
            return lastCountForMessagesTable
        }
        
        var count: Int = -1
        
        let querySql = "SELECT COUNT(*) FROM " + table + ";"
        
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        while(sqlite3_step(queryStatement) == SQLITE_ROW)
        {
            count = Int(sqlite3_column_int(queryStatement, 0));
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        if table == CCLocationTables.kMessagesTable {
            lastCountForMessagesTable = count
            areMessagesCounted = true
        }
       
        return count
    }
    
    func saveResetAutoincrement(table: String) throws {
        if try count(table: table) == 0 {
            do {
                try saveResetAutoincrementEmptyTable(table: table)
            } catch {
                Log.warning("Failed to save and autoincrement table \(table) in local database")
            }
        }
    }
    
    func saveResetAutoincrementEmptyTable(table: String) throws {
        areMessagesCounted = false
        
        let resetAutoincrementSql = "DELETE FROM sqlite_sequence WHERE name = '\(table)';"
            
        guard let resetAutoincrementStatement = try? prepareStatement(sql: resetAutoincrementSql) else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
            
        defer {
            sqlite3_finalize(resetAutoincrementStatement)
        }
            
        guard sqlite3_step(resetAutoincrementStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
}
