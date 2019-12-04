//
//  CCSocket.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 15/08/2018.
//  Copyright © 2018 Crowd Connected. All rights reserved.
//

import Foundation
import CoreFoundation
import SocketRocket
import CoreLocation
import TrueTime

@objc public class LocationResponse: NSObject {
    @objc public var latitude: Double
    @objc public var longitude: Double
    @objc public var headingOffSet: Double
    @objc public var error: Double
    @objc public var timestamp: UInt64
    
    public init(latitude: Double,
         longitude: Double,
         headingOffSet: Double,
         error: Double,
         timestamp: UInt64) {
        self.latitude = latitude
        self.longitude = longitude
        self.headingOffSet = headingOffSet
        self.error = error
        self.timestamp = timestamp
        super.init()
    }
}

protocol CCSocketDelegate: AnyObject{
    func receivedTextMessage(message: NSDictionary)
    func receivedLocationMessages(_ messages: [LocationResponse])
    func ccSocketDidConnect()
    func ccSocketDidFailWithError(error: Error)
}

class CCSocket:NSObject {
    
    var webSocket: SRWebSocket?
    
    var delegate: CCSocketDelegate?
    
    var deviceId: String?
    var ccWebsocketBaseURL: String?
    var ccRequestMessaging: CCRequestMessaging?
    var colocatorManager: ColocatorManager?
    
    var delay: Double = 0
    var maxCycleTimer: Timer?
    var firstReconnect: Bool = true
    var pingTimer: Timer?
    var reconnectTimer: Timer?
    var startTime: Date?
    
    #if DEBUG
    var messagesSentSinceStart = 0
    #endif
    
    public static let sharedInstance: CCSocket = {
        let instance = CCSocket()
        return instance
    }()
    
    func start(urlString: String,
               apiKey: String,
               ccRequestMessaging: CCRequestMessaging) {
        startTime = Date()
        deviceId = UserDefaults.standard.string(forKey: CCSocketConstants.kLastDeviceIDKey)
        colocatorManager = ColocatorManager.sharedInstance
        
        ccWebsocketBaseURL = CCSocketConstants.kWsPrefix.appendingFormat("%@/%@",
                                                                         urlString,
                                                                         apiKey)
        
        self.ccRequestMessaging = ccRequestMessaging
        
        connect(timer: nil)
        
        #if DEBUG
        messagesSentSinceStart = 0
        #endif
    }
    
    public func stop() {
        webSocket?.delegate = nil
        webSocket = nil
        
        ccRequestMessaging = nil
        
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        
        maxCycleTimer?.invalidate()
        maxCycleTimer = nil
        
        pingTimer?.invalidate()
        pingTimer = nil
        
        ccWebsocketBaseURL = nil
        startTime = nil
    }
    
    @objc public func connect(timer: Timer?) {
        Log.debug("Establishing connection to Colocator servers ...")
        if webSocket == nil {
            configureWebSocket()
        }
    }
    
    private func configureWebSocket() {
        var certRef: SecCertificate?
        var certDataRef: CFData?

        guard let ccWebsocketBaseURL = self.ccWebsocketBaseURL,
            let socketURL = createWebsocketURL(url: ccWebsocketBaseURL, id: deviceId) else {
            Log.error("[Colocator] Construction of the Websocket connection request URL failed, will not attempt to connect to CoLocator backend")
            return
        }
        
        let platformConnectionRequest = NSMutableURLRequest(url: socketURL)
        
        if let cerPath = Bundle(for: type(of: self)).path(forResource: "certificate", ofType: "der") {
            do {
                let certData = try Data(contentsOf: URL(fileURLWithPath: cerPath))
                certDataRef = certData as CFData
            }
            catch {
                Log.error("[Colocator] Could not create certificate data")
            }
        } else {
            Log.error("[Colocator] Could not find certificate file in Application Bundle, will not attempt to connect to CoLocator backend")
        }
        
        guard let certDataRefUnwrapped = certDataRef else {
            return
        }
        
        certRef = SecCertificateCreateWithData(nil, certDataRefUnwrapped)
        
        guard let certRefUnwrapped = certRef else {
            Log.error("[Colocator] Certificate is not a valid DER-encoded X.509 certificate")
            return
        }
        
        platformConnectionRequest.sr_SSLPinnedCertificates = [certRefUnwrapped]
        
        if platformConnectionRequest.url != nil {
            self.webSocket = SRWebSocket.init(urlRequest: platformConnectionRequest as URLRequest?)
            self.webSocket?.delegate = self
        }
        self.webSocket?.open()
    }
    
    @objc func stopCycler(timer: Timer) {
        colocatorManager?.stopLocationObservations()
        colocatorManager?.deleteDatabaseContent()
        self.maxCycleTimer = nil
        
        Log.debug("Location observations stopped")
    }
    
