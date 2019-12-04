//
//  CCRequestMessaging+RequestLocation.swift
//  CCLocation
//
//  Created by Mobile Developer on 03/09/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation

//  case single = 1
//  case ongoing = 2
//  case stop = 3
        
extension CCRequestMessaging {

    func sendLocationRequestMessage(type: Int) {
        guard type >= 1, type <= 3 else {
            return
        }
        
        var clientMessage = Messaging_ClientMessage()
        var requestLocationMessage = Messaging_ClientLocationRequest()

        requestLocationMessage.type = Messaging_ClientLocationRequest.TypeEnum(rawValue: type)!
        clientMessage.locationRequest = requestLocationMessage
        
        Log.verbose("Request location message build: \(clientMessage)")
        
        if let data = try? clientMessage.serializedData() {
            sendOrQueueClientMessage(data: data, messageType: .urgent)
        }
    }
}
