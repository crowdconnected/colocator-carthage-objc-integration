//
//  ContactState.swift
//  CCLocation
//
//  Created by TCode on 15/06/2020.
//  Copyright © 2020 Crowd Connected. All rights reserved.
//

import ReSwift

public struct ContactState: StateType {
    var contactBluetoothState: ContactBluetoothState?
    var eidState: EIDState?
}
