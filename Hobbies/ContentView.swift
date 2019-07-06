//
//  ContentView.swift
//  Hobbies
//
//  Created by David Idol on 6/29/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var hobbiesStore: HobbiesStore
    @State var activeTab: Int = 0
    
    var body: some View {
        NavigationView {
            if userDataStore.userData != nil && userDataStore.userData!.isEmailVerified {
                TabbedView(selection: $activeTab) {
                    HobbyList(hobbiesStore: hobbiesStore)
                        .tabItemLabel(VStack {
                            Image("search")
                            Text("Explore")
                        })
                        .tag(0)
                
                
                    Profile()
                        .tabItemLabel(VStack {
                            Image("user")
                            Text("Profile")
                        })
                        .tag(1)
                }
                .navigationBarTitle(Text(activeTab == 0 ? "SNAP, INC." : "PROFILE"))
                    .navigationBarItems(trailing: Button(action: {}) {
                        Text("Hi")
                    })
            } else {
                Onboarding(createdButNotVerified: userDataStore.userData != nil)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
