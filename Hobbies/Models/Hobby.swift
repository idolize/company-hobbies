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
    
    var templateImage: String? {
        return template?.rawValue
    }
    
    var gcsImagePath: String {
        return "images/\(companyId)/hobbies/\(id).jpg"
    }
    
    var docRef: DocumentReference {
        return Firestore.firestore().document("companies/\(companyId)/hobbies/\(id)")
    }
    
    var documentData: [String : Any] {
        return [
            "name": name,
            "description": description,
            "external": external,
            "template": template?.rawValue as Any
        ]
    }
    
    init(id: String, name: String, companyId: String, description: String?, template: Template?, external: [String: String]?) {
        self.id = id
        self.name = name
        self.companyId = companyId
        self.template = template
        if let description = description {
            self.description = description
        }
        if let external = external {
            self.external = external
        }
    }
    
    init(id: String, name: String, companyId: String) {
        self.init(id: id, name: name, companyId: companyId, description: nil, template: nil, external: nil)
    }
    
    init(from hobbyDoc: DocumentSnapshot, companyId: String) {
        self.init(
            id: hobbyDoc.documentID,
            name: hobbyDoc.get("name") as! String,
            companyId: companyId,
            description: hobbyDoc.get("description") as? String,
            template: hobbyDoc.get("template") != nil ?
                Hobby.Template(rawValue: hobbyDoc.get("template") as! String) : nil,
            external: hobbyDoc.get("external") as? [String: String]
        )
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
