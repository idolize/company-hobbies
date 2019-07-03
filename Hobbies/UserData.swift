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
    
    init(from user: User) {
        self.id = user.uid
        self.email = user.email ?? ""
        self.name = user.displayName
        self.photoUrl = user.photoURL
        self.isEmailVerified = user.isEmailVerified
    }
}

final class UserDataStore {
    static let `default` = UserDataStore()
    
    private static func getAuthStatus(user: UserData?) -> AuthStatus {
        guard let user = user else { return .notLoggedIn }
        if !user.isEmailVerified {
            return .waitingForVerification
        }
        if user.companyRef == nil {
            return .loggedIn
        }
        return .loggedInToCompany
    }
    
    let authStatusSubject: CurrentValueSubject<AuthStatus, Never>
    let userDataSubject: CurrentValueSubject<UserData?, Never>
    
    var userData: UserData? {
        userDataSubject.value
    }
    var authStatus: AuthStatus {
        authStatusSubject.value
    }
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        userDataSubject = CurrentValueSubject(nil)
        authStatusSubject = CurrentValueSubject(UserDataStore.getAuthStatus(user: userDataSubject.value))
        
        let authStatusFromUserDataPublisher = userDataSubject
            .replaceError(with: nil)
            .compactMap({ $0 == nil ? nil : UserDataStore.getAuthStatus(user: $0) })
        _ = authStatusFromUserDataPublisher.subscribe(authStatusSubject)
        
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let strongSelf = self else { return }
            strongSelf.userDataSubject.send(user == nil ? nil : UserData(from: user!))
        }
        
        let waitingForVerificationPublisher = authStatusSubject.removeDuplicates()
            .filter({ $0 == .waitingForVerification })
        
        let pollWhileWaitingPublisher = waitingForVerificationPublisher
            .zip(Timer.publish(every: 7, on: RunLoop.current, in: RunLoop.Mode.default))
        
        let refreshAndGetCompanyInfoPublisher = waitingForVerificationPublisher
            .combineLatest(pollWhileWaitingPublisher) { auth, _ in return auth }
            .flatMap { authStatus in
                return Publishers.Future<User?, Never> { promise in
                    if let user = Auth.auth().currentUser {
                        user.reload() { error in
                            if let user = Auth.auth().currentUser, error == nil && user.isEmailVerified {
                                promise(.success(user))
                            }
                            promise(.success(nil))
                        }
                    }
                }
            }
            .filter({ $0 != nil })
            .flatMap { user in
                return Publishers.Future<DocumentSnapshot?, Never> { promise in
                    user?.getIDTokenForcingRefresh(true) { token, error in
                        // TODO handle error
                        // load the companyUser details
                        if let user = self.userData {
                            let companyUserRef = Firestore.firestore().collection("companyUsers").document(user.id)
                            companyUserRef.getDocument { doc, error in
                                // TODO handle error
                                promise(.success(doc))
                            }
                        }
                    }
                }
            }
        
        let updateUserWithCompanyPublisher = refreshAndGetCompanyInfoPublisher
            .compactMap { doc -> UserData? in
                if let doc = doc, var user = self.userData {
                    user.companyRef = doc.get("company") as! DocumentReference?
                    user.myHobbyRefs = doc.get("hobbies") as! [DocumentReference]?
                    return user
                }
                return self.userData
            }
            .map({ u -> UserData? in u })
        
        _ = updateUserWithCompanyPublisher.subscribe(userDataSubject)
    }
    
    deinit {
        if let authStateHandle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
        userDataSubject.send(completion: .finished)
    }
}
