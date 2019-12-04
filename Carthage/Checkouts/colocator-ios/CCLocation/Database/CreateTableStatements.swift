//
//  CreateTableStatements.swift
//  CCLocation
//
//  Created by Mobile Developer on 22/08/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation

extension Beacon : SQLTable {
    static var createStatement: String {
        return """
        CREATE TABLE IF NOT EXISTS \(CCLocationTables.kIBeaconMessagesTable) (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        UUID TEXT,
        MAJOR INTEGER,
        MINOR INTEGER,
        PROXIMITY INTEGER,
        ACCURACY REAL,
        RSSI INTEGER,
        TIMEINTERVAL REAL
        );
        """
    }
}

extension EddystoneBeacon : SQLTable {
    static var createStatement: String {
        return """
        CREATE TABLE IF NOT EXISTS \(CCLocationTables.kEddystoneBeaconMessagesTable) (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        EID TEXT,
        TX INTEGER,
        RSSI INTEGER,
        TIMEINTERVAL REAL
        );
        """
    }
}

extension CCMessage : SQLTable {
    static var createStatement: String {
        return """
        CREATE TABLE IF NOT EXISTS \(CCLocationTables.kMessagesTable) (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        OBSERVATION BLOB
        );
        """
    }
}
