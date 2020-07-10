//
//  CCRequestMessaging+AnalyzeMessages.swift
//  CCLocation
//
//  Created by Mobile Developer on 04/07/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation

// Extension Analyze Messages

extension CCRequestMessaging {
    
    public func handleMessageType(message: Data,
                                  subMessageInitialNumber: Int = 0,
                                  compiledMessage: Messaging_ClientMessage = Messaging_ClientMessage(),
                                  queueMessage: Messaging_ClientMessage = Messaging_ClientMessage()) -> (Int, Messaging_ClientMessage, Messaging_ClientMessage) {
        var compiledClientMessage = compiledMessage
        var backToQueueMessages = queueMessage
        
        var subMessageCounter: Int = subMessageInitialNumber
        var tempClientMessage: Messaging_ClientMessage?
        
        tempClientMessage = try? Messaging_ClientMessage(serializedData: message)
        
        if tempClientMessage!.locationMessage.count > 0 {
            Log.debug ("Found location messages in queue")
            
            let (actualizedSubmessageCounter, toCompileMessages, toQueueMessages) =
                self.checkLocationTypeMessages(tempClientMessage!.locationMessage, subMessageCounter: subMessageCounter)
            
            subMessageCounter = actualizedSubmessageCounter
            
            if self.surveyMode == true { compiledClientMessage.surveryMode = true }
            compiledClientMessage.locationMessage.append(contentsOf: toCompileMessages)
            backToQueueMessages.locationMessage.append(contentsOf: toQueueMessages)
        }
        
        if tempClientMessage!.circularGeoFenceEvents.count > 0 {
            Log.debug ("Found geofence event messages in queue")
            
            let (actualizedSubmessageCounter, toCompileMessages, toQueueMessages) =
                self.checkGeofenceTypeMessages(tempClientMessage!.circularGeoFenceEvents, subMessageCounter: subMessageCounter)
            
            subMessageCounter = actualizedSubmessageCounter
            
            if self.surveyMode == true { compiledClientMessage.surveryMode = true }
            compiledClientMessage.circularGeoFenceEvents.append(contentsOf: toCompileMessages)
            backToQueueMessages.circularGeoFenceEvents.append(contentsOf: toQueueMessages)
        }
        
        if tempClientMessage!.step.count > 0 {
            Log.debug ("Found step messages in queue")
            
            let (actualizedSubmessageCounter, toCompileMessages, toQueueMessages) =
                self.checkStepsTypeMessages(tempClientMessage!.step, subMessageCounter: subMessageCounter)
            
            subMessageCounter = actualizedSubmessageCounter
            
            if self.surveyMode == true { compiledClientMessage.surveryMode = true }
            compiledClientMessage.step.append(contentsOf: toCompileMessages)
            backToQueueMessages.step.append(contentsOf: toQueueMessages)
        }
        
        if tempClientMessage!.bluetoothMessage.count > 0 {
            Log.debug ("Found bluetooth messages in queue")
            
            let (actualizedSubmessageCounter, toCompileMessages, toQueueMessages) =
                self.checkBluetoothTypeMessages(tempClientMessage!.bluetoothMessage, subMessageCounter: subMessageCounter)
            
            subMessageCounter = actualizedSubmessageCounter
            
            if self.surveyMode == true { compiledClientMessage.surveryMode = true }
            compiledClientMessage.bluetoothMessage.append(contentsOf: toCompileMessages)
            backToQueueMessages.bluetoothMessage.append(contentsOf: toQueueMessages)
        }
        
        if tempClientMessage!.ibeaconMessage.count > 0 {
            Log.debug ("Found ibeacon messages in queue")
            
            let (actualizedSubmessageCounter, toCompileMessages, toQueueMessages) =
                self.checkiBeaconTypeMessages(tempClientMessage!.ibeaconMessage, subMessageCounter: subMessageCounter)
            
            subMessageCounter = actualizedSubmessageCounter
            
            if self.surveyMode == true { compiledClientMessage.surveryMode = true }
            compiledClientMessage.ibeaconMessage.append(contentsOf: toCompileMessages)
            backToQueueMessages.ibeaconMessage.append(contentsOf: toQueueMessages)
        }
        
        if tempClientMessage!.eddystonemessage.count > 0 {
            Log.debug ("Found eddystone messages in queue")
            
            let (actualizedSubmessageCounter, toCompileMessages, toQueueMessages) =
                self.checkEddystoneTypeMessages(tempClientMessage!.eddystonemessage, subMessageCounter: subMessageCounter)
            
            subMessageCounter = actualizedSubmessageCounter
            
            if self.surveyMode == true { compiledClientMessage.surveryMode = true }
            compiledClientMessage.eddystonemessage.append(contentsOf: toCompileMessages)
            backToQueueMessages.eddystonemessage.append(contentsOf: toQueueMessages)
        }
        
        if tempClientMessage!.alias.count > 0 {
            Log.debug ("Found alias messages in queue")
            
            let (actualizedSubmessageCounter, toCompileMessages, toQueueMessages) =
                self.checkAliasesTypeMessages(tempClientMessage!.alias, subMessageCounter: subMessageCounter)
            
            subMessageCounter = actualizedSubmessageCounter
            
            if self.surveyMode == true { compiledClientMessage.surveryMode = true }
            compiledClientMessage.alias.append(contentsOf: toCompileMessages)
            backToQueueMessages.alias.append(contentsOf: toQueueMessages)
        }
        
        if tempClientMessage!.hasIosCapability {
            Log.debug ("Found iosCapability messages in queue")
            
            let (actualizedSubmessageCounter, toCompileMessage, toQueueMessage) =
                self.checkMessageIOSCapability(tempClientMessage!.iosCapability, subMessageCounter: subMessageCounter)
            
            subMessageCounter = actualizedSubmessageCounter
            if let newCompileMessage = toCompileMessage {
                if self.surveyMode == true { compiledClientMessage.surveryMode = true }
                compiledClientMessage.iosCapability = newCompileMessage
            }
            if let newQueueMessage = toQueueMessage {
                backToQueueMessages.iosCapability = newQueueMessage
            }
        }
        
        if tempClientMessage!.hasLocationRequest {
            Log.debug ("Found locationRequest messages in queue")
            
            let (actualizedSubmessageCounter, toCompileMessage, toQueueMessage) =
                self.checkMessageLocationRequest(tempClientMessage!.locationRequest, subMessageCounter: subMessageCounter)
            
            subMessageCounter = actualizedSubmessageCounter
            if let newCompileMessage = toCompileMessage {
                if self.surveyMode == true { compiledClientMessage.surveryMode = true }
                compiledClientMessage.locationRequest = newCompileMessage
            }
            if let newQueueMessage = toQueueMessage {
                backToQueueMessages.locationRequest = newQueueMessage
            }
        }
        
        if tempClientMessage!.contactMessage.count > 0 {
            Log.debug("Found contact message in queue")
            
            let (actualizedSubmessageCounter, toCompileMessages, toQueueMessages) = self.checkContactTypeMessages(tempClientMessage!.contactMessage,
                                                                                                                subMessageCounter: subMessageCounter)
            subMessageCounter = actualizedSubmessageCounter
            
            if self.surveyMode == true { compiledClientMessage.surveryMode = true }
            compiledClientMessage.contactMessage.append(contentsOf: toCompileMessages)
            backToQueueMessages.contactMessage.append(contentsOf: toQueueMessages)
        }
        
        if let newBatteryMessage = self.checkNewBatteryLevelTypeMessage() {
            Log.debug ("Found new battery level messages in queue")
            
            if self.surveyMode == true { compiledClientMessage.surveryMode = true }
            compiledClientMessage.battery = newBatteryMessage
        }
        
        return (subMessageCounter, compiledClientMessage, backToQueueMessages)
    }
    
