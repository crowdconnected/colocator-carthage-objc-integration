//
//  CCRequestMessaging+Helpers.swift
//  CCLocation
//
//  Created by Mobile Developer on 23/08/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import CoreBluetooth
import CoreLocation
import Foundation

extension CCRequestMessaging {
    
    func getLocationAuthStatus(forAuthorisationStatus status: CLAuthorizationStatus) -> Messaging_IosCapability.LocationAuthStatus {
        switch status {
        case .authorizedAlways: return Messaging_IosCapability.LocationAuthStatus.always
        case .authorizedWhenInUse: return Messaging_IosCapability.LocationAuthStatus.inUse
        case .denied: return Messaging_IosCapability.LocationAuthStatus.denied
        case .notDetermined: return Messaging_IosCapability.LocationAuthStatus.notDetermined
        case .restricted: return Messaging_IosCapability.LocationAuthStatus.restricted
        }
    }
    
    func getBluetoothStatus(forBluetoothState state: CBCentralManagerState) -> Messaging_IosCapability.BluetoothHardware {
        switch state {
        case .poweredOff: return Messaging_IosCapability.BluetoothHardware.off
        case .poweredOn: return Messaging_IosCapability.BluetoothHardware.on
        case .resetting: return Messaging_IosCapability.BluetoothHardware.resetting
        case .unauthorized: return Messaging_IosCapability.BluetoothHardware.unauthorized
        case .unknown: return Messaging_IosCapability.BluetoothHardware.unknown
        case .unsupported: return Messaging_IosCapability.BluetoothHardware.unsupported
        }
    }
    
    func getBatteryState(fromState state: UIDevice.BatteryState) -> Messaging_IosCapability.BatteryState {
        switch state {
        case .charging: return Messaging_IosCapability.BatteryState.charging
        case .full: return Messaging_IosCapability.BatteryState.full
        case .unknown: return Messaging_IosCapability.BatteryState.notDefined
        case .unplugged: return Messaging_IosCapability.BatteryState.unplugged
        }
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var categories: [U: [Iterator.Element]] = [:]
        for element in self {
            let key = key(element)
            if case nil = categories[key]?.append(element) {
                categories[key] = [element]
            }
        }
        return categories
    }
}

