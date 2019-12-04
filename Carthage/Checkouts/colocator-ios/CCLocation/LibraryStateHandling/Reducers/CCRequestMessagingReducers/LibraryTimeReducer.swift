//
//  LibraryTimeReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 09/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

private struct LibraryTimeReducerConstants {
    static let userDefaultsLibraryTimeKey = "libraryTimeKey"
}

private typealias L = LibraryTimeReducerConstants

func libraryTimeReducer (action: Action, state: LibraryTimeState?) -> LibraryTimeState {
    
    var libraryTimeState = LibraryTimeState(lastTrueTime: nil, bootTimeIntervalAtLastTrueTime: nil, systemTimeAtLastTrueTime: nil, lastRebootTime: nil)
    
    if let loadedLibraryTimeState = getLibraryTimeFromUserDefaults() {
        libraryTimeState = loadedLibraryTimeState
    }
    
    var state = state ?? libraryTimeState
    
    if let newTruetimeReceivedAction = action as? NewTruetimeReceivedAction {
        state.lastTrueTime = newTruetimeReceivedAction.lastTrueTime
        state.bootTimeIntervalAtLastTrueTime = newTruetimeReceivedAction.bootTimeIntervalAtLastTrueTime
        state.systemTimeAtLastTrueTime = newTruetimeReceivedAction.systemTimeAtLastTrueTime
        state.lastRebootTime = newTruetimeReceivedAction.lastRebootTime
        
        saveLibraryTimeToUserDefaults(libraryTimeState: state)
    }
    
    return state
}

func getLibraryTimeFromUserDefaults () -> LibraryTimeState? {
    
    let userDefaults = UserDefaults.standard
    var libraryTimeState: LibraryTimeState?

    if let dictionary = userDefaults.dictionary(forKey: L.userDefaultsLibraryTimeKey){
        
        if libraryTimeState == nil {
            libraryTimeState = LibraryTimeState(lastTrueTime: nil, bootTimeIntervalAtLastTrueTime: nil, systemTimeAtLastTrueTime: nil, lastRebootTime: nil)
        }
        
        libraryTimeState?.lastTrueTime = Date(timeIntervalSince1970: TimeInterval((dictionary["lastTrueTime"] as? Double)!))

        libraryTimeState?.bootTimeIntervalAtLastTrueTime = TimeInterval((dictionary["bootTimeIntervalAtLastTrueTime"] as? Double)!)
        libraryTimeState?.systemTimeAtLastTrueTime = Date(timeIntervalSince1970: TimeInterval((dictionary["systemTimeAtLastTrueTime"] as? Double)!))
        libraryTimeState?.lastRebootTime = Date(timeIntervalSince1970: TimeInterval((dictionary["lastRebootTime"] as? Double)!))
    }

    return libraryTimeState
}

func saveLibraryTimeToUserDefaults (libraryTimeState: LibraryTimeState?){
    guard let libraryTimeState = libraryTimeState else
    {
        return
    }
    
    let userDefaults = UserDefaults.standard

    var dictionary = [String:Double]()
    
    if let lastTrueTime = libraryTimeState.lastTrueTime {
        dictionary["lastTrueTime"] = lastTrueTime.timeIntervalSince1970
    }
    
    if let bootTimeAtLastTrueTime = libraryTimeState.bootTimeIntervalAtLastTrueTime {
        dictionary["bootTimeIntervalAtLastTrueTime"] = bootTimeAtLastTrueTime
    }
    
    if let systemTimeAtLastTrueTime = libraryTimeState.systemTimeAtLastTrueTime {
        dictionary["systemTimeAtLastTrueTime"] = systemTimeAtLastTrueTime.timeIntervalSince1970
    }

    if let lastRebootTime = libraryTimeState.lastRebootTime {
        dictionary["lastRebootTime"] = lastRebootTime.timeIntervalSince1970
    }

    userDefaults.set(dictionary, forKey: L.userDefaultsLibraryTimeKey)

}
