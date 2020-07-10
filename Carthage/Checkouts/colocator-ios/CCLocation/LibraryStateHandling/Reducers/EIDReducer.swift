//
//  EIDReducer.swift
//  CCLocation
//
//  Created by TCode on 15/06/2020.
//  Copyright © 2020 Crowd Connected. All rights reserved.
//

import ReSwift

struct EIDReducerConstants {
    static let userDefaultsEIDKey = "userDefaultsEIDKey"
    static let secretKey = "EIDsecretKey"
    static let kKey = "eidK"
    static let clockOffsetKey = "clockOffset"
}

private typealias E = EIDReducerConstants

func eidReducer(action: Action, state: EIDState?) -> EIDState {
    var state = EIDState(secret: "", k: 0, clockOffset: 0)
    
    if let loadedEIDState = getEIDStateFromUserDefaults() {
        state = loadedEIDState
    }
    
    switch action {
    case let eidStateChangedAction as EIDStateChangedAction:
        state.secret = eidStateChangedAction.secret
        state.k = eidStateChangedAction.k
        state.clockOffset = eidStateChangedAction.clockOffset
        
        saveEIDStateInUserDefaults(eidState: state)
        
    case _ as DisableEIDAction:
        //Even if the eid settings are not being sent, they should remain saved locally. Do NOT clean them from UserDefaults
        break
    default: break
    }
    
    return state
}

func getEIDStateFromUserDefaults() -> EIDState? {
    let userDefaults = UserDefaults.standard
    let dictionary = userDefaults.dictionary(forKey: E.userDefaultsEIDKey)
    
    if dictionary != nil {
        return EIDState(secret: userDefaults.value(forKey: E.secretKey) as? String,
                        k: dictionary?[E.kKey] as? UInt32,
                        clockOffset: dictionary?[E.clockOffsetKey] as? UInt32)
    } else {
        return nil
    }
}

func saveEIDStateInUserDefaults(eidState: EIDState?) {
    guard let eidState = eidState else {
        return
    }
    
    let userDefaults = UserDefaults.standard
    
    var dictionary = [String:UInt32]()
    
    if let secret = eidState.secret {
        userDefaults.set(secret, forKey: E.secretKey)
    }
    
    if let k = eidState.k {
        dictionary[E.kKey] = k
    }
    if let clockOffset = eidState.clockOffset {
        dictionary[E.clockOffsetKey] = clockOffset
    }
    
    userDefaults.set(dictionary, forKey: E.userDefaultsEIDKey)
}
