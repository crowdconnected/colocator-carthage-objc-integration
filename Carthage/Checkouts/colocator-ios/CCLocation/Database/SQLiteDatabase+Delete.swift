//
//  SQLiteDatabase+Delete.swift
//  CCLocation
//
//  Created by Mobile Developer on 22/08/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation
import SQLite3

// Extensions Delete

extension SQLiteDatabase {
    func deleteBeacons(beaconTable: String) throws {
        let deleteMessagesSQL = "DELETE FROM \(beaconTable);"
        
        guard let deleteMessagesStatement = try? prepareStatement(sql: deleteMessagesSQL) else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        defer {
            sqlite3_finalize(deleteMessagesStatement)
        }
        
        guard sqlite3_step(deleteMessagesStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        try saveResetAutoincrement(table: beaconTable)
    }
    
    func deleteMessages(messagesTable: String) throws {
        let deleteMessagesSQL = "DELETE FROM \(messagesTable);"
        
        guard let deleteMessagesStatement = try? prepareStatement(sql: deleteMessagesSQL) else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        defer {
            sqlite3_finalize(deleteMessagesStatement)
        }
        
        guard sqlite3_step(deleteMessagesStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        try saveResetAutoincrement(table: messagesTable)
    }
}
