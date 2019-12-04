//
//  InertiaState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 07/06/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import ReSwift

public struct InertialState: StateType, AutoEquatable {
    var isEnabled: Bool?
    var interval: UInt32?
    
    init(isEnabled: Bool?,
         interval: UInt32?) {
        
        self.isEnabled = isEnabled
        self.interval = interval
    }
}
