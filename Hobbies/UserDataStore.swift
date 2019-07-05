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

struct UserData : Identifiable {
    let id: String
    let email: String
    
    var isEmailVerified: Bool = false
    var name: String?
    var photoUrl: URL?
    var companyRef: DocumentReference?
    var myHobbyRefs: [DocumentReference]?
    
    init(id: String, email: String) {
        self.id = id
        self.email = email
    }
    
    init(from authUser: User) {
        self.id = authUser.uid
        self.email = authUser.email ?? ""
        self.name = authUser.displayName
        self.photoUrl = authUser.photoURL
        self.isEmailVerified = authUser.isEmailVerified
    }
}

// TODO move all of this to something more sane - like the new Combine framework!!
// see the "use-combine" branch for a first attempt at such a migration
final class UserDataStore : BindableObject {
    static let `default` = UserDataStore()
    
    static func getAuthStatus(user: UserData?) -> AuthStatus {
        guard let user = user else { return .notLoggedIn }
        if !user.isEmailVerified {
            return .waitingForVerification
        }
        if user.companyRef == nil {
            return .loggedIn
        }
        return .loggedInToCompany
    }
    
    var userData: UserData? = nil {
        didSet {
            if authStatus == .loggedIn {
                print("Auth status changed to logged in")
                forceRefreshUser()
            }
            if authStatus == .loggedInToCompany && oldValue?.companyRef != userData?.companyRef {
                print("Auth status changed -- logged into company!")
                NotificationCenter.default.post(name:
                    Notification.Name(rawValue: "software.idol.userDataStore.loggedInToCompany"), object: self)
            }
            if authStatus == .waitingForVerification {
                print("Auth status changed -- waiting for verification")
                startPollingVerification()
            } else {
                stopPollingVerification()
            }
            didChange.send()
        }
    }
    var authStatus: AuthStatus {
        return UserDataStore.getAuthStatus(user: userData)
    }
    
    let didChange = PassthroughSubject<Void, Never>()
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var verificationRefreshTimer: Timer?
    
    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let strongSelf = self else { return }
            strongSelf.userData = user != nil ? UserData(from: user!) : nil
        }
        if let authUser = Auth.auth().currentUser {
            userData = UserData(from: authUser)
        }
    }
    
    func startPollingVerification() {
        if verificationRefreshTimer != nil { return }
        print("Start polling for verification")
        // https://stackoverflow.com/a/41341827
        verificationRefreshTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {timer in
            if self.authStatus == .waitingForVerification {
                if let authUser = Auth.auth().currentUser {
                    authUser.reload() { error in
                        if let authUser = Auth.auth().currentUser, error == nil && authUser.isEmailVerified {
                            print("Poll result: VERIFIED!")
                            self.forceRefreshUser()
                        }
                        print("Poll result: not verified yet...")
                        if error != nil {
                            print(error!)
                        }
                    }
                }
            } else {
                self.stopPollingVerification()
            }
        }
    }
    
    func stopPollingVerification() {
        if verificationRefreshTimer != nil {
            print("Stop polling for verification")
            verificationRefreshTimer?.invalidate()
            verificationRefreshTimer = nil
        }
    }
    
    func forceRefreshUser() {
        print("Force refresh user begin")
        guard let authUser = Auth.auth().currentUser else { return }
        authUser.getIDTokenForcingRefresh(true) { token, error in
            print("Force refresh user success")
            if error == nil {
                self.loadCompanyData()
            } else {
                print(error!)
            }
        }
    }
    
    func loadCompanyData() {
        if var userData = userData {
            // load the companyUser details
            let companyUserRef = Firestore.firestore().collection("companyUsers").document(userData.id)
            companyUserRef.getDocument { doc, error in
                if error != nil {
                    print(error!)
                }
                if let doc = doc {
                    userData.companyRef = doc.get("company") as! DocumentReference?
                    userData.myHobbyRefs = doc.get("hobbies") as! [DocumentReference]?
                    self.userData = userData
                } else {
                    print("Missing doc -- cannot set company details")
                }
            }
        } else {
            print("Missing user data -- cannot load company details")
        }
    }
    
    deinit {
        if let authStateHandle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }
}
