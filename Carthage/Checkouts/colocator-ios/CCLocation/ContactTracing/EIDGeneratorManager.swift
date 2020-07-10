//
//  ContactTracing+EID.swift
//  CCLocation
//
//  Created by TCode on 15/06/2020.
//  Copyright © 2020 Crowd Connected. All rights reserved.
//

import Foundation
import CommonCrypto
import ReSwift

class EIDGeneratorManager: NSObject {

    public static let eidLength = 16 // in .utf8
    
    internal var secret = ""
    internal var k = 0
    internal var clockOffset = 0
    
    internal var renewEIDTimer: Timer? = nil
    private var lastGeneratedEID: Data? = nil
    
    var currentEIDState: EIDState!
    weak var stateStore: Store<LibraryState>!
    
    init(stateStore: Store<LibraryState>) {
        super.init()
        
        self.stateStore = stateStore
        currentEIDState = EIDState(secret: "",
                                   k: 0,
                                   clockOffset: 0)
        stateStore.subscribe(self)
    }
    
    func generateEIDData() -> Data? {
        if lastGeneratedEID == nil {
            lastGeneratedEID = generateEIDString()?.data(using: .utf8)
            startEIDRenewTimer()
            
            return lastGeneratedEID
            
        } else {
            return lastGeneratedEID
        }
    }
    
    internal func startEIDRenewTimer() {
        if clockOffset == 0 { return }
        
        if renewEIDTimer != nil {
            renewEIDTimer?.invalidate()
            renewEIDTimer = nil
        }
        
        renewEIDTimer = Timer.scheduledTimer(timeInterval: TimeInterval(clockOffset / 1000),
                                             target: self,
                                             selector: #selector(self.renewEID),
                                             userInfo: nil,
                                             repeats: false)
    }
    
    @objc func renewEID() {
        lastGeneratedEID = generateEIDString()?.data(using: .utf8)
        startEIDRenewTimer()
    }
    
    private func generateEIDString() -> String? {
        if secret.isEmpty {
            Log.warning("EID settings are not configured yet. Cannot generate EID")
            return nil
        }
        
        let timeCounter = Int(Date().timeIntervalSince1970)
        
        if let tempKey = generateTempKey(timeCounter: timeCounter) {
            let rotationIndexTimeCounter = getRotationIndex(time: timeCounter)
            
            if let tempEID = generateTempEID(timeCounter: rotationIndexTimeCounter, tempKey: tempKey) {
                
                let trimmedEID = extract(from: tempEID, limit: 8)
                return convertDataToHexString(trimmedEID)
                
            } else {
                Log.error("Failed to generate temp eid")
                return nil
            }
        } else {
            Log.error("Failed to generate temp key")
            return nil
        }
    }
    
    private func generateTempKey(timeCounter: Int) -> Data? {
        var tempKeyArray: [UInt8] = [UInt8]()
        tempKeyArray.append(0)
        tempKeyArray.append(0)
        tempKeyArray.append(0)
        tempKeyArray.append(0)
        tempKeyArray.append(0)
        tempKeyArray.append(0)
        tempKeyArray.append(0)
        tempKeyArray.append(0)
        tempKeyArray.append(0)
        tempKeyArray.append(0)
        tempKeyArray.append(0)
        tempKeyArray.append(255)
        tempKeyArray.append(0)
        tempKeyArray.append(0)
        
        let firstShift = UInt8 ((timeCounter >> 24) & 255)
        let secondShift = UInt8 ((timeCounter >> 16) & 255)
        
        tempKeyArray.append(firstShift)
        tempKeyArray.append(secondShift)
        
        let tempKeyData = tempKeyArray.withUnsafeBufferPointer {Data(buffer: $0)}
        
        let secretKey = secret.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! as Data
        return AESEncryption(value: tempKeyData, key: secretKey, trimKeyLength: true)
    }
    
    private func getRotationIndex(time: Int) -> Int {
        return (time >> k) << k
    }
    
    private func generateTempEID(timeCounter: Int, tempKey: Data) -> Data? {
        var tempEIDArray: [UInt8] = [UInt8]()
        tempEIDArray.append(0)
        tempEIDArray.append(0)
        tempEIDArray.append(0)
        tempEIDArray.append(0)
        tempEIDArray.append(0)
        tempEIDArray.append(0)
        tempEIDArray.append(0)
        tempEIDArray.append(0)
        tempEIDArray.append(0)
        tempEIDArray.append(0)
        tempEIDArray.append(0)
        tempEIDArray.append(UInt8(k))
        
        let firstShift = UInt8 ((timeCounter >> 24) & 255)
        let secondShift = UInt8 ((timeCounter >> 16) & 255)
        let thirdShift = UInt8 ((timeCounter >> 8) & 255)
        let forthShift = UInt8 (timeCounter & 255)
        
        tempEIDArray.append(firstShift)
        tempEIDArray.append(secondShift)
        tempEIDArray.append(thirdShift)
        tempEIDArray.append(forthShift)
        
        let tempEIDData = tempEIDArray.withUnsafeBufferPointer {Data(buffer: $0)}
        return AESEncryption(value: tempEIDData, key: tempKey)
    }
    
    private func AESEncryption(value: Data, key: Data, trimKeyLength: Bool = false) -> Data? {
        if value.count != 16 || key.count != 16 {
            Log.error("AES Encryption failed because of wrong input length. Value \(value.count) bytes, key \(key.count) bytes")
            return nil
        }
        
        let keyData: NSData! = key as NSData
        let data: NSData! = value as NSData
        
        let cryptData    = NSMutableData(length: Int(data.length) + kCCBlockSizeAES128)!
        
        let keyLength              = trimKeyLength ? size_t(kCCKeySizeAES128) : key.count
        let operation: CCOperation = UInt32(kCCEncrypt)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options:   CCOptions   = UInt32(kCCOptionECBMode)
        
        var numBytesEncrypted :size_t = 0
        
        let cryptStatus = CCCrypt(operation,
                                  algoritm,
                                  options,
                                  keyData.bytes, keyLength,
                                  nil,
                                  data.bytes, data.length,
                                  cryptData.mutableBytes, cryptData.length,
                                  &numBytesEncrypted)
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.length = Int(numBytesEncrypted)
            return cryptData as Data
        }
        return nil
    }
    
    public func convertDataToHexString(_ data: Data?) -> String? {
        return data == nil ? nil : data!.map{ String(format:"%02x", $0) }.joined()
    }
    
    public func extract(from data: Data, limit: Int) -> Data? {
        guard data.count > 0 else {
            return nil
        }
        
        return data.subdata(in: 0..<limit)
    }
}
