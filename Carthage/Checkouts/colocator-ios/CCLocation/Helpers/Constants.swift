//
//  Constants.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 06/03/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import Foundation

struct CCLocationTables {
    static let kIBeaconMessagesTable = "IBEACONMESSAGES"
    static let kEddystoneBeaconMessagesTable = "EDDYSTONEBEACONMESSAGES"
    static let kMessagesTable = "MESSAGES"
}

struct CCLocationMessageType {
    static let kSystemSettings = "SYSTEM_SETTINGS"
}

struct CCLocationConstants {
    static let kMaxQueueSize = 100000
}

struct CCSocketConstants {
    static let kLibraryVersionToReport = "2.4.1"
    static let kLastDeviceIDKey = "LastDeviceId"
    static let kMinDelay: Double = 1 * 1000
    static let kMaxDelay: Double = 60 * 60 * 1000
    static let kMaxCycleDelay: Double = 24 * 60 * 60 * 1000
    static let kWsPrefix = "wss://"
    static let kAliasKey = "Aliases"
}

struct TimerHandlingConstants {
    static let kMaxDifferenceAllowedBetweenSystemTimeAndBootTime: Double = 30
}

struct ColocatorManagerConstants {
    static let kMaxTimeSendingDataAtStop = 120 // seconds
}

struct CCRequestMessagingConstants {
    static let kMessageCounter = "messageCounterKey"
    static let kNotAvaialble = "Not Available"
}

struct CCInertialConstants {
    static let kBufferSize = 500 // do not make smaller than 50
    static let kCutOff = 100
}
