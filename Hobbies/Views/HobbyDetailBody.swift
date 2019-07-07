//
//  HobbyDetailBody.swift
//  Hobbies
//
//  Created by David Idol on 7/7/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI


struct HobbyDetailBody : View {
    var hobby: Hobby
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading) {
            Text(hobby.description)
                .font(Font.system(size: 22).italic())
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .padding(.bottom)
            
            HStack {
                Text("Contact:")
                Text("idol@snapchat.com")
                    .color(.blue)
            }
            Divider()
            HStack {
                Text("Slack:")
                Text(hobby.external["slack"] ?? "none")
                    .color(.blue)
            }
            Divider()
            Text("Members: userA, userB, userC, userD, userE, userF").lineLimit(nil).lineSpacing(9.0)
            
        }
    }
}

#if DEBUG
struct HobbyDetailBody_Previews : PreviewProvider {
    static var previews: some View {
        HobbyDetailBody(hobby: testData[0])
    }
}
#endif
