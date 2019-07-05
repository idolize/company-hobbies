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
            ZStack(alignment: .bottom) {
                Image(hobby.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: nil, height: 275, alignment: .leading)
                    .clipped()
                
                Rectangle()
                    .foregroundColor(.black)
                    .frame(height: 80)
                    .opacity(0.35)
                    .blur(radius: 10)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text("\(hobby.name) @ Snap, Inc.")
                            .color(.white)
                            .font(.largeTitle)
                    }
                    .padding(.leading)
                    .padding(.bottom)
                    
                    Spacer()
                }
            }
            .listRowInsets(EdgeInsets())
            
            VStack(alignment: HorizontalAlignment.leading) {
                
                
                Text(hobby.description)
                    .font(Font.system(size: 22).italic())
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
                Text(
                    """
                    Members:
                    - userA
                    - userB
                    - userC
                    - userD
                    """
                ).lineLimit(nil).lineSpacing(9.0)
            }
            .padding()
            
            HStack {
                Spacer()
                JoinButton()
                Spacer()
            }
            .padding(.top, 50)
            
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
    }
}

struct JoinButton : View {
    var body: some View {
        Button(action: {}) {
            Text("Join Up!")
        }
        .frame(width: 210, height: 50)
        .foregroundColor(.white)
        .font(.headline)
        .background(Color.blue)
        .cornerRadius(10)
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
