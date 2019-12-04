//
//  CCRequestMessaging.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 16/10/2016.
//  Copyright © 2016 Crowd Connected. All rights reserved.
//

import Foundation
import CoreLocation
import ReSwift
import CoreBluetooth

class CCRequestMessaging: NSObject {
    
    enum MessageType {
        case queueable
        case discardable
        case urgent
    }
    
    weak var ccSocket: CCSocket?
    weak var stateStore: Store<LibraryState>!
    weak var timeHandling: TimeHandling!
    
    var currentRadioSilenceTimerState: TimerState?
    var currentWebSocketState: WebSocketState?
    var currentLibraryTimerState: LibraryTimeState?
    var currentCapabilityState: CapabilityState?
    
    weak var timeBetweenSendsTimer: Timer?
    
    internal var messagesDB: SQLiteDatabase!
    internal let messagesDBName = "observations.db"
    
    init(ccSocket: CCSocket, stateStore: Store<LibraryState>) {
        super.init()
        
        self.ccSocket = ccSocket
        self.stateStore = stateStore
        
        timeHandling = TimeHandling.shared
        timeHandling.delegate = self
        
        stateStore.subscribe(self) {
            $0.select {
                state in state.ccRequestMessagingState
            }
        }
        
        if stateStore.state.ccRequestMessagingState.libraryTimeState?.lastTrueTime == nil {
            timeHandling.fetchTrueTime()
        }
        
        openMessagesDatabase()
        createCCMesageTable()
        
        setupApplicationNotifications()
        setupBatteryStateAndLevelNotifcations()
        
        //initial dispatch of battery state
        batteryStateDidChange(notification: Notification(name: UIDevice.batteryStateDidChangeNotification))
    }
    
    // MARK: - PROCESS RECEIVED COLOCATOR SERVER MESSAGES FUNCTIONS
    
    public func processServerMessage(data: Data) throws {
        let serverMessage = try Messaging_ServerMessage.init(serializedData: data)
        
        let serverMessageJSON = try serverMessage.jsonString()
        if serverMessageJSON.count > 2 {
            Log.info("[Colocator] Received message from server \n\(serverMessage)")
        }
        
        processGlobalSettings(serverMessage: serverMessage, store: stateStore)
        processIosSettings(serverMessage: serverMessage, store: stateStore)
        processLocationResponseMessages(serverMessage: serverMessage)
    }
    
    func processLocationResponseMessages(serverMessage: Messaging_ServerMessage) {
        if !serverMessage.locationResponses.isEmpty {
            var messages: [LocationResponse] = []
            
            for locationResponse in serverMessage.locationResponses {
                let newLocationMessage = LocationResponse(latitude: locationResponse.latitude,
                                                          longitude: locationResponse.longitude,
                                                          headingOffSet: locationResponse.headingOffset,
                                                          error: locationResponse.error,
                                                          timestamp: locationResponse.timestamp)
                
                messages.append(newLocationMessage)
            }
            ccSocket?.delegate?.receivedLocationMessages(messages)
        }
    }
    
    func processGlobalSettings(serverMessage: Messaging_ServerMessage, store: Store<LibraryState>) {
        if serverMessage.hasGlobalSettings {
            Log.debug("Got global settings message")
            
            let globalSettings = serverMessage.globalSettings
            var radioSilence: UInt64? = nil
            
            // if radio silence is 0 treat it the same way as if the timer doesn't exist
            if globalSettings.hasRadioSilence && globalSettings.radioSilence != 0 {
                radioSilence = globalSettings.radioSilence
            }
            
            DispatchQueue.main.async {
                store.dispatch(TimeBetweenSendsTimerReceivedAction(timeInMilliseconds: radioSilence))
            }
            
            if globalSettings.hasID {
                let uuid = NSUUID(uuidBytes: ([UInt8](globalSettings.id)))
                ccSocket?.setDeviceId(deviceId: uuid.uuidString)
            }
        }
    }
    
    public func processIOSCapability(locationAuthStatus: CLAuthorizationStatus?,
                                     bluetoothHardware: CBCentralManagerState?,
                                     batteryState: UIDevice.BatteryState?,
                                     isLowPowerModeEnabled: Bool?,
                                     isLocationServicesEnabled: Bool?){
        var clientMessage = Messaging_ClientMessage()
        var capabilityMessage = Messaging_IosCapability()
        
        if let locationServices = isLocationServicesEnabled {
            capabilityMessage.locationServices = locationServices
        }
        if let lowPowerMode = isLowPowerModeEnabled {
            capabilityMessage.lowPowerMode = lowPowerMode
        }
        if let locationAuthStatus = locationAuthStatus {
            capabilityMessage.locationAuthStatus = getLocationAuthStatus(forAuthorisationStatus: locationAuthStatus)
        }
        if let bluetoothHardware = bluetoothHardware {
            capabilityMessage.bluetoothHardware = getBluetoothStatus(forBluetoothState: bluetoothHardware)
        }
        if let batteryState = batteryState {
            capabilityMessage.batteryState = getBatteryState(fromState: batteryState)
        }
        
        clientMessage.iosCapability = capabilityMessage
        
        if let data = try? clientMessage.serializedData() {
            Log.debug("Capability message built\n\(clientMessage)")
            sendOrQueueClientMessage(data: data, messageType: .queueable)
        }
    }
    