    private func delayReconnect() {
        if delay == 0 {
            delay = CCSocketConstants.kMinDelay
        }
        
        if pingTimer != nil {
            pingTimer!.invalidate()
        }

        Log.debug("Trying to reconnect in \(round((delay / 1000) * 100) / 100) s")
        
        reconnectTimer = Timer.scheduledTimer(timeInterval: delay/1000,
                                              target: self,
                                              selector: #selector(self.connect(timer:)),
                                              userInfo: nil,
                                              repeats: false)
        
        if delay * 1.2 < CCSocketConstants.kMaxDelay {
            delay = delay * 1.2
        } else {
            delay = CCSocketConstants.kMaxDelay
        }
        
        if maxCycleTimer == nil && firstReconnect {
            Log.warning("[Colocator] Fired timer for stop collecting data in \(CCSocketConstants.kMaxCycleDelay / 1000) seconds")

            maxCycleTimer = Timer.scheduledTimer(timeInterval: CCSocketConstants.kMaxCycleDelay / 1000,
                                                 target: self,
                                                 selector: #selector(self.stopCycler(timer:)),
                                                 userInfo: nil,
                                                 repeats: false)
        }
        firstReconnect = false
    }
    
    func setDeviceId(deviceId: String) {
        self.deviceId = deviceId
        UserDefaults.standard.set(self.deviceId!, forKey: CCSocketConstants.kLastDeviceIDKey)
    }
    
    func sendWebSocketMessage(data: Data) {
        if webSocket != nil {
            webSocket?.send(data)
            #if DEBUG
            messagesSentSinceStart += 1
            #endif
        }
    }
    
    func createWebsocketURL(url: String, id: String?) -> URL? {
        var requestURL: URL?
        var queryString: String?
            
        queryString = id != nil ? String(format: "?id=%@&", id!) : "?"
        
        queryString! += colocatorManager?.deviceDescription() ?? ""
        queryString! += colocatorManager?.networkType() ?? ""
        queryString! += colocatorManager?.libraryVersion() ?? ""
        
        if queryString!.isEmpty {
            queryString = "?error=inQueryStringConstruction"
        } else {
            queryString = queryString!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }

        guard let queryStringUnwrapped = queryString else {
            return nil
        }
        
        Log.debug("Query string is \(queryString ?? "NOT AVAILABLE")")
        
        requestURL = URL(string: url)
        requestURL = URL(string: queryStringUnwrapped, relativeTo: requestURL)
        
        return requestURL
    }

    deinit {
        Log.debug("CCRequestMessaging DEINIT")
        
        if #available(iOS 10.0, *) {
            Log.debug("CCRequestMessaging DEINIT")
        } else {
            // Fallback on earlier versions
        }
    }
}

// MARK: SRWebSocketDelegate
extension CCSocket: SRWebSocketDelegate {
    public func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        Log.info("[Colocator] Connection to back-end established")
        
        guard let ccRequestMessagingUnwrapped = ccRequestMessaging else {
            return
        }
        
        ccRequestMessagingUnwrapped.webSocketDidOpen()
        
        delay = CCSocketConstants.kMinDelay
                
        if let timer = maxCycleTimer {
            timer.invalidate()
        }
        
        maxCycleTimer = nil
        firstReconnect = true
        
        if let delegate = self.delegate {
            delegate.ccSocketDidConnect()
        }
    }
    
    public func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        Log.error("[Colocator] Connection failed With Error " + error.localizedDescription)
        
        guard let ccRequestMessaging = self.ccRequestMessaging else {
            return
        }
        
        self.webSocket?.delegate = nil
        self.webSocket = nil
        
        ccRequestMessaging.webSocketDidClose()
        
        if let delegate = self.delegate {
            delegate.ccSocketDidFailWithError(error: error)
        }
        
        delayReconnect()
    }
    
    public func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        guard let ccRequestMessaging = self.ccRequestMessaging else {
            return
        }
        
        var messageData: Data? = nil
        
        if message is String || message is NSString {
           
            messageData = (message as! String).data(using: .utf8)!
            
        } else if message is Data || message is NSData {
            
            messageData = message as? Data
        }
        
        do {
            try ccRequestMessaging.processServerMessage(data: messageData!)
        } catch {
            Log.error("[Colocator] Processing server message failed");
        }
    }
    
    public func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        self.webSocket?.delegate = nil
        self.webSocket = nil
        
        delayReconnect()
    }
}

extension StringProtocol {
    var hexa2Bytes: [UInt8] {
        let hexa = Array(self)
        return stride(from: 0, to: count, by: 2).compactMap {
            UInt8(String(hexa[$0..<$0.advanced(by: 2)]), radix: 16)
        }
    }
}
