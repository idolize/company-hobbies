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
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading) {
            if userData.user != nil {
                Text("Email: \(userData.user!.email ?? "missing")")
                Text("Verified \(userData.user!.isEmailVerified.description)")
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
    }
}
#endif