    // MARK: - STATE HANDLING FUNCTIONS
    
    public func webSocketDidOpen() {
        if stateStore != nil {
            DispatchQueue.main.async {self.stateStore.dispatch(WebSocketAction(connectionState: ConnectionState.online))}
        }
    }
    
    public func webSocketDidClose() {
        if stateStore != nil {
            DispatchQueue.main.async {self.stateStore.dispatch(WebSocketAction(connectionState: ConnectionState.offline))}
        }
    }
    
    // MARK: - HIGH LEVEL SEND CLIENT MESSAGE DATA
    
    func sendOrQueueClientMessage(data: Data, messageType: MessageType) {
        let connectionState = stateStore.state.ccRequestMessagingState.webSocketState?.connectionState
        let timeBetweenSends = stateStore.state.ccRequestMessagingState.radiosilenceTimerState?.timeInterval
        
        sendOrQueueClientMessage(data: data,
                                 messageType: messageType,
                                 connectionState: connectionState,
                                 timeBetweenSends: timeBetweenSends)
    }
    
    func sendOrQueueClientMessage(data: Data, messageType: MessageType, connectionState: ConnectionState?, timeBetweenSends: UInt64?) {
        if let connectionStateUnwrapped = connectionState, connectionStateUnwrapped == .online {
            
            if timeBetweenSends == nil || timeBetweenSends == 0 {
                Log.verbose("Websocket open, buffer timer absent, send new and queued messages")
                self.sendQueuedClientMessages(firstMessage: data)
            } else {
                if messageType == .queueable {
                    Log.verbose("Message queuable, buffer timer present, queue message")
                    insertMessageInLocalDatabase(message: data)
                }
                if messageType == .discardable {
                    Log.verbose("Websocket online, buffer timer present, message discardable, send new and queued messages")
                    sendQueuedClientMessages(firstMessage: data)
                }
                if messageType == .urgent {
                    Log.verbose("Websocket online, buffer timer present,  urgent message, send current messages")
                    sendSingleMessage(data)
                }
            }
        } else {
            if messageType == .queueable {
                Log.verbose("Websocket offline, message queuable, queue message")
                insertMessageInLocalDatabase(message: data)
            }
            if messageType == .discardable {
                Log.verbose("Websocket offline, message discardable, discard message")
            }
            if messageType == .urgent {
                Log.verbose("Websocket offline, urgent message , add into database")
                insertMessageInLocalDatabase(message: data)
            }
        }
    }
    
    // sendQueuedClientMessage for timeBetweenSendsTimer firing
    @objc internal func sendQueuedClientMessagesTimerFired() {
        Log.verbose("Flushing queued messages")
        if stateStore != nil {
            if stateStore.state.ccRequestMessagingState.webSocketState?.connectionState == .online {
                self.sendQueuedClientMessages(firstMessage: nil)
            }
        }
    }
    
    func sendQueuedMessagesAndStopTimer() {
        if stateStore.state.ccRequestMessagingState.webSocketState?.connectionState == .online {
            self.sendQueuedClientMessages(firstMessage: nil)
        }
        timeBetweenSendsTimer?.invalidate()
        timeBetweenSendsTimer = nil
    }
    
    @objc internal func sendQueuedClientMessagesTimerFiredOnce() {
        Log.verbose("Truncated silence period timer fired")
        sendQueuedClientMessagesTimerFired()
        
        // now we simply resume the normal timer
        DispatchQueue.main.async {self.stateStore.dispatch(ScheduleSilencePeriodTimerAction())}
    }
    
    func stop() {
        NotificationCenter.default.removeObserver(self)
        stateStore.unsubscribe(self)
        killTimeBetweenSendsTimer()
        
        timeHandling.delegate = nil
        
        messagesDB.close()
        messagesDB = nil
    }
    
    func killTimeBetweenSendsTimer() {
        timeBetweenSendsTimer?.invalidate()
        timeBetweenSendsTimer = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        Log.debug("CCRequestMessaging DEINIT")
    }
}

// MARK:- TimeHandling delegate

extension CCRequestMessaging: TimeHandlingDelegate {
    
    public func newTrueTimeAvailable(trueTime: Date, timeIntervalSinceBootTime: TimeInterval, systemTime: Date, lastRebootTime: Date) {
        Log.debug("""
            Received new truetime \(trueTime)
            TimeIntervalSinceBootTime \(timeIntervalSinceBootTime)
            SystemTime \(systemTime)
            LastRebootTime \(lastRebootTime)
            """)
        
        DispatchQueue.main.async {
            self.stateStore.dispatch(NewTruetimeReceivedAction(lastTrueTime: trueTime,
                                                               bootTimeIntervalAtLastTrueTime: timeIntervalSinceBootTime,
                                                               systemTimeAtLastTrueTime: systemTime,
                                                               lastRebootTime: lastRebootTime))
        }
        
        guard let radioSilenceTimerState = stateStore.state.ccRequestMessagingState.radiosilenceTimerState else {
            return
        }
        
        if radioSilenceTimerState.timer == .stopped && radioSilenceTimerState.startTimeInterval != nil {
            DispatchQueue.main.async {self.stateStore.dispatch(ScheduleSilencePeriodTimerAction())}
        }
    }
}
