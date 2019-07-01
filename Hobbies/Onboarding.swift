//
//  Onboarding.swift
//  Hobbies
//
//  Created by David Idol on 6/30/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI
import Firebase

struct Onboarding : View {
    @State var email: String = ""
    @State var password: String = ""
    @State var error: Error? = nil
    
    var body: some View {
        Form {
            Section(header: Text("Email")) {
                TextField($email)
                    .textContentType(.emailAddress)
            }
            
            Section(header: Text("Password")) {
                SecureField($password)
                    .textContentType(.password)
            }
            
            Section {
                Button(action: submit) {
                    Text("Sign in")
                }
            }
            
            if error != nil {
                Text(error!.localizedDescription)
                    .color(.red)
            }
        }
        .navigationBarHidden(true)
    }
    
    func submit() {
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            self.error = error
        }
    }
}

#if DEBUG
struct Onboarding_Previews : PreviewProvider {
    static var previews: some View {
        Onboarding()
    }
}
#endif
