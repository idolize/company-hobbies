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
        List(store.hobbies) { hobby in
            HobbyCell(hobby: hobby)
        }
    }
}


struct HobbyCell : View {
    var hobby: Hobby
    
    var body: some View {
        NavigationLink(destination: HobbyDetail(hobby: hobby)) {
            Image(hobby.imageThumb)
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text(hobby.name)
                Text("20 People")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#if DEBUG
struct HobbyList_Previews : PreviewProvider {
    static var previews: some View {
        HobbyList(store: HobbiesStore(hobbies: testData))
    }
}
#endif
