//
//  HobbyDetailEditor.swift
//  Hobbies
//
//  Created by David Idol on 7/5/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI

struct HobbyDetailEditor : View {
    @Binding var hobby: Hobby
    
    var body: some View {
        List {
            HStack {
                Text("Name").bold()
                Divider()
                TextField("Name", text: $hobby.name)
            }

            HStack {
                Text("Description").bold()
                Divider()
                TextField("Description", text: $hobby.description)
                    .lineLimit(2)
            }
            

//            HStack {
//                Text("Slack").bold()
//                Divider()
//                TextField($hobby.external["slack"], placeholder: Text("#channel"))
//            }
        }
    }
}

//#if DEBUG
//struct HobbyDetailEditor_Previews : PreviewProvider {
//    static var previews: some View {
//        HobbyDetailEditor(hobby: $hobby)
//    }
//}
//#endif
