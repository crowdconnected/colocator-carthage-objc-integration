//
//  CCRequestMessaging+DatabaseOperations.swift
//  CCLocation
//
//  Created by Mobile Developer on 03/07/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation

// Extension Database Operations

extension CCRequestMessaging {
    
    func openMessagesDatabase() {
        // Get the library directory
        let dirPaths = NSSearchPathForDirectoriesInDomains (.libraryDirectory, .userDomainMask, true)
        
        let docsDir = dirPaths[0]
        
        // Build the path to the database file
        let messageDBPath = URL.init(string: docsDir)?.appendingPathComponent(messagesDBName).absoluteString
        
        guard let messageDBPathStringUnwrapped = messageDBPath else {
            Log.error("[Colocator] Unable to observation messages database path")
            return
        }
        
        do {
            messagesDB = try SQLiteDatabase.open(path: messageDBPathStringUnwrapped)
            Log.debug("Successfully opened connection to observation messages database.")
        } catch SQLiteError.OpenDatabase(let message) {
            Log.error("[Colocator] Unable to open observation messages database. \(message)")
        } catch {
            Log.error("[Colocator] An unexpected error was thrown, when trying to open a connection to observation messages database")
        }
    }
    
    func createCCMesageTable() {
        do {
            try messagesDB.createTable(table: CCMessage.self)
        } catch {
            Log.error("[Colocator] Message database error: \(messagesDB.errorMessage)")
        }
    }
    
    func insertMessageInLocalDatabase(message: Data) {
        Log.verbose("Pushing new message into message queue")
        
        if let database = self.messagesDB {
            do {
                try database.insertMessage(ccMessage: CCMessage.init(observation: message))
            } catch SQLiteError.Prepare(let error) {
                Log.error("[Colocator] SQL Prepare Error: \(error)")
            } catch {
                Log.error("[Colocator] Error while executing messagesDB.insertMessage \(error)")
            }
        }
    }
    
    func popMessagesFromLocalDatabase(maxMessagesToReturn: Int) -> [Data] {
        var popMessages = [Data]()
        
        if let database = self.messagesDB {
            do {
                popMessages = try database.popMessages(num: maxMessagesToReturn)
            } catch SQLiteError.Prepare(let error) {
                Log.error("[Colocator] SQL Prepare Error: \(error)")
            } catch {
                Log.error("[Colocator] Error while executing messagesDB.popMessage \(error)")
            }
        }
        return popMessages
    }
    
    func getMessageCount() -> Int {
        var count: Int = -1
        
        do {
            if self.messagesDB == nil {
                return count
            }
            count = try self.messagesDB.count(table: CCLocationTables.kMessagesTable)
        } catch SQLiteError.Prepare(let error) {
            Log.error("[Colocator] SQL Prepare Error: \(error)")
        } catch {
            Log.error("[Colocator] Error while executing messagesDB.count \(error)")
        }
        
        return count
    }
}

