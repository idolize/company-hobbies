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
        NotificationCenter.default.addObserver(self, selector: #selector(HobbiesStore.loadHobbies(notification:)), name: Notification.Name(rawValue: "software.idol.userDataStore.loggedInToCompany"), object: nil)
    }

    var didChange = PassthroughSubject<Void, Never>()
    
    @objc func loadHobbies(notification: Notification) {
        print("Loading hobbies")
        if let userDataStore = notification.object as? UserDataStore, let userData = userDataStore.userData {
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
                            external: doc.get("external") as! [String: String]
                        )
                    })
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
