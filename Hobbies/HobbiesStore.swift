//
//  HobbiesStore.swift
//  Hobbies
//
//  Created by David Idol on 6/29/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI
import Combine

class HobbiesStore : BindableObject {
    var hobbies: [Hobby] {
        didSet { didChange.send() }
    }
    
    init(hobbies: [Hobby] = []) {
        self.hobbies = hobbies
    }

    var didChange = PassthroughSubject<Void, Never>()
}
