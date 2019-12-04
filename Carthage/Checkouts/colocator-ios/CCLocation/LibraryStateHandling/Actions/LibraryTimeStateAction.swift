//
//  LibraryTimeStateAction.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 09/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

struct NewTruetimeReceivedAction: Action {
    var lastTrueTime: Date?
    var bootTimeIntervalAtLastTrueTime: TimeInterval?
    var systemTimeAtLastTrueTime: Date?
    var lastRebootTime: Date?
}
