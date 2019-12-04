//
//  CCLocationTests.swift
//  CCLocationTests
//
//  Created by Ralf Kernchen on 16/10/2016.
//  Copyright © 2016 Crowd Connected. All rights reserved.
//

import XCTest
import CoreLocation
@testable import CCLocation

class CCLocationTests: XCTestCase {

    let testAPIKey = "iosrtest"
    let stagingWrongURL = "staging.colocator.net:443/wrongURLString"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    class MockCCLocation: CCLocation {
        
        var mockUrlString: String?
        var mockColocatorManger: ColocatorManager?
        
        var lastAliasesMessage: Messaging_ClientMessage?
        
        override func start(apiKey: String, urlString: String? = nil) {
            mockUrlString = apiKey + Constants.kDefaultEndPointPartialUrl
            if urlString != nil {
                mockUrlString = urlString!
            }
            mockColocatorManger = ColocatorManager()
        }
        
        override func stop() {
            mockColocatorManger = nil
        }
        
        override func getDeviceId() -> String? {
            return UserDefaults.standard.string(forKey: CCSocketConstants.kLastDeviceIDKey)
        }
        
        override func setAliases(aliases: Dictionary<String, String>) {
            for key in aliases.keys {
                var aliasMessage = Messaging_AliasMessage()
                aliasMessage.key = key
                aliasMessage.value = aliases[key]!

                lastAliasesMessage = Messaging_ClientMessage()
                lastAliasesMessage?.alias.append(aliasMessage)
            }
        }
    }
    
    func testStartSDK() {
        let expectation = XCTestExpectation(description: "Data should be saved in database if cannot be sent")
        let mockCCLocation = MockCCLocation()
        let ccLocation = CCLocation.sharedInstance

        ccLocation.stop()
        
        mockCCLocation.start(apiKey: testAPIKey)
        ccLocation.start(apiKey: testAPIKey)

        let mockURL = mockCCLocation.mockUrlString
        let realURL = ccLocation.colocatorManager?.ccRequestMessaging?.ccSocket?.ccWebsocketBaseURL

        mockCCLocation.stop()
        ccLocation.stop()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            XCTAssert(realURL?.contains(mockURL!) ?? false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.5)
    }
    
