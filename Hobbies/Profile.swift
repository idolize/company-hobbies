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
        VStack(alignment: HorizontalAlignment.leading) {
            if userDataStore.userData != nil {
                Text("Email: \(userDataStore.userData!.email)")
                Text("Verified: \(userDataStore.userData!.isEmailVerified.description)")
                Text("Name: \(userDataStore.userData!.name ?? "nil")")
                Text("Photo URL: \(userDataStore.userData!.photoUrl?.absoluteString ?? "nil")")
                Text("Company ref: \(userDataStore.userData!.companyRef?.documentID ?? "nil")")
                Button(action: signOut) {
                    Text("Sign out")
                }
            } else {
                Text("Not signed in")
            }
            Spacer()
        }
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
