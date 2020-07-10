//
//  ContactTracing+Util.swift
//  CCLocation
//
//  Created by TCode on 15/06/2020.
//  Copyright © 2020 Crowd Connected. All rights reserved.
//

import Foundation
import CoreBluetooth

class ContactTracingUUIDs {
    static var colocatorServiceUUID = CBUUID(string: "FEAA")
    static var colocatorIdCharacteristicUUID = CBUUID(string: "31AF61DB-E873-4DC0-B37D-1863AFEBD24B")
    static var keepaliveCharacteristicUUID = CBUUID(string: "6287E717-DA7D-4FC8-9432-3736D5BFD87C")
}

extension Sequence where Iterator.Element == CBService {
    func colocatorIdService() -> CBService? {
        return first(where: {$0.uuid == ContactTracingUUIDs.colocatorServiceUUID})
    }
}

extension Sequence where Iterator.Element == CBCharacteristic {
    func colocatorIdCharacteristic() -> CBCharacteristic? {
        return first(where: {$0.uuid == ContactTracingUUIDs.colocatorIdCharacteristicUUID})
    }
}

extension Sequence where Iterator.Element == CBCharacteristic {
    func keepaliveCharacteristic() -> CBCharacteristic? {
        return first(where: {$0.uuid == ContactTracingUUIDs.keepaliveCharacteristicUUID})
    }
}

extension FixedWidthInteger {
    var networkByteOrderData: Data {
        var mutableSelf = self.bigEndian // network byte order
        return Data(bytes: &mutableSelf, count: MemoryLayout.size(ofValue: mutableSelf))
    }
}

// from https://stackoverflow.com/a/38024025/17294
// CC BY-SA 4.0: https://creativecommons.org/licenses/by-sa/4.0/
extension Data {

    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }

    func to<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value
    }
}
