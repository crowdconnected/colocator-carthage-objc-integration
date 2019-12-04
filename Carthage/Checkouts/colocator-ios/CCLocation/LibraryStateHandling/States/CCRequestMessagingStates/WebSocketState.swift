//
//  WebSocketState.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

enum ConnectionState{
    case online
    case offline
}

public struct WebSocketState: StateType, AutoEquatable {
    var connectionState: ConnectionState?
    
    init(connectionState: ConnectionState?) {
        self.connectionState = connectionState
    }
}
