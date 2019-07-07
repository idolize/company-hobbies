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
    
    var createButton: some View {
        NavigationButton(destination: Profile()) {
            // https://stackoverflow.com/questions/56606053/swiftui-navigationbutton-within-navigationbaritems
//            DynamicNavigationDestinationLink()
            Text("Create")
        }
    }
    
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
                .navigationBarItems(trailing: activeTab == 0 ? createButton : nil)
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
