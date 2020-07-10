//
//  EIDActions.swift
//  CCLocation
//
//  Created by TCode on 15/06/2020.
//  Copyright © 2020 Crowd Connected. All rights reserved.
//

import ReSwift

struct EIDStateChangedAction: Action {
    var secret: String?
    var k: UInt32?
    var clockOffset: UInt32?
}

struct DisableEIDAction: Action {}
