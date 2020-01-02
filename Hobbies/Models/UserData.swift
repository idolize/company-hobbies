//
//  UserData.swift
//  Hobbies
//
//  Created by David Idol on 7/7/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import Firebase
import SwiftUI

struct UserData : Identifiable {
    let id: String
    let email: String
    
    var isEmailVerified: Bool = false
    var name: String?
    var photoUrl: URL?
    var companyRef: DocumentReference?
    var userDetailsFetchStatus: FetchStatus = FetchStatus.notFetched
    var myHobbyRefs: [DocumentReference] = []
    
    var docRef: DocumentReference {
        return Firestore.firestore().collection("companyUsers").document(id);
    }
    
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
    
    func isMemberOfHobby(hobbyId: String) -> Bool {
        return myHobbyRefs.firstIndex(where: { $0.documentID == hobbyId }) != nil
    }
}
