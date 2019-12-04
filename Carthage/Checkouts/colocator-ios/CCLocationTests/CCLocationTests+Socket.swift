//
//  CCLocationTests+Socket.swift
//  CCLocationTests
//
//  Created by Mobile Developer on 26/07/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import XCTest
import CoreLocation
import ReSwift
@testable import CCLocation

extension CCLocationTests {
    
    func testSuccessfullConnectionToSocket() {
        let expectation = XCTestExpectation(description: "Library should connect in a few seconds")
        
        let ccSocket = CCSocket()
        let urlString = "staging.colocator.net:443/socket"
        let state = Store<LibraryState> (
            reducer: libraryReducer,
            state: nil
        )
        let ccRequestMessaging = CCRequestMessaging(ccSocket: ccSocket,
                                                    stateStore: state)
        ccSocket.start(urlString: urlString,
                       apiKey: testAPIKey,
                       ccRequestMessaging: ccRequestMessaging)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            ccSocket.stop()
            XCTAssert(ccSocket.delay == CCSocketConstants.kMinDelay)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 6.0)
    }
    
    func testSuccessfullConnectionToSocketWithoutURL() {
        let expectation = XCTestExpectation(description: "Library should connect without URL")
        
        let cclocation = CCLocation.sharedInstance
        cclocation.start(apiKey: testAPIKey)

        let ccSocket = cclocation.colocatorManager?.ccRequestMessaging?.ccSocket

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            cclocation.stop()
            XCTAssert(ccSocket?.delay == CCSocketConstants.kMinDelay)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 6.0)
    }
    
    func testExponentialDelayForSocketConnection() {
        let expectation = XCTestExpectation(description: "Increade delay")
        
        let ccSocket = CCSocket()
        let urlString = "staging.colocator.net:443/wrongURLString"
        let state = Store<LibraryState> (
            reducer: libraryReducer,
            state: nil
        )
        let ccRequestMessaging = CCRequestMessaging(ccSocket: ccSocket,
                                                    stateStore: state)
        
        ccSocket.start(urlString: urlString,
                       apiKey: testAPIKey,
                       ccRequestMessaging: ccRequestMessaging)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            ccSocket.stop()
            XCTAssert(ccSocket.delay > CCSocketConstants.kMinDelay)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 6.0)
    }
    
    func testPresenceOfAllDeviceData() {
        let expectation = XCTestExpectation(description: "Send all device info")
        
        let ccSocket = CCSocket()
        let urlString = "staging.colocator.net:443/socket"
        let state = Store<LibraryState> (
            reducer: libraryReducer,
            state: nil
        )
        let ccRequestMessaging = CCRequestMessaging(ccSocket: ccSocket,
                                                    stateStore: state)
        ccSocket.start(urlString: urlString,
                       apiKey: testAPIKey,
                       ccRequestMessaging: ccRequestMessaging)
        let finalURL = ccSocket.createWebsocketURL(url: ccSocket.ccWebsocketBaseURL ?? "", id: ccSocket.deviceId)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            var allInfoIsPresent = false
            
            if let absoluteString = finalURL?.absoluteString {
                allInfoIsPresent = absoluteString.contains("model") &&
                    absoluteString.contains("os") &&
                    absoluteString.contains("version") &&
                    absoluteString.contains("networkType") &&
                    absoluteString.contains("libVersion")
            }
            
            ccSocket.stop()
            XCTAssert(allInfoIsPresent)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 6.0)
    }
    
    func testConstantConnection() {
        let expectation = XCTestExpectation(description: "Connection should stay open")
        
        let cclocation = CCLocation.sharedInstance
        cclocation.start(apiKey: testAPIKey)

        let ccSocket = cclocation.colocatorManager?.ccRequestMessaging?.ccSocket

        let timeRunningInSeconds: Int = 60 * 1 // 5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(timeRunningInSeconds)) {
            cclocation.stop()
            XCTAssert(ccSocket?.delay == CCSocketConstants.kMinDelay)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: Double(timeRunningInSeconds + 5))
    }
    
    func testStopObservationsAfter24hWithoutInternet() {
        let cclocation = CCLocation.sharedInstance
        cclocation.start(apiKey: testAPIKey)
                 
        let colocatorManager = cclocation.colocatorManager
        let ccSocket = colocatorManager?.ccRequestMessaging?.ccSocket
        ccSocket?.stopCycler(timer: Timer())
        
        let locationManager = colocatorManager?.ccLocationManager
        let noObservations = locationManager?.locationManager.monitoredRegions.count == 0 &&
                             locationManager?.areAllObservationsStopped ?? false
        cclocation.stop()
        
        XCTAssert(noObservations)
    }
    
    func testMaximumItemsInOneMessage() {
        let expectation = XCTestExpectation(description: "In a client message should be sent maximum 100 submessages")
        
        let ccLocation = CCLocation.sharedInstance
        ccLocation.start(apiKey: testAPIKey)
        
        let colocatorManager = ccLocation.colocatorManager
        let ccRequestMessages = colocatorManager?.ccRequestMessaging
        
        colocatorManager?.deleteDatabaseContent()
        
        let messagesToAdd = 301
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ccRequestMessages?.stateStore.dispatch( TimeBetweenSendsTimerReceivedAction(timeInMilliseconds: 3000))
            
            for i in 0..<messagesToAdd {
                ccRequestMessages?.processStep(date: Date(), angle: Double(i))
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ccRequestMessages?.stateStore.dispatch( TimeBetweenSendsTimerReceivedAction(timeInMilliseconds: 0))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let sentMessages = ccRequestMessages?.ccSocket?.messagesSentSinceStart ?? -1
            
            let hundredsOfMessages =  messagesToAdd / 100
            XCTAssert(sentMessages >= hundredsOfMessages && sentMessages <= hundredsOfMessages + 2)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 4.0)
    }
}
