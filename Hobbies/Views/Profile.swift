//
//  Profile.swift
//  Hobbies
//
//  Created by David Idol on 6/30/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI
import Firebase

struct Profile : View {
    @EnvironmentObject var userDataStore: UserDataStore
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 15.0) {
            if userDataStore.userData != nil {
                Text("Email: \(userDataStore.userData!.email)")
                Text("Verified: \(userDataStore.userData!.isEmailVerified.description)")
                Text("Name: \(userDataStore.userData!.name ?? "none")")
                Text("Photo URL: \(userDataStore.userData!.photoUrl?.absoluteString ?? "none")")
                Text("Company ref: \(userDataStore.userData!.companyRef?.documentID ?? "none")")
                Text("Hobbies: \(userDataStore.userData!.myHobbyRefs.map({ ref in ref.documentID }).joined(separator: ", "))")
                Button(action: signOut) {
                    Text("Sign out")
                }
            } else {
                Text("Not signed in")
            }
            Spacer()
        }
        .padding(.top)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign out failed")
        }
    }
}

#if DEBUG
struct Profile_Previews : PreviewProvider {
    static var previews: some View {
        Profile()
            .environmentObject(UserDataStore.default)
    }
}
#endif
