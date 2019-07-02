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
    var createdButNotVerified: Bool
    @State var isNewUser = false
    @State var email: String = ""
    @State var password: String = ""
    @State var error: Error? = nil
    
    var body: some View {
        Group {
            if createdButNotVerified == true {
                VStack {
                    Text("You must verify your email address to continue")
                        .padding()
                    Button(action: resendVerificationEmail) {
                        Text("Resend email")
                    }.padding()
                }.padding()
            } else {
                Form {
                    Section(header: Text("Email")) {
                        TextField($email, placeholder: Text("user@company.com"))
                            .textContentType(.emailAddress)
                    }
                    
                    Section(header: Text("Password")) {
                        SecureField($password, placeholder: Text("password"))
                            .textContentType(.password)
                    }
                    
                    Section {
                        Toggle(isOn: $isNewUser) {
                            Text("Don't have an account yet?")
                        }
                    }
                    
                    Section {
                        Button(action: submit) {
                            Text(isNewUser ? "Sign up" : "Sign in")
                        }
                    }
                    
                    if error != nil {
                        Text(error!.localizedDescription)
                            .color(.red)
                    }
                }
            }
        }
        .navigationBarTitle(Text("Log in to your account"))
    }
    
    private func onLogin(user: AuthDataResult?, error: Error?) {
        self.error = error
    }
    
    func resendVerificationEmail() {
        Auth.auth().currentUser?.sendEmailVerification()
    }
    
    func submit() {
        if (!email.hasSuffix("@snapchat.com") && !email.hasSuffix("@snap.com")) {
            error = RuntimeError("Email domain is not supported yet!")
            return
        }
        error = nil;
        if (isNewUser) {
            Auth.auth().createUser(withEmail: email, password: password, completion: onLogin)
        } else {
            Auth.auth().signIn(withEmail: email, password: password, completion: onLogin)
        }
    }
}

#if DEBUG
struct Onboarding_Previews : PreviewProvider {
    static var previews: some View {
        Onboarding(createdButNotVerified: false)
    }
}
#endif
