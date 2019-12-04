//
//  CCInertial+StoreSubscriber.swift
//  CCLocation
//
//  Created by Mobile Developer on 22/08/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation
import ReSwift

extension CCInertial: StoreSubscriber {
    
    public func newState(state: LibraryState) {
        guard let newInertialState = state.intertialState else {
            return
        }
        
        if newInertialState != currentInertialState {
            if let interval = newInertialState.interval {
                setInterval(time: Double(interval) / 1000)
            }
            Log.debug("Pedometer: New state is: \(newInertialState)")
            
            updateCurrentInertialStateActivity(newState: newInertialState)
            currentInertialState = newInertialState
        }
    }
    
    private func updateCurrentInertialStateActivity(newState: InertialState) {
        guard let isInertialEnabled = newState.isEnabled else {
            return
        }
        
        if isInertialEnabled && !self.currentInertialState.isEnabled! {
            start()
        }
        if !isInertialEnabled && self.currentInertialState.isEnabled! {
            stop()
        }
    }
}
