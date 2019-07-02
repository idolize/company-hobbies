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

enum AuthStatus {
    case notLoggedIn, waitingForVerification, loggedIn, loggedInToCompany
}

final class UserData : BindableObject {
    static let `default` = UserData()

    var user: User? = nil {
        didSet {
            if authStatus == .waitingForVerification {
                startPollingVerification()
            } else {
                stopPollingVerification()
            }
            didChange.send(self)
        }
    }
    var companyRef: String? = nil
    var myHobbiesRefs: [String]? = nil
    
    var authStatus: AuthStatus {
        if user == nil {
            return .notLoggedIn
        }
        if !user!.isEmailVerified {
            return .waitingForVerification
        }
        if companyRef == nil {
            return .loggedIn
        }
        return .loggedInToCompany
    }
    
    let didChange = PassthroughSubject<UserData, Never>()
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var verificationRefreshTimer: Timer? = nil
    
    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let strongSelf = self else { return }
            strongSelf.user = user
        }
    }
    
    func startPollingVerification() {
        // https://stackoverflow.com/a/41341827
        verificationRefreshTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) {timer in
            if self.authStatus == .waitingForVerification {
                if let user = self.user {
                    user.reload() { error in
                        if let user = self.user, error == nil && user.isEmailVerified {
                            user.getIDTokenForcingRefresh(true)
                        }
                    }
                }
            } else {
                self.stopPollingVerification()
            }
        }
    }
    
    func stopPollingVerification() {
        if (verificationRefreshTimer != nil) {
            verificationRefreshTimer?.invalidate()
            verificationRefreshTimer = nil
        }
    }
    
    deinit {
        if let authStateHandle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }
}
