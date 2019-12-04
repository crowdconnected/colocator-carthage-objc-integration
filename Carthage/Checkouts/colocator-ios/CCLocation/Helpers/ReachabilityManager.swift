//
//  ReachabilityManager.swift
//  CCLocation
//
//  Created by Ralf Kernchen on 15/08/2018.
//  Copyright © 2018 Crowd Connected. All rights reserved.
//

import Foundation

final class ReachabilityManager{
    
    let reachability: Reachability
    private init() {
        reachability = Reachability.init()!
    }
    
    static let shared = ReachabilityManager()
    
    func isReachable() -> Bool{
        return (reachability.connection != .none)
    }
    
    func isUnreachable() -> Bool{
        return (reachability.connection == .none)
    }
    
    func isReachableViaWan() -> Bool{
        return (reachability.connection == .cellular)
    }
    
    func isReachableViaWiFi() -> Bool {
        return (reachability.connection == .wifi)
    }

}

