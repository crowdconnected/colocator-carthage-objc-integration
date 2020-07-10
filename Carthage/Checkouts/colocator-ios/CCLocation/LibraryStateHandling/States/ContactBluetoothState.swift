//
//  ContactState.swift
//  CCLocation
//
//  Created by TCode on 15/06/2020.
//  Copyright © 2020 Crowd Connected. All rights reserved.
//

import ReSwift

public struct ContactBluetoothState: StateType, AutoEquatable {
    var isEnabled: Bool?
    var serviceUUID: String?
    var scanInterval: UInt64?
    var scanDuration: UInt64?
    var advertiseInterval: UInt64?
    var advertiseDuration: UInt64?
    
    init(isEnabled: Bool?,
         serviceUUID: String?,
         scanInterval: UInt64?,
         scanDuration: UInt64?,
         advertiseInterval: UInt64?,
         advertiseDuration: UInt64?) {
        
        self.isEnabled = isEnabled
        self.serviceUUID = serviceUUID
        self.scanInterval = scanInterval
        self.scanDuration = scanDuration
        self.advertiseInterval = advertiseInterval
        self.advertiseDuration = advertiseDuration
    }
}
