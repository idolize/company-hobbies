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

extension Notification.Name {
    static let hobbyUserLoggedInToCompany: NSNotification.Name = Notification.Name(rawValue: "software.idol.userDataStore.loggedInToCompany")
}

enum AuthStatus {
    case notLoggedIn, waitingForVerification, loggedIn, loggedInToCompany
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
    
//    var userData: UserData? = nil {
//        didSet {
//            if authStatus == .loggedIn {
//                print("Auth status changed to logged in")
//                forceRefreshUser()
//            }
//            if authStatus == .loggedInToCompany && oldValue?.companyRef != userData?.companyRef {
//                print("Auth status changed -- logged into company!")
//                NotificationCenter.default.post(name: Notification.Name.hobbyUserLoggedInToCompany, object: self)
//            }
//            if authStatus == .waitingForVerification {
//                print("Auth status changed -- waiting for verification")
//                startPollingVerification()
//            } else {
//                stopPollingVerification()
//            }
//            didChange.send()
//        }
//    }
//    var authStatus: AuthStatus {
//        return UserDataStore.getAuthStatus(user: userData)
//    }
//    let didChange = PassthroughSubject<Void, Never>()
    
    let authStatusSubject: CurrentValueSubject<AuthStatus, Never>
    let userDataSubject: CurrentValueSubject<UserData?, Never>
    
    var userData: UserData? {
        userDataSubject.value
    }
    var authStatus: AuthStatus {
        authStatusSubject.value
    }
    
    let didChange: AnyPublisher<Void, Never>
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var verificationRefreshTimer: Timer?
    
    init() {
//        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
//            guard let strongSelf = self else { return }
//            strongSelf.userData = user != nil ? UserData(from: user!) : nil
//        }
//        if let authUser = Auth.auth().currentUser {
//            userData = UserData(from: authUser)
//        }
        
        userDataSubject = CurrentValueSubject(Auth.auth().currentUser != nil ? UserData(from: Auth.auth().currentUser!) : nil)
        authStatusSubject = CurrentValueSubject(UserDataStore.getAuthStatus(user: userDataSubject.value))
        didChange = userDataSubject.map({ _ in })
            .merge(with: authStatusSubject.map({ _ in }))
            .eraseToAnyPublisher()
        
        let userDataPublisher = userDataSubject.print("userDataSubject")
        let authStatusPublisher = authStatusSubject.print("authStatusSubject")
        
        let authStatusFromUserDataPublisher = userDataPublisher
            .replaceError(with: nil) // Not needed currently
            .compactMap({ $0 == nil ? nil : UserDataStore.getAuthStatus(user: $0) })
        _ = authStatusFromUserDataPublisher.subscribe(authStatusSubject)
        
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let strongSelf = self else { return }
            strongSelf.userDataSubject.send(user == nil ? nil : UserData(from: user!))
        }
        
        let waitingForVerificationPublisher = authStatusPublisher.removeDuplicates()
            .filter({ $0 == .waitingForVerification })
            .print("waitingForVerificationPublisher")
        
        //TODO don't think this zip will work:
        // The returned publisher waits until both publishers have emitted an event, then delivers the oldest unconsumed event from each
        // publisher together as a tuple to the subscriber. For example, if publisher P1 emits elements a and b, and publisher P2 emits
        // event c, the zip publisher emits the tuple (a, c).
        // It won’t emit a tuple with event b until P2 emits another event.
        // If either upstream publisher finishes successfuly or fails with an error, the zipped publisher does the same.
        let pollWhileWaitingPublisher = waitingForVerificationPublisher
            .zip(Timer.publish(every: 5.0, on: RunLoop.current, in: RunLoop.Mode.default))
            .map({ _ -> AuthStatus in .waitingForVerification })
            .print("pollWhileWaitingPublisher")
        
        let refreshVerifiedTokenPublisher = waitingForVerificationPublisher
            .merge(with: pollWhileWaitingPublisher)
            .flatMap { authStatus in
                return Publishers.Future<User?, Never> { promise in
                    print("\nPoll begin")
                    if let user = Auth.auth().currentUser {
                        user.reload() { error in
                            if let user = Auth.auth().currentUser, error == nil && user.isEmailVerified {
                                print("\nPoll result: VERIFIED!")
                                promise(.success(user))
                            } else {
                                if error != nil {
                                    print(error!)
                                } else {
                                    print("\nPoll result: not verified yet...")
                                }
                                // TODO handle error
                                promise(.success(nil))
                            }
                        }
                    } else {
                        promise(.success(nil))
                    }
                }
            }
            .compactMap({ $0 })
            .print("refreshVerifiedTokenPublisher")
        
        let loggedInPublisher = authStatusPublisher.removeDuplicates()
            .filter({ $0 == .loggedIn })
            .print("loggedInPublisher")
        
