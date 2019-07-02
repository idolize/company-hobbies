//
//  HobbiesStore.swift
//  Hobbies
//
//  Created by David Idol on 6/29/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI
import Combine
import Firebase

class HobbiesStore : BindableObject {
    var db: Firestore
    
    var hobbies: [Hobby] {
        didSet { didChange.send() }
    }
    
    init(hobbies: [Hobby] = []) {
        self.hobbies = hobbies
        db = Firestore.firestore()
    }

    var didChange = PassthroughSubject<Void, Never>()
    
    func loadUsers() {
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
}