    public func checkLocationTypeMessages(_ messages: [Messaging_LocationMessage],
                                          subMessageCounter: Int) -> (Int, [Messaging_LocationMessage], [Messaging_LocationMessage]) {
        var clientMessagesToCompile = [Messaging_LocationMessage]()
        var messagesToQueue = [Messaging_LocationMessage]()
        var subMessageNo = subMessageCounter
        
        for tempLocationMessage in messages {
            var locationMessage = Messaging_LocationMessage()
            
            locationMessage.longitude = tempLocationMessage.longitude
            locationMessage.latitude = tempLocationMessage.latitude
            locationMessage.horizontalAccuracy = tempLocationMessage.horizontalAccuracy
            locationMessage.timestamp = tempLocationMessage.timestamp
            
            if tempLocationMessage.hasAltitude {
                locationMessage.altitude = tempLocationMessage.altitude
            }
            
            if subMessageNo >= 0 {
                clientMessagesToCompile.append(locationMessage)
            } else {
                messagesToQueue.append(locationMessage)
            }
            
            subMessageNo += 1
        }
        
        return (subMessageNo, clientMessagesToCompile, messagesToQueue)
    }
    
    public func checkGeofenceTypeMessages (_ messages: [Messaging_CircularGeoFenceEvent],
                                           subMessageCounter: Int) -> (Int, [Messaging_CircularGeoFenceEvent], [Messaging_CircularGeoFenceEvent]) {
        var clientMessagesToCompile = [Messaging_CircularGeoFenceEvent]()
        var messagesToQueue = [Messaging_CircularGeoFenceEvent]()
        var subMessageNo = subMessageCounter
        
        for tempGeofenceMessage in messages {
            var geofenceMessage = Messaging_CircularGeoFenceEvent()
            
            geofenceMessage.longitude = tempGeofenceMessage.longitude
            geofenceMessage.latitude = tempGeofenceMessage.latitude
            geofenceMessage.radius = tempGeofenceMessage.radius
            
            //TODO Add identifier and type later
            
            if subMessageNo >= 0 {
                clientMessagesToCompile.append(geofenceMessage)
            } else {
                messagesToQueue.append(geofenceMessage)
            }
            
            subMessageNo += 1
        }
        
        return (subMessageNo, clientMessagesToCompile, messagesToQueue)
    }
    
