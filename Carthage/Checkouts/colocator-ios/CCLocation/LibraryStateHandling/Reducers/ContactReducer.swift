//
//  ContactReducer.swift
//  CCLocation
//
//  Created by TCode on 15/06/2020.
//  Copyright © 2020 Crowd Connected. All rights reserved.
//

import ReSwift

func contactReducer (action: Action, state: ContactState?) -> ContactState? {
    
    let state = ContactState (contactBluetoothState: contactBluetoothReducer(action: action, state: state?.contactBluetoothState),
                              eidState: eidReducer(action: action, state: state?.eidState))
    
    return state
}
