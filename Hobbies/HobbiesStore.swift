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
    static let `default` = HobbiesStore()
    
    var db: Firestore
    
    var hobbies: [Hobby] = [] {
        didSet { didChange.send() }
    }
    
    init() {
        db = Firestore.firestore()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(HobbiesStore.handleLoggedInToCompany(notification:)),
                                               name: Notification.Name(rawValue: "software.idol.userDataStore.loggedInToCompany"),
                                               object: nil)
    }

    var didChange = PassthroughSubject<Void, Never>()
    
    @objc private func handleLoggedInToCompany(notification: Notification) {
        if let userDataStore = notification.object as? UserDataStore {
            loadHobbies(userDataStore: userDataStore)
        }
    }
    
    func setHobbyImage() {
        
    }
    
    func updateHobby(hobby: Hobby) {
        if let index = hobbies.firstIndex(where: {$0.id == hobby.id}) {
            print("Optimistically updating hobby \(hobby.id)")
            hobbies[index] = hobby
            didChange.send()
        }
        print("Saving updated hobby \(hobby.id) to server", hobby.documentData)
        let docRef = db.collection("companies").document(hobby.companyId).collection("hobbies").document(hobby.id)
        docRef.setData(hobby.documentData) { err in
            if err != nil {
                print("Error updating hobby \(hobby.id)")
            } else {
                print("Save success")
            }
        }
    }
    
    func loadHobbies(userDataStore: UserDataStore) {
        print("Loading hobbies")
        if let userData = userDataStore.userData {
            userData.companyRef!.collection("hobbies").getDocuments() { querySnapshot, err in
                if let err = err {
                    print("Error getting hobbies documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
                    print("Loading hobbies success")
                    self.hobbies = querySnapshot!.documents.map({ doc in
                        return Hobby(
                            id: doc.documentID,
                            name: doc.get("name") as! String,
                            description: doc.get("description") as! String,
                            template: doc.get("template") != nil ? Hobby.Template(rawValue: doc.get("template") as! String) : nil,
                            external: doc.get("external") as! [String: String],
                            companyId: userData.companyRef!.documentID
                        )
                    })
                    .sorted(by: {one, two in one.name < two.name })
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
