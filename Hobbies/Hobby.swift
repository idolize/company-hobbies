//
//  Hobby.swift
//  Hobbies
//
//  Created by David Idol on 6/29/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI
import Firebase

struct Hobby : Identifiable {
    enum Template : String, CaseIterable, Hashable {
        case cooking
        case dancing
        case drawing
        case motorcycling
        case martialArts
    }
    
    var id: String
    var name: String
    var description: String = ""
    var template: Template?
    var external: [String: String] = [:]
    var companyId: String
    
    var image: String? {
        return template?.rawValue
    }
    
    var docRef: DocumentReference {
        return Firestore.firestore().collection("companies").document(companyId).collection("hobbies").document(id)
    }
    
    var documentData: [String : Any] {
        return [
            "name": name,
            "description": description,
            "external": external,
            "template": template?.rawValue as Any
        ]
    }
}

#if DEBUG
let testData = [
    Hobby(id: UUID().uuidString, name: "Cooking", companyId: ""),
    Hobby(id: UUID().uuidString,name: "Dancing", companyId: ""),
    Hobby(id: UUID().uuidString,name: "Drawing", companyId: ""),
    Hobby(id: UUID().uuidString,name: "Motorcycling", companyId: ""),
    Hobby(id: UUID().uuidString,name: "Jiu Jitsu", companyId: ""),
]
#endif