    public func checkStepsTypeMessages(_ messages: [Messaging_Step],
                                       subMessageCounter: Int) -> (Int, [Messaging_Step], [Messaging_Step]) {
        var clientMessagesToCompile = [Messaging_Step]()
        var messagesToQueue = [Messaging_Step]()
        var subMessageNo = subMessageCounter
        
        for tempStepMessage in messages {
            var stepMessage = Messaging_Step()
            
            stepMessage.timestamp = tempStepMessage.timestamp
            stepMessage.angle = tempStepMessage.angle
            
            if subMessageCounter >= 0 {
                clientMessagesToCompile.append(stepMessage)
            } else {
                messagesToQueue.append(stepMessage)
            }
            
            subMessageNo += 1
        }
        
        return (subMessageNo, clientMessagesToCompile, messagesToQueue)
    }
    
    public func checkBluetoothTypeMessages(_ messages: [Messaging_Bluetooth],
                                           subMessageCounter: Int) -> (Int, [Messaging_Bluetooth], [Messaging_Bluetooth]) {
        var clientMessagesToCompile = [Messaging_Bluetooth]()
        var messagesToQueue = [Messaging_Bluetooth]()
        var subMessageNo = subMessageCounter
        
        for tempBluetoothMessage in messages {
            var bluetoothMessage = Messaging_Bluetooth()
            
            bluetoothMessage.identifier = tempBluetoothMessage.identifier
            bluetoothMessage.rssi = tempBluetoothMessage.rssi
            bluetoothMessage.tx = tempBluetoothMessage.tx
            bluetoothMessage.timestamp = tempBluetoothMessage.timestamp
            
            if subMessageCounter >= 0 {
                clientMessagesToCompile.append(bluetoothMessage)
            } else {
                messagesToQueue.append(bluetoothMessage)
            }
            
            subMessageNo += 1
        }
        
        return (subMessageNo, clientMessagesToCompile, messagesToQueue)
    }
    
    public func checkiBeaconTypeMessages(_ messages: [Messaging_IBeacon],
                                         subMessageCounter: Int) -> (Int, [Messaging_IBeacon], [Messaging_IBeacon]) {
        var clientMessagesToCompile = [Messaging_IBeacon]()
        var messagesToQueue = [Messaging_IBeacon]()
        var subMessageNo = subMessageCounter
        
        for tempIbeaconMessage in messages {
            var ibeaconMessage = Messaging_IBeacon()
            
            ibeaconMessage.uuid = tempIbeaconMessage.uuid
            ibeaconMessage.major = tempIbeaconMessage.major
            ibeaconMessage.minor = tempIbeaconMessage.minor
            ibeaconMessage.rssi = tempIbeaconMessage.rssi
            ibeaconMessage.accuracy = tempIbeaconMessage.accuracy
            ibeaconMessage.timestamp = tempIbeaconMessage.timestamp
            ibeaconMessage.proximity = tempIbeaconMessage.proximity
            
            if subMessageCounter >= 0 {
                clientMessagesToCompile.append(ibeaconMessage)
            } else {
                messagesToQueue.append(ibeaconMessage)
            }
            
            subMessageNo += 1
        }
        
        return (subMessageNo, clientMessagesToCompile, messagesToQueue)
    }
    
    public func checkEddystoneTypeMessages(_ messages: [Messaging_EddystoneBeacon],
                                           subMessageCounter: Int) -> (Int, [Messaging_EddystoneBeacon], [Messaging_EddystoneBeacon]) {
        var clientMessagesToCompile = [Messaging_EddystoneBeacon]()
        var messagesToQueue = [Messaging_EddystoneBeacon]()
        var subMessageNo = subMessageCounter
        
        for tempEddyStoneMessage in messages {
            var eddyStoneMessage = Messaging_EddystoneBeacon()
            
            eddyStoneMessage.eid = tempEddyStoneMessage.eid
            eddyStoneMessage.rssi = tempEddyStoneMessage.rssi
            eddyStoneMessage.timestamp = tempEddyStoneMessage.timestamp
            eddyStoneMessage.tx = tempEddyStoneMessage.tx
            
            if subMessageCounter >= 0 {
                clientMessagesToCompile.append(eddyStoneMessage)
            } else {
                messagesToQueue.append(eddyStoneMessage)
            }
            
            subMessageNo += 1
        }
        
        return (subMessageNo, clientMessagesToCompile, messagesToQueue)
    }
    
