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
    @ObjectBinding var store: HobbiesStore
    @State var activeTab: Int = 0
    
    var body: some View {
        NavigationView {
            if userDataStore.userData != nil && userDataStore.userData!.isEmailVerified {
                TabbedView(selection: $activeTab) {
                    HobbyList(store: store)
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
                .navigationBarTitle(Text(activeTab == 0 ? "Hobbies" : "Profile"))
            } else {
                Onboarding(createdButNotVerified: userDataStore.userData != nil)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView(store: HobbiesStore(hobbies: testData))
    }
}
#endif
