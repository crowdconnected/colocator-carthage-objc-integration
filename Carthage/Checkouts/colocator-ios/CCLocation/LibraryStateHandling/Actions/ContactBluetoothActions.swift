//
//  ContactActions.swift
//  CCLocation
//
//  Created by TCode on 15/06/2020.
//  Copyright © 2020 Crowd Connected. All rights reserved.
//

import ReSwift

struct ContactBluetoothStateChangedAction: Action {
    var isEnabled: Bool?
    var serviceUUID: String?
    var scanInterval: UInt64?
    var scanDuration: UInt64?
    var advertiseInterval: UInt64?
    var advertiseDuration: UInt64?
}

struct DisableContactBluetoothAction: Action {}
