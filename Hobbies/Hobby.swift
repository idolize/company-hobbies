//
//  Hobby.swift
//  Hobbies
//
//  Created by David Idol on 6/29/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI

struct Hobby : Identifiable {
    var id = UUID().uuidString
    var name: String
    var description: String = ""
    var external: [String: String] = [:]
    
    var image: String {
        return name.lowercased().replacingOccurrences(of: " ", with: "")
    }
}

#if DEBUG
let testData = [
    Hobby(name: "Cooking"),
    Hobby(name: "Dancing"),
    Hobby(name: "Drawing"),
    Hobby(name: "Motorcycling"),
    Hobby(name: "Jiu Jitsu"),
]
#endif
