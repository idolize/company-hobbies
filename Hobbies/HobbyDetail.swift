//
//  HobbyDetail.swift
//  Hobbies
//
//  Created by David Idol on 6/29/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI

struct HobbyDetail : View {
    var hobby: Hobby
    
    var body: some View {
        VStack {
            Image(hobby.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .listRowInsets(EdgeInsets())
            
            VStack(alignment: HorizontalAlignment.leading) {
                Text("\(hobby.name) @ Snap, Inc.")
                    .font(.title)
                    .padding(.bottom, 10)
                
                Text("Description...")
                
                Divider()
                
                Text("Contact: idol@snapchat.com")
                Divider()
                Text("Slack: #\(hobby.image)")
                Divider()
                Text(
                    """
                    Members:
                    - userA
                    - userB
                    - userC
                    - userD
                    """
                ).lineLimit(nil)
            }
                .padding()
            
            Spacer()
        }
        .navigationBarTitle(Text(hobby.name), displayMode: .inline)
    }
}

#if DEBUG
struct HobbyDetail_Previews : PreviewProvider {
    static var previews: some View {
        NavigationView {
            HobbyDetail(hobby: testData[0])
        }
    }
}
#endif
