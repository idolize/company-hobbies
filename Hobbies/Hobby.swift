//
//  Hobby.swift
//  Hobbies
//
//  Created by David Idol on 6/29/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI

struct Hobby : Identifiable {
    var id = UUID()
    var name: String
    
    var image: String {
        return name.lowercased().replacingOccurrences(of: " ", with: "")
    }
    
    var imageThumb: String {
        return image + "Thumb"
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
