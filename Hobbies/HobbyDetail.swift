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
        Image(hobby.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
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
