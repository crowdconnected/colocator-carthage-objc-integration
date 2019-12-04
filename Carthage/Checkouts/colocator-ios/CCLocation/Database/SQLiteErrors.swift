//
//  SQLiteErrors.swift
//  CCLocation
//
//  Created by Mobile Developer on 22/08/2019.
//  Copyright © 2019 Crowd Connected. All rights reserved.
//

import Foundation

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
    case Exec(message: String)
    case Finalise(message: String)
}