    func testStopSDK() {
        let expectation = XCTestExpectation(description: "All objects in Colocator Manager should be removed after stopping the SDK")
        
        let ccLocation = CCLocation.sharedInstance
        
        ccLocation.start(apiKey: testAPIKey)
        ccLocation.stop()
        
        let realColocatorManager = ccLocation.colocatorManager
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let areObjectsDestroyed = realColocatorManager?.ccLocationManager == nil &&
            realColocatorManager?.ccRequestMessaging == nil &&
            realColocatorManager?.ccInertial == nil &&
            realColocatorManager?.ccSocket == nil
            
            XCTAssert(areObjectsDestroyed)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 6.0)
    }
    
    func testSetAliasesAndPersistence() {
        let expectation = XCTestExpectation(description: "Aliases should be sent and persist in User Defaults")
        
        let ccLocation = CCLocation.sharedInstance
        ccLocation.start(apiKey: testAPIKey)
        
        let colocatorManager = ccLocation.colocatorManager
        let ccRequestMessages = colocatorManager?.ccRequestMessaging


        ccLocation.colocatorManager?.deleteDatabaseContent()
        let initialMessagesCount = ccRequestMessages?.getMessageCount() ?? 0
        
        let aliasKey = "key"
        let aliasValue = "value"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ccLocation.addAlias(key: aliasKey, value: aliasValue)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let finalMessagesCount = ccRequestMessages?.getMessageCount() ?? 0
            
            let aliases = UserDefaults.standard.value(forKey: CCSocketConstants.kAliasKey) as? Dictionary<String, String> ?? [:]
            let value = aliases[aliasKey]
            
            XCTAssert(initialMessagesCount >= finalMessagesCount && aliasValue == value)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testGetDeviceID() {
        let mockCCLocation = MockCCLocation()
        let ccLocation = CCLocation.sharedInstance

        mockCCLocation.start(apiKey: testAPIKey)
        ccLocation.start(apiKey: testAPIKey)

        let mockDeviceID = mockCCLocation.getDeviceId()
        let realDeviceID = ccLocation.getDeviceId()

        mockCCLocation.stop()
        ccLocation.stop()

        XCTAssert(mockDeviceID == realDeviceID)
    }
    
    func testSavingDataInDatabase() { // no internet connect is required for this test
        let expectation = XCTestExpectation(description: "Data should be saved in database if cannot be sent")
        
        let cclocation = CCLocation.sharedInstance
        cclocation.start(apiKey: testAPIKey, urlString: stagingWrongURL)

        let colocatorManager = cclocation.colocatorManager
        let ccRequestMessages = colocatorManager?.ccRequestMessaging

        let initialMessagesCount = ccRequestMessages?.getMessageCount() ?? 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            cclocation.requestLocation()
            cclocation.requestLocation()
            cclocation.requestLocation()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let finalMessagesCount = ccRequestMessages?.getMessageCount() ?? 0
            
            XCTAssert(initialMessagesCount < finalMessagesCount)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testDatabaseMaximumCapacity() {
        let expectation = XCTestExpectation(description: "Database should store items up to 100.000")
        
        let cclocation = CCLocation.sharedInstance
        cclocation.start(apiKey: testAPIKey, urlString: stagingWrongURL)

        let colocatorManager = cclocation.colocatorManager
        let ccRequestMessages = colocatorManager?.ccRequestMessaging

        let messagesToInsert = 100100

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            colocatorManager?.deleteDatabaseContent()
            
            for i in 0..<messagesToInsert {
                ccRequestMessages?.processStep(date: Date(), angle: Double(i))
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 100) {
            let finalMessagesCount = ccRequestMessages?.getMessageCount() ?? 0
            cclocation.stop()
            
            XCTAssert(finalMessagesCount > 99990 && finalMessagesCount < messagesToInsert)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 102)
    }
    
    func testSendDataInOrder() {
        let expectation = XCTestExpectation(description: "Data should be sent in order to server")
        
        let cclocation = CCLocation.sharedInstance
        cclocation.start(apiKey: testAPIKey, urlString: stagingWrongURL)

        let colocatorManager = cclocation.colocatorManager
        let ccRequestMessages = colocatorManager?.ccRequestMessaging

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ccRequestMessages?.processStep(date: Date(), angle: 1)
            ccRequestMessages?.processStep(date: Date(), angle: 2)
            ccRequestMessages?.processStep(date: Date(), angle: 3)
            ccRequestMessages?.processStep(date: Date(), angle: 4)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let finalMessagesCount = ccRequestMessages?.getMessageCount() ?? 0

            if finalMessagesCount > 0 {
                let tempMessageData = ccRequestMessages?.popMessagesFromLocalDatabase(maxMessagesToReturn: 10)

                var subMessageCounter = 0
                var compiledClientMessage = Messaging_ClientMessage()
                let backToQueueMessages = Messaging_ClientMessage()

                if let unwrappedTempMessageData = tempMessageData {
                    for tempMessage in unwrappedTempMessageData {

                        let (newSubMessageCounter,
                             newCompiledClientMessage,
                             _) = ccRequestMessages?.handleMessageType(message: tempMessage,
                                                                               subMessageInitialNumber: subMessageCounter,
                                                                               compiledMessage: compiledClientMessage,
                                                                               queueMessage: backToQueueMessages)
                                                        ?? (subMessageCounter,
                                                            Messaging_ClientMessage(),
                                                            Messaging_ClientMessage())

                        subMessageCounter = newSubMessageCounter
                        compiledClientMessage = newCompiledClientMessage
                    }
                }

                let sortedMessages = compiledClientMessage.step.sorted { (msg1, msg2) -> Bool in
                    msg1.angle < msg2.angle
                }

                cclocation.stop()
                XCTAssert(compiledClientMessage.step == sortedMessages)
                expectation.fulfill()
            } else {
                cclocation.stop()
                XCTAssert(false)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }
    
    // connection available
    func testRadioSilence0() {
        let expectation = XCTestExpectation(description: "Data shouldn't be collected in database anymore, but sent immediately")
        
        let cclocation = CCLocation.sharedInstance
        cclocation.start(apiKey: testAPIKey)

        let colocatorManager = cclocation.colocatorManager
        let ccRequestMessages = colocatorManager?.ccRequestMessaging
        colocatorManager?.deleteDatabaseContent()
        
        let initialMessagesCount = ccRequestMessages?.getMessageCount() ?? 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ccRequestMessages?.stateStore.dispatch( TimeBetweenSendsTimerReceivedAction(timeInMilliseconds: 0))
            ccRequestMessages?.stateStore.dispatch( EnableForegroundGEOAction(activityType: .fitness, maxRuntime: nil, minOffTime: nil, desiredAccuracy: -1, distanceFilter: -1, pausesUpdates: false))
            
            // location messages are received
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let finalMessagesCount = ccRequestMessages?.getMessageCount() ?? 0
            cclocation.stop()
            
            XCTAssert(finalMessagesCount <= initialMessagesCount)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 6.5)
    }
    
    // connection available
    func testRadioSilenceNot0() {
        let expectation = XCTestExpectation(description: "Data should be collected in database without being sent until radioSilence passes")
        
        let cclocation = CCLocation.sharedInstance
        cclocation.start(apiKey: testAPIKey)

        let colocatorManager = cclocation.colocatorManager
        let ccRequestMessages = colocatorManager?.ccRequestMessaging
     
        colocatorManager?.deleteDatabaseContent()
        
        let initialMessagesCount = ccRequestMessages?.getMessageCount() ?? 0
              
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ccRequestMessages?.stateStore.dispatch( TimeBetweenSendsTimerReceivedAction(timeInMilliseconds: 5000))
            ccRequestMessages?.processLocationEvent(location: CLLocation(latitude: 2.0, longitude: 3.0))
            ccRequestMessages?.processLocationEvent(location: CLLocation(latitude: 4.0, longitude: 3.0))
            ccRequestMessages?.processLocationEvent(location: CLLocation(latitude: 7.0, longitude: 3.0))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let finalMessagesCount = ccRequestMessages?.getMessageCount() ?? 0
            cclocation.stop()
            
            XCTAssert(finalMessagesCount > initialMessagesCount)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4.0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
