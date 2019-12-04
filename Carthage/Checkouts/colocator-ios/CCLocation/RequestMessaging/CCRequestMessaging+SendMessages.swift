//
//  CCRequestMessaging+SendMessages.swift
//  CCLocation
//
//  Created by Mobile Developer on 03/07/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation

// Extension Send Messages

extension CCRequestMessaging {
    
    public func sendQueuedClientMessages(firstMessage: Data?) {
        if let newMessage = firstMessage {
            if self.getMessageCount() > 0 {
                insertMessageInLocalDatabase(message: newMessage)
                sendAllMessagesFromDatabase()
            } else {
                sendSingleMessage(firstMessage!)
            }
        } else {
            sendAllMessagesFromDatabase()
        }
    }
    
    private func sendAllMessagesFromDatabase() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let maxMessagesToReturn = 100
            var connectionState = self?.stateStore.state.ccRequestMessagingState.webSocketState?.connectionState
            
            let messageNumber = self?.getMessageCount() ?? -1
            Log.verbose ("\(messageNumber) Queued messages are available")
            
            while self?.getMessageCount() ?? -1 > 0 && connectionState == .online {
                connectionState = self?.stateStore.state.ccRequestMessagingState.webSocketState?.connectionState
                
                var compiledClientMessage = Messaging_ClientMessage()
                var backToQueueMessages = Messaging_ClientMessage()
                
                var tempMessageData: [Data]?
                var subMessageCounter: Int = 0
                
                while self?.getMessageCount() ?? -1 > 0 && subMessageCounter < maxMessagesToReturn {
                    tempMessageData = self?.popMessagesFromLocalDatabase(maxMessagesToReturn: maxMessagesToReturn)
                    
                    if let unwrappedTempMessageData = tempMessageData {
                        for tempMessage in unwrappedTempMessageData {
                            
                            let (newSubMessageCounter,
                                 newCompiledClientMessage,
                                 newBackToQueueMessages) = self?.handleMessageType(message: tempMessage,
                                                                                   subMessageInitialNumber: subMessageCounter,
                                                                                   compiledMessage: compiledClientMessage,
                                                                                   queueMessage: backToQueueMessages)
                                                            ?? (subMessageCounter,
                                                                Messaging_ClientMessage(),
                                                                Messaging_ClientMessage())
                            
                            subMessageCounter = newSubMessageCounter
                            compiledClientMessage = newCompiledClientMessage
                            backToQueueMessages = newBackToQueueMessages
                        }
                    }
                }
                
                self?.logMessageContent(compiledClientMessage, subMessageCounter: subMessageCounter)
                
                self?.handleMessageBackToQueue(backToQueueMessages)
                
                if let data = try? compiledClientMessage.serializedData(), data.count > 0 {
                    self?.setupSentTime(forMessage: &compiledClientMessage)
                    self?.sendMessageThroughSocket(compiledClientMessage)
                }
            }
        }
    }
    
    private func logMessageContent(_ message: Messaging_ClientMessage, subMessageCounter: Int) {
        Log.debug("Compiled \(subMessageCounter) message(s)")
        
        if message.locationMessage.count > 0 {
            let geoMsg = message.locationMessage[0]
            let geoData = try? geoMsg.serializedData()
            
            Log.verbose("""
                Compiled geoMsg: \(geoData?.count ?? -1) and byte array
                \(geoData?.hexEncodedString() ?? CCRequestMessagingConstants.kNotAvaialble)
                """)
        }
        
        if message.circularGeoFenceEvents.count > 0 {
            let geofenceMsg = message.circularGeoFenceEvents[0]
            let geofenceData = try? geofenceMsg.serializedData()
            
            Log.verbose("""
                Compiled geofenceMsg: \(geofenceData?.count ?? -1) and byte array
                \(geofenceData?.hexEncodedString() ?? CCRequestMessagingConstants.kNotAvaialble)
                """)
        }
        
        if message.bluetoothMessage.count > 0 {
            let blMsg = message.bluetoothMessage[0]
            let blData = try? blMsg.serializedData()
            
            Log.verbose("""
                Compiled bluetooth message: \(blData?.count ?? -1) and byte array
                \(blData?.hexEncodedString() ?? CCRequestMessagingConstants.kNotAvaialble))
                """)
        }
        
        for beacon in message.ibeaconMessage {
            Log.verbose("Sending beacons \(message.ibeaconMessage.count) with \(beacon)")
        }
        
        if message.alias.count > 0 {
            let alMsg = message.alias[0]
            let alData = try? alMsg.serializedData()
            
            Log.verbose("""
                Compiled alias message: \(alData?.count ?? -1)  and byte array
                \(alData?.hexEncodedString() ?? CCRequestMessagingConstants.kNotAvaialble))
                """)
        }
    }
    
    func sendSingleMessage(_ message: Data) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            var (_,
                 compiledClientMessage,
                 backToQueueMessage) = self?.handleMessageType(message: message) ?? (0,
                                                                                     Messaging_ClientMessage(),
                                                                                     Messaging_ClientMessage())
            
            self?.handleMessageBackToQueue(backToQueueMessage)
        
            if let data = try? compiledClientMessage.serializedData(), data.count > 0 {
                self?.setupSentTime(forMessage: &compiledClientMessage)
                self?.sendMessageThroughSocket(compiledClientMessage)
            }
        }
    }
    
    private func handleMessageBackToQueue(_ message: Messaging_ClientMessage) {
        if let backToQueueData = try? message.serializedData() {
            if backToQueueData.count > 0 {
                insertMessageInLocalDatabase(message: backToQueueData)
                Log.debug("Had to split a client message into two, pushing \(backToQueueData.count) unsent messages back to the Queue")
            }
        } else {
            Log.error("[Colocator] Couldn't serialize back to queue data")
        }
    }
    
    private func setupSentTime(forMessage message: inout Messaging_ClientMessage) {
        let isRebootTimeSame = self.timeHandling.isRebootTimeSame(stateStore: stateStore, ccSocket: ccSocket)
        let currentTimePeriod = TimeHandling.getCurrentTimePeriodSince1970(stateStore: stateStore)
        
        if isRebootTimeSame && currentTimePeriod != nil {
            message.sentTime = UInt64(currentTimePeriod! * 1000)
            
            if message.sentTime == 0 {
                Log.error("[Colocator] Client message timestamp 0! \(message)")
            }
        }
    }
    
    private func sendMessageThroughSocket(_ message: Messaging_ClientMessage) {
        if let messageData = try? message.serializedData() {
            Log.verbose("Sending \(messageData.count) bytes of compiled instant message data")
            
            ccSocket?.sendWebSocketMessage(data: messageData)
            
            Log.info("[Colocator]  Sent message to server")
        }
    }
}
