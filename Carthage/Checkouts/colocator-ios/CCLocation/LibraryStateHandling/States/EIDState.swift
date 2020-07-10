//
//  EIDState.swift
//  CCLocation
//
//  Created by TCode on 15/06/2020.
//  Copyright © 2020 Crowd Connected. All rights reserved.
//


import ReSwift

public struct EIDState: StateType, AutoEquatable {
    var secret: String?
    var k: UInt32?
    var clockOffset: UInt32?
    
    init(secret: String?,
         k: UInt32?,
         clockOffset: UInt32?) {
        
        self.secret = secret
        self.k = k
        self.clockOffset = clockOffset
    }
}
