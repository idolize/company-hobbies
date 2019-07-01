//
//  UserData.swift
//  Hobbies
//
//  Created by David Idol on 6/30/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import Firebase
import Combine
import SwiftUI

final class UserData : BindableObject {
    let didChange = PassthroughSubject<UserData, Never>()

    /** @var handle
        @brief The handler for the auth state listener, to allow cancelling later.
     */
    private var handle: AuthStateDidChangeListenerHandle?
    
    var user: User? = nil {
        didSet {
            didChange.send(self)
        }
    }
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let strongSelf = self else { return }
            strongSelf.user = user
        }
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
}
