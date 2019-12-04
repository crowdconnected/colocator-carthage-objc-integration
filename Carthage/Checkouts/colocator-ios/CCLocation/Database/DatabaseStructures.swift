//
//  DatabaseStructures.swift
//  CCLocation
//
//  Created by Mobile Developer on 22/08/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation

struct Beacon {
    let uuid: NSString
    let major: Int32
    let minor: Int32
    let proximity: Int32
    let accuracy: Double
    let rssi: Int32
    let timeIntervalSinceBootTime: Double
}

struct EddystoneBeacon {
    let eid: NSString
    let rssi: Int32
    let tx: Int32
    let timeIntervalSinceBootTime: Double
}

struct CCMessage {
    let observation: Data
}
