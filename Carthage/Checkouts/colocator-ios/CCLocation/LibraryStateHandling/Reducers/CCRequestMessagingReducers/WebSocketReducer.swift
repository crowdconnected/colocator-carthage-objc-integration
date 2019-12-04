//
//  WebSocketReducer.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 29/07/2017.
//  Copyright © 2017 Crowd Connected. All rights reserved.
//

import ReSwift

func webSocketReducer (action: Action, state: WebSocketState?) -> WebSocketState {
    var state = state ?? WebSocketState(connectionState: nil)
    
    if let webSocketAction = action as? WebSocketAction {
         state.connectionState = webSocketAction.connectionState
    }
    
    return state
}