    public func checkAliasesTypeMessages(_ messages: [Messaging_AliasMessage],
                                         subMessageCounter: Int) -> (Int, [Messaging_AliasMessage], [Messaging_AliasMessage]) {
        var clientMessagesToCompile = [Messaging_AliasMessage]()
        var messagesToQueue = [Messaging_AliasMessage]()
        var subMessageNo = subMessageCounter
        
        for tempAliasMessage in messages {
            var aliasMessage = Messaging_AliasMessage()
            
            aliasMessage.key = tempAliasMessage.key
            aliasMessage.value = tempAliasMessage.value
            
            if subMessageCounter >= 0 {
                clientMessagesToCompile.append(aliasMessage)
            } else {
                messagesToQueue.append(aliasMessage)
            }
            
            subMessageNo += 1
        }
        
        return (subMessageNo, clientMessagesToCompile, messagesToQueue)
    }
    
    public func checkMessageIOSCapability(_ message: Messaging_IosCapability,
                                          subMessageCounter: Int) -> (Int, Messaging_IosCapability?, Messaging_IosCapability?) {
        let subMessageNo = subMessageCounter
        var capabilityMessage = Messaging_IosCapability()
        let tempCapabilityMessage = message
        
        if tempCapabilityMessage.hasLocationServices {
            capabilityMessage.locationServices = tempCapabilityMessage.locationServices
        }
        if tempCapabilityMessage.hasLowPowerMode {
            capabilityMessage.lowPowerMode = tempCapabilityMessage.lowPowerMode
        }
        if tempCapabilityMessage.hasLocationAuthStatus {
            capabilityMessage.locationAuthStatus = tempCapabilityMessage.locationAuthStatus
        }
        if tempCapabilityMessage.hasBluetoothHardware {
            capabilityMessage.bluetoothHardware = tempCapabilityMessage.bluetoothHardware
        }
        if tempCapabilityMessage.hasBatteryState {
            capabilityMessage.batteryState = tempCapabilityMessage.batteryState
        }
        
        if subMessageNo >= 0 {
            return (subMessageNo + 1, capabilityMessage, nil)
        } else {
            return (subMessageNo + 1, nil, capabilityMessage)
        }
    }
    
    public func checkNewBatteryLevelTypeMessage() -> (Messaging_Battery?) {
        var newBatteryMessage: Messaging_Battery? = nil
        guard let stateStore = self.stateStore else {
            return nil
        }
        if let isNewBatteryLevel = stateStore.state.batteryLevelState.isNewBatteryLevel {
            if isNewBatteryLevel {
                var batteryMessage = Messaging_Battery()
                
                if let batteryLevel = stateStore.state.batteryLevelState.batteryLevel {
                    batteryMessage.battery = batteryLevel
                    newBatteryMessage = batteryMessage
                    DispatchQueue.main.async {
                        if self.stateStore == nil { return }
                        self.stateStore.dispatch(BatteryLevelReportedAction())
                    }
                }
            }
        }
        return newBatteryMessage
    }
    
    public func checkMessageLocationRequest(_ message: Messaging_ClientLocationRequest, subMessageCounter: Int)
                                            -> (Int, Messaging_ClientLocationRequest?, Messaging_ClientLocationRequest?) {
        let subMessageNo = subMessageCounter
        var locationRequestMessage = Messaging_ClientLocationRequest()
        let tempLocationRequestMessage = message
                          
        if tempLocationRequestMessage.hasType {
            locationRequestMessage.type = tempLocationRequestMessage.type
        }
        
        if subMessageNo >= 0 {
            return (subMessageNo + 1, locationRequestMessage, nil)
        } else {
            return (subMessageNo + 1, nil, locationRequestMessage)
        }
    }
    
    public func checkContactTypeMessages(_ messages: [Messaging_ContactMessage], subMessageCounter: Int)
                                         -> (Int, [Messaging_ContactMessage], [Messaging_ContactMessage]) {
        var clientMessagesToCompile = [Messaging_ContactMessage]()
        var messagesToQueue = [Messaging_ContactMessage]()
        var subMessageNo = subMessageCounter
        
        for tempContactMessage in messages {
            var contactMessage = Messaging_ContactMessage()
            
            contactMessage.eid = tempContactMessage.eid
            contactMessage.rssi = tempContactMessage.rssi
            contactMessage.timestamp = tempContactMessage.timestamp
            
            if subMessageCounter >= 0 {
                clientMessagesToCompile.append(contactMessage)
            } else {
                messagesToQueue.append(contactMessage)
            }
            
            subMessageNo += 1
        }
        
        return (subMessageNo, clientMessagesToCompile, messagesToQueue)
    }
}

