//
//  CCInertial.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 06/06/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation
import CoreMotion
import ReSwift

protocol CCInertialDelegate: class {
    func receivedStep(date: Date, angle: Double)
}

class CCInertial: NSObject {
    
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    private let motion = CMMotionManager()
    
    private var pedometerStartDate: Date = Date()
    private var previousPedometerData: PedometerData?
    private var yawDataBuffer: [YawData] = []
    
    private let yawDataSerialQueue = DispatchQueue(label: "YawDataDispatchQueue")
    
    private lazy var yawDataOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Yaw Data queue"
        queue.maxConcurrentOperationCount = 5
        return queue
    }()

    var currentInertialState: InertialState!
    weak var stateStore: Store<LibraryState>!
    public weak var delegate: CCInertialDelegate?
    
    init(stateStore: Store<LibraryState>) {
        super.init()
        
        self.stateStore = stateStore
        currentInertialState = InertialState(isEnabled: false, interval: 0)
        stateStore.subscribe(self)
    }
    
    public func updateFitnessAndMotionStatus() {
        // The 5 seconds time frame is the estimated time (+ margin) for the user to make a choice in granting permission
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.stateStore == nil { return }
            if #available(iOS 11.0, *) {
                if self.stateStore == nil { return }
                switch CMMotionActivityManager.authorizationStatus() {
                    case .authorized:  self.stateStore.dispatch(IsMotionAndFitnessEnabledAction(isMotionAndFitnessEnabled: true))
                    case .restricted, .denied: self.stateStore.dispatch(IsMotionAndFitnessEnabledAction(isMotionAndFitnessEnabled: false))
                    case .notDetermined: self.stateStore.dispatch(IsMotionAndFitnessEnabledAction(isMotionAndFitnessEnabled: nil))
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    internal func start() {
       if #available(iOS 11.0, *) {
           let pedometerAuthStatus = CMPedometer.authorizationStatus()
           
           if pedometerAuthStatus == .authorized || pedometerAuthStatus == .notDetermined {
               Log.info("[Colocator] Starting inertial")
            
               startCountingSteps()
               startMotionUpdates()
               updateFitnessAndMotionStatus()
           } else {
               Log.info("[Colocator] Cannot start inertial due to restricted permission for Motion&Fitness")
            
               DispatchQueue.main.async {
                    if self.stateStore == nil { return }
                    self.stateStore.dispatch(IsMotionAndFitnessEnabledAction(isMotionAndFitnessEnabled: false))
               }
           }
       } else {
           Log.info("[Colocator] Starting inertial")
           
           startCountingSteps()
           startMotionUpdates()
       }
    }
       
    internal func stop() {
        Log.info("[Colocator] Stopping inertial")
           
        pedometer.stopUpdates()
        motion.stopDeviceMotionUpdates()
    }
    
    internal func startCountingSteps() {
        if !CMPedometer.isStepCountingAvailable() {
            return
        }
        
        pedometerStartDate = Date()
        previousPedometerData = PedometerData(endDate: pedometerStartDate, numberOfSteps: 0)
        
        pedometer.startUpdates(from: pedometerStartDate) { [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else {
                Log.error("[Colocator] Received: \(error.debugDescription)")
                self?.updateFitnessAndMotionStatus()
                return
            }
            
            self?.handleStepsSinceLastCount(fromPedometerData: pedometerData)
        }
    }
    
    private func startMotionUpdates() {
        if !motion.isDeviceMotionAvailable {
            Log.debug("Device Motion is not available. Cannot start monitoring updated")
            return
        }
        
        motion.startDeviceMotionUpdates(using: .xArbitraryZVertical,
                                        to: yawDataOperationQueue) { [weak self] deviceMotion, error in
            guard let data = deviceMotion, error == nil else {
                Log.error("[Colocator] Received motion update error: \((error as? CMError).debugDescription)")
                self?.updateFitnessAndMotionStatus()
                return
            }

            DispatchQueue.main.async {
                self?.handleDeviceMotionData(data)
            }
        }
    }
    
    private func handleDeviceMotionData(_ data: CMDeviceMotion) {
        let yawValue = data.attitude.yaw
        let yawData = YawData(yaw: yawValue, date: Date())

        Log.verbose("""
            Device Motion Data
            Yaw: \(yawData.yaw)
            Timestamp: \(yawData.date.timeIntervalSince1970)
            """)

        yawDataSerialQueue.sync {
            self.yawDataBuffer.append(yawData)
        }

        let bufferSize = CCInertialConstants.kBufferSize
        let cutOff = CCInertialConstants.kCutOff

        if self.yawDataBuffer.count >= bufferSize {
            let upperLimit = bufferSize - cutOff - 1
            
            yawDataSerialQueue.sync {
                self.yawDataBuffer.removeSubrange(0 ... upperLimit)
            }
        }
    }
    
    private func findFirstSmallerYaw(yawArray: [YawData], timeInterval: TimeInterval) -> YawData? {
        for (index, yaw) in yawArray.reversed().enumerated() {
            if yaw.date.timeIntervalSince1970 < timeInterval {
                let upperLimit = yawArray.count - index - 1
                yawDataSerialQueue.sync {
                    yawDataBuffer.removeSubrange(0 ... upperLimit)
                
                    // Extend matching yaw data for 0.04 seconds for reducing the discarded steps number
                    yawDataBuffer.insert(YawData(yaw: yaw.yaw, date: Date(timeIntervalSince1970: yaw.date.timeIntervalSince1970 + 0.04)), at: 0)
                }
                
                return yaw
            }
        }
        return nil
    }
    
    //MARK: - Handle Updates
    
    private func handleStepsSinceLastCount(fromPedometerData pedometerData: CMPedometerData) {
        guard let tempPreviousPedometerData = previousPedometerData else {
            return
        }
        
        let endDate = pedometerData.endDate
        let numberOfSteps = pedometerData.numberOfSteps.intValue
        
        if tempPreviousPedometerData.numberOfSteps != numberOfSteps {
            let periodBetweenStepCounts = getPeriodBetween(recentDate: endDate,
                                                           oldDate: tempPreviousPedometerData.endDate)
            let stepsBetweenStepCounts = numberOfSteps - tempPreviousPedometerData.numberOfSteps
            let oneStepTimeInterval = TimeInterval(periodBetweenStepCounts / Double(stepsBetweenStepCounts))
            
            Log.verbose("""
                Pedometer Data
                Step count: \(numberOfSteps)
                Period between step counts: \(periodBetweenStepCounts)
                Steps in-between: \(stepsBetweenStepCounts)
                Time interval per step: \(oneStepTimeInterval)
                """)
            
            handleAndReceiveEachStep(totalSteps: stepsBetweenStepCounts,
                                          oneStepTimeInterval: oneStepTimeInterval,
                                          previousPedometerData: tempPreviousPedometerData)
            previousPedometerData = PedometerData (endDate: pedometerData.endDate,
                                                   numberOfSteps: numberOfSteps)
        }
    }
    
    private func handleAndReceiveEachStep(totalSteps: Int,
                                          oneStepTimeInterval: TimeInterval,
                                          previousPedometerData: PedometerData) {
        Log.debug("Handle \(totalSteps) steps")
        
        for i in  1 ... totalSteps {
            let tempTimePeriod = TimeInterval(Double(i) * oneStepTimeInterval)
            let tempTimeStamp = previousPedometerData.endDate.timeIntervalSince1970 + tempTimePeriod
            
            guard let tempYaw = findFirstSmallerYaw(yawArray: yawDataBuffer, timeInterval: tempTimeStamp) else {
                Log.debug("Steps discarded. Matching yaw not found")
                continue
            }
            
            Log.debug ("""
                Valid Step Data
                Timestamp: \(tempTimeStamp)
                Yaw: \(String(describing: tempYaw.yaw))
                """)
            
            let stepDate = Date(timeIntervalSince1970: tempTimeStamp)
            let angle = rad2deg(tempYaw.yaw)
            self.delegate?.receivedStep(date: stepDate, angle: angle)
        }
    }
    
    // MARK: - Helpers
    
    func setInterval(time: TimeInterval) {
        self.motion.deviceMotionUpdateInterval = time
    }
    
    private func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
    
    private func getPeriodBetween(recentDate date1: Date, oldDate date2: Date) -> TimeInterval {
        return date1.timeIntervalSince1970 - date2.timeIntervalSince1970
    }
}
