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
    let createdButNotVerified: Bool
    
    var body: some View {
        Group {
            if createdButNotVerified == true {
                NotVerified()
            } else {
                LogInOrSignUpForm()
            }
        }
        .navigationBarTitle(Text("SIGN IN"))
    }
}

struct NotVerified : View {
    var body: some View {
        VStack {
            Text("You must verify your email address to continue")
                .lineLimit(2)
                .frame(height: 300)
                .padding()
            Button(action: resendVerificationEmail) {
                Text("Resend email")
            }
            Button(action: signOut) {
                Text("Sign out")
            }
        }.padding()
    }
    
    private func resendVerificationEmail() {
        Auth.auth().currentUser?.sendEmailVerification()
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign out failed")
        }
    }
}

struct LogInOrSignUpForm : View {
    @State var isNewUser = false
    @State var email: String = ""
    @State var password: String = ""
    
    @State var error: Error? = nil
    
    var body: some View {
        Form {
            if error != nil {
                Text(error!.localizedDescription)
                    .color(.red)
                    .lineLimit(5)
            }
            
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
                Button(action: submit) {
                    Text(isNewUser ? "Sign up" : "Sign in")
                }
            }
        }
    }
    
    private func onLogin(user: AuthDataResult?, error: Error?) {
        self.error = error
    }
    
    private func submit() {
        if (!email.hasSuffix("@snapchat.com") && !email.hasSuffix("@snap.com") && !email.hasSuffix("@gmail.com")) {
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
