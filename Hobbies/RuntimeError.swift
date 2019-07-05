//
//  RuntimeError.swift
//  Hobbies
//
//  Created by David Idol on 7/1/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import Foundation

struct RuntimeError : Error, LocalizedError {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var errorDescription: String? {
        return NSLocalizedString(message, comment: "")
    }
}
