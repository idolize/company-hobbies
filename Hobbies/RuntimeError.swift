//
//  RuntimeError.swift
//  Hobbies
//
//  Created by David Idol on 7/1/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

struct RuntimeError : Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
}
