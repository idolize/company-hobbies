//
//  HobbyList.swift
//  Hobbies
//
//  Created by David Idol on 6/30/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI

struct HobbyList : View {
    @EnvironmentObject var userDataStore: UserDataStore
    @ObjectBinding var hobbiesStore: HobbiesStore
    
    var body: some View {
         ZStack {
            if hobbiesStore.hobbies.isEmpty {
                Text("Loading data...")
            } else {
                List {
                    ForEach(hobbiesStore.hobbies) { hobby in
                        HobbyCell(hobby: hobby)
                            .padding(.top)
                            .padding(.bottom)
                    }
                    HStack {
                        Spacer()
                        Button(action: refreshHobbies) {
                            Text("Refresh")
                        }
                        .frame(width: 210, height: 50)
                        .foregroundColor(.white)
                        .font(.headline)
                        .background(Color.gray)
                        .cornerRadius(10)
                        Spacer()
                    }
                    .padding(.top, 80)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    func refreshHobbies() {
        hobbiesStore.loadHobbies(userDataStore: userDataStore)
    }
}


#if DEBUG
struct HobbyList_Previews : PreviewProvider {
    static var previews: some View {
        HobbyList(hobbiesStore: HobbiesStore.default)
            .environmentObject(UserDataStore.default)
    }
}
#endif
