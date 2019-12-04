//
//  CCRequestMessagingState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 06/08/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import Foundation
import ReSwift

public struct CCRequestMessagingState: StateType, AutoEquatable {
    let webSocketState: WebSocketState?
    var radiosilenceTimerState: TimerState?
    let libraryTimeState: LibraryTimeState?
    var capabilityState: CapabilityState?
}
