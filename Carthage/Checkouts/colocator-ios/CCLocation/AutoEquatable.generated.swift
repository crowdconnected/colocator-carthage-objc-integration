// Generated using Sourcery 0.16.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length
fileprivate func compareOptionals<T>(lhs: T?, rhs: T?, compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    switch (lhs, rhs) {
    case let (lValue?, rValue?):
        return compare(lValue, rValue)
    case (nil, nil):
        return true
    default:
        return false
    }
}

fileprivate func compareArrays<T>(lhs: [T], rhs: [T], compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (idx, lhsItem) in lhs.enumerated() {
        guard compare(lhsItem, rhs[idx]) else { return false }
    }

    return true
}


// MARK: - AutoEquatable for classes, protocols, structs
// MARK: - BackgroundGEOState AutoEquatable
extension BackgroundGEOState: Equatable {}
internal func == (lhs: BackgroundGEOState, rhs: BackgroundGEOState) -> Bool {
    guard compareOptionals(lhs: lhs.bgGEOEnabled, rhs: rhs.bgGEOEnabled, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.bgActivityType, rhs: rhs.bgActivityType, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.bgMaxRuntime, rhs: rhs.bgMaxRuntime, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.bgMinOffTime, rhs: rhs.bgMinOffTime, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.bgDesiredAccuracy, rhs: rhs.bgDesiredAccuracy, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.bgDistanceFilter, rhs: rhs.bgDistanceFilter, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.bgPausesUpdates, rhs: rhs.bgPausesUpdates, compare: ==) else { return false }
    return true
}
// MARK: - BackgroundLocationState AutoEquatable
extension BackgroundLocationState: Equatable {}
public func == (lhs: BackgroundLocationState, rhs: BackgroundLocationState) -> Bool {
    guard compareOptionals(lhs: lhs.backgroundGEOState, rhs: rhs.backgroundGEOState, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.backgroundBeaconState, rhs: rhs.backgroundBeaconState, compare: ==) else { return false }
    return true
}
// MARK: - BatteryLevelState AutoEquatable
extension BatteryLevelState: Equatable {}
public func == (lhs: BatteryLevelState, rhs: BatteryLevelState) -> Bool {
    guard compareOptionals(lhs: lhs.batteryLevel, rhs: rhs.batteryLevel, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.isNewBatteryLevel, rhs: rhs.isNewBatteryLevel, compare: ==) else { return false }
    return true
}
// MARK: - BeaconState AutoEquatable
extension BeaconState: Equatable {}
public func == (lhs: BeaconState, rhs: BeaconState) -> Bool {
    guard compareOptionals(lhs: lhs.isIBeaconRangingEnabled, rhs: rhs.isIBeaconRangingEnabled, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.maxRuntime, rhs: rhs.maxRuntime, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.minOffTime, rhs: rhs.minOffTime, compare: ==) else { return false }
    guard lhs.regions == rhs.regions else { return false }
    guard compareOptionals(lhs: lhs.filterWindowSize, rhs: rhs.filterWindowSize, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.filterMaxObservations, rhs: rhs.filterMaxObservations, compare: ==) else { return false }
    guard lhs.filterExcludeRegions == rhs.filterExcludeRegions else { return false }
    guard compareOptionals(lhs: lhs.isEddystoneScanningEnabled, rhs: rhs.isEddystoneScanningEnabled, compare: ==) else { return false }
    return true
}
// MARK: - CCRequestMessagingState AutoEquatable
extension CCRequestMessagingState: Equatable {}
public func == (lhs: CCRequestMessagingState, rhs: CCRequestMessagingState) -> Bool {
    guard compareOptionals(lhs: lhs.webSocketState, rhs: rhs.webSocketState, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.radiosilenceTimerState, rhs: rhs.radiosilenceTimerState, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.libraryTimeState, rhs: rhs.libraryTimeState, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.capabilityState, rhs: rhs.capabilityState, compare: ==) else { return false }
    return true
}
// MARK: - CapabilityState AutoEquatable
extension CapabilityState: Equatable {}
public func == (lhs: CapabilityState, rhs: CapabilityState) -> Bool {
    guard compareOptionals(lhs: lhs.locationAuthStatus, rhs: rhs.locationAuthStatus, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.bluetoothHardware, rhs: rhs.bluetoothHardware, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.batteryState, rhs: rhs.batteryState, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.isLowPowerModeEnabled, rhs: rhs.isLowPowerModeEnabled, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.isLocationServicesAvailable, rhs: rhs.isLocationServicesAvailable, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.isMotionAndFitnessAvailable, rhs: rhs.isMotionAndFitnessAvailable, compare: ==) else { return false }
    return true
}
// MARK: - CurrentBeaconState AutoEquatable
extension CurrentBeaconState: Equatable {}
public func == (lhs: CurrentBeaconState, rhs: CurrentBeaconState) -> Bool {
    guard compareOptionals(lhs: lhs.isIBeaconRangingEnabled, rhs: rhs.isIBeaconRangingEnabled, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.isInForeground, rhs: rhs.isInForeground, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.maxRuntime, rhs: rhs.maxRuntime, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.minOffTime, rhs: rhs.minOffTime, compare: ==) else { return false }
    guard lhs.regions == rhs.regions else { return false }
    guard compareOptionals(lhs: lhs.filterWindowSize, rhs: rhs.filterWindowSize, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.filterMaxObservations, rhs: rhs.filterMaxObservations, compare: ==) else { return false }
    guard lhs.filterExcludeRegions == rhs.filterExcludeRegions else { return false }
    guard compareOptionals(lhs: lhs.offTime, rhs: rhs.offTime, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.maxOnTimeStart, rhs: rhs.maxOnTimeStart, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.isEddystoneScanningEnabled, rhs: rhs.isEddystoneScanningEnabled, compare: ==) else { return false }
    return true
}
// MARK: - CurrentGEOState AutoEquatable
extension CurrentGEOState: Equatable {}
public func == (lhs: CurrentGEOState, rhs: CurrentGEOState) -> Bool {
    guard compareOptionals(lhs: lhs.isInForeground, rhs: rhs.isInForeground, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.isSignificantLocationChangeMonitoringState, rhs: rhs.isSignificantLocationChangeMonitoringState, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.isStandardGEOEnabled, rhs: rhs.isStandardGEOEnabled, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.activityType, rhs: rhs.activityType, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.maxRuntime, rhs: rhs.maxRuntime, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.minOffTime, rhs: rhs.minOffTime, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.desiredAccuracy, rhs: rhs.desiredAccuracy, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.distanceFilter, rhs: rhs.distanceFilter, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.pausesUpdates, rhs: rhs.pausesUpdates, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.offTime, rhs: rhs.offTime, compare: ==) else { return false }
    return true
}
// MARK: - CurrentLocationState AutoEquatable
extension CurrentLocationState: Equatable {}
public func == (lhs: CurrentLocationState, rhs: CurrentLocationState) -> Bool {
    guard compareOptionals(lhs: lhs.currentGEOState, rhs: rhs.currentGEOState, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.currentBeaconState, rhs: rhs.currentBeaconState, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.currentiBeaconMonitoringState, rhs: rhs.currentiBeaconMonitoringState, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.wakeupState, rhs: rhs.wakeupState, compare: ==) else { return false }
    return true
}
// MARK: - CurrentiBeaconMonitoringState AutoEquatable
extension CurrentiBeaconMonitoringState: Equatable {}
public func == (lhs: CurrentiBeaconMonitoringState, rhs: CurrentiBeaconMonitoringState) -> Bool {
    guard lhs.monitoringRegions == rhs.monitoringRegions else { return false }
    return true
}
// MARK: - CurrentGeofencesMonitoringState AutoEquatable
extension CurrentGeofencesMonitoringState: Equatable {}
public func == (lhs: CurrentGeofencesMonitoringState, rhs: CurrentGeofencesMonitoringState) -> Bool {
    guard lhs.monitoringGeofences == rhs.monitoringGeofences else { return false }
    return true
}
// MARK: - ForegroundGEOState AutoEquatable
extension ForegroundGEOState: Equatable {}
internal func == (lhs: ForegroundGEOState, rhs: ForegroundGEOState) -> Bool {
    guard compareOptionals(lhs: lhs.fgGEOEnabled, rhs: rhs.fgGEOEnabled, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.fgActivityType, rhs: rhs.fgActivityType, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.fgMaxRuntime, rhs: rhs.fgMaxRuntime, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.fgMinOffTime, rhs: rhs.fgMinOffTime, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.fgDesiredAccuracy, rhs: rhs.fgDesiredAccuracy, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.fgDistanceFilter, rhs: rhs.fgDistanceFilter, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.fgPausesUpdates, rhs: rhs.fgPausesUpdates, compare: ==) else { return false }
    return true
}
// MARK: - ForegroundLocationState AutoEquatable
extension ForegroundLocationState: Equatable {}
public func == (lhs: ForegroundLocationState, rhs: ForegroundLocationState) -> Bool {
    guard compareOptionals(lhs: lhs.foregroundGEOState, rhs: rhs.foregroundGEOState, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.foregroundBeaconState, rhs: rhs.foregroundBeaconState, compare: ==) else { return false }
    return true
}
// MARK: - InertialState AutoEquatable
extension InertialState: Equatable {}
public func == (lhs: InertialState, rhs: InertialState) -> Bool {
    guard compareOptionals(lhs: lhs.isEnabled, rhs: rhs.isEnabled, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.interval, rhs: rhs.interval, compare: ==) else { return false }
    return true
}
// MARK: - ContactBluetoothState AutoEquatable
extension ContactBluetoothState: Equatable {}
public func == (lhs: ContactBluetoothState, rhs: ContactBluetoothState) -> Bool {
    guard compareOptionals(lhs: lhs.isEnabled, rhs: rhs.isEnabled, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.serviceUUID, rhs: rhs.serviceUUID, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.scanInterval, rhs: rhs.scanInterval, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.scanDuration, rhs: rhs.scanDuration, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.advertiseInterval, rhs: rhs.advertiseInterval, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.advertiseDuration, rhs: rhs.advertiseDuration, compare: ==) else { return false }

    return true
}
// MARK: - EIDState AutoEquatable
extension EIDState: Equatable {}
public func == (lhs: EIDState, rhs: EIDState) -> Bool {
    guard compareOptionals(lhs: lhs.secret, rhs: rhs.secret, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.k, rhs: rhs.k, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.clockOffset, rhs: rhs.clockOffset, compare: ==) else { return false }
    return true
}
// MARK: - LibraryTimeState AutoEquatable
extension LibraryTimeState: Equatable {}
public func == (lhs: LibraryTimeState, rhs: LibraryTimeState) -> Bool {
    guard compareOptionals(lhs: lhs.lastTrueTime, rhs: rhs.lastTrueTime, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.bootTimeIntervalAtLastTrueTime, rhs: rhs.bootTimeIntervalAtLastTrueTime, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.systemTimeAtLastTrueTime, rhs: rhs.systemTimeAtLastTrueTime, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.lastRebootTime, rhs: rhs.lastRebootTime, compare: ==) else { return false }
    return true
}
// MARK: - LifecycleState AutoEquatable
extension LifecycleState: Equatable {}
public func == (lhs: LifecycleState, rhs: LifecycleState) -> Bool {
    guard lhs.lifecycleState == rhs.lifecycleState else { return false }
    return true
}
// MARK: - TimerState AutoEquatable
extension TimerState: Equatable {}
public func == (lhs: TimerState, rhs: TimerState) -> Bool {
    guard compareOptionals(lhs: lhs.timer, rhs: rhs.timer, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.timeInterval, rhs: rhs.timeInterval, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.startTimeInterval, rhs: rhs.startTimeInterval, compare: ==) else { return false }
    return true
}
// MARK: - WakeupState AutoEquatable
extension WakeupState: Equatable {}
public func == (lhs: WakeupState, rhs: WakeupState) -> Bool {
    guard lhs.ccWakeup == rhs.ccWakeup else { return false }
    return true
}
// MARK: - WebSocketState AutoEquatable
extension WebSocketState: Equatable {}
public func == (lhs: WebSocketState, rhs: WebSocketState) -> Bool {
    guard compareOptionals(lhs: lhs.connectionState, rhs: rhs.connectionState, compare: ==) else { return false }
    return true
}

// MARK: - AutoEquatable for Enums
