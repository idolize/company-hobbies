//
//  HobbyList.swift
//  Hobbies
//
//  Created by David Idol on 6/30/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI

struct HobbyList : View {
    @ObjectBinding var store: HobbiesStore
    
    var body: some View {
         ZStack {
            if store.hobbies.isEmpty {
                Text("Loading data...")
            } else {
                List(store.hobbies) { hobby in
                    HobbyCell(hobby: hobby)
                        .padding(.top)
                        .padding(.bottom)
                }
            }
        }
    }
}


struct HobbyCell : View {
    var hobby: Hobby
    
    var body: some View {
        NavigationButton(destination: HobbyDetail(hobby: hobby)) {
            VStack(alignment: .leading, spacing: 16.0) {
                Image(hobby.image)
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 170)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                
                VStack(alignment: .leading, spacing: 5.0) {
                    Text(hobby.name)
                        .color(.primary)
                        .font(.headline)
                    
                    Text(hobby.description)
                        .font(.subheadline)
                        .color(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .frame(height: 40)
                }
                
            }
        }
    }
}

#if DEBUG
struct HobbyList_Previews : PreviewProvider {
    static var previews: some View {
        HobbyList(store: HobbiesStore())
    }
}
#endif