        let companyUserLoadedPublisher = refreshVerifiedTokenPublisher
            .merge(with: loggedInPublisher.map({ _ in Auth.auth().currentUser! }))
            .flatMap { user in
                return Publishers.Future<DocumentSnapshot?, Never> { promise in
                    print("Force refresh user begin")
                    user.getIDTokenForcingRefresh(true) { token, error in
                        if let user = self.userData, error == nil {
                            print("\nForce refresh user success")
                            // load the companyUser details
                            let companyUserRef = Firestore.firestore().collection("companyUsers").document(user.id)
                            companyUserRef.getDocument { doc, error in
                                if error != nil {
                                    print(error!)
                                }
                                // TODO handle error
                                promise(.success(doc))
                            }
                        } else {
                            if error != nil {
                                print(error!)
                            }
                            // TODO handle error
                            promise(.success(nil))
                        }
                    }
                }
            }
            .print("companyUserLoadedPublisher")
        
        let updateUserWithCompanyPublisher = companyUserLoadedPublisher
            .compactMap { doc -> UserData? in
                if let doc = doc, var userData = self.userData {
                    userData.companyRef = doc.get("company") as? DocumentReference? ?? nil
                    userData.myHobbyRefs = doc.get("hobbies") as? [DocumentReference] ?? []
                    return userData
                }
                return self.userData
            }
            .map({ u -> UserData? in u })
        _ = updateUserWithCompanyPublisher.subscribe(userDataSubject)
        
        _ = userDataSubject.sink(receiveValue: { userData in
            if userData?.companyRef != nil {
                print("\nAuth status changed -- logged into company!")
                NotificationCenter.default.post(name: Notification.Name.hobbyUserLoggedInToCompany, object: self)
            }
        })
    }
    
//    private func startPollingVerification() {
//        if verificationRefreshTimer != nil { return }
//        print("Start polling for verification")
//        // https://stackoverflow.com/a/41341827
//        verificationRefreshTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {timer in
//            if self.authStatus == .waitingForVerification {
//                if let authUser = Auth.auth().currentUser {
//                    authUser.reload() { error in
//                        if let authUser = Auth.auth().currentUser, error == nil && authUser.isEmailVerified {
//                            print("Poll result: VERIFIED!")
//                            self.forceRefreshUser()
//                        }
//                        print("Poll result: not verified yet...")
//                        if error != nil {
//                            print(error!)
//                        }
//                    }
//                }
//            } else {
//                self.stopPollingVerification()
//            }
//        }
//    }
//
//    private func stopPollingVerification() {
//        if verificationRefreshTimer != nil {
//            print("Stop polling for verification")
//            verificationRefreshTimer?.invalidate()
//            verificationRefreshTimer = nil
//        }
//    }
//
//    func forceRefreshUser() {
//        print("Force refresh user begin")
//        guard let authUser = Auth.auth().currentUser else { return }
//        authUser.getIDTokenForcingRefresh(true) { token, error in
//            print("Force refresh user success")
//            if error == nil {
//                self.loadCompanyData()
//            } else {
//                print(error!)
//            }
//        }
//    }
//
//    func loadCompanyData() {
//        if var userData = userData {
//            // load the companyUser details
//            let companyUserRef = Firestore.firestore().collection("companyUsers").document(userData.id)
//            companyUserRef.getDocument { doc, error in
//                if error != nil {
//                    print(error!)
//                }
//                if let doc = doc {
//                    userData.companyRef = doc.get("company") as? DocumentReference? ?? nil
//                    userData.myHobbyRefs = doc.get("hobbies") as? [DocumentReference] ?? []
//                    self.userData = userData
//                } else {
//                    print("Missing doc -- cannot set company details")
//                }
//            }
//        } else {
//            print("Missing user data -- cannot load company details")
//        }
//    }
    
    func joinHobby(hobby: Hobby) {
        if var userData = userData, !userData.isMemberOfHobby(hobbyId: hobby.id) {
            print("Joining hobby")
            userData.myHobbyRefs.append(hobby.docRef)
//            self.userData = userData
            userDataSubject.send(userData)
            let fields = [ "hobbies": userData.myHobbyRefs ]
            userData.docRef.updateData(fields as [AnyHashable : Any]) { error in
                if error != nil {
                    print(error!)
                } else {
                    print("Hobby joined")
                }
            }
        }
    }
    
    func leaveHobby(hobby: Hobby) {
        if var userData = userData, let index = userData.myHobbyRefs.firstIndex(where: {$0.documentID == hobby.id}) {
            print("Leaving hobby")
            userData.myHobbyRefs.remove(at: index)
//            self.userData = userData
            userDataSubject.send(userData)
            let fields = [ "hobbies": userData.myHobbyRefs ]
            userData.docRef.updateData(fields as [AnyHashable : Any]) { error in
                if error != nil {
                    print(error!)
                } else {
                    print("Hobby left")
                }
            }
        }
    }
    
    deinit {
        if let authStateHandle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
        userDataSubject.send(completion: .finished)
    }
}
