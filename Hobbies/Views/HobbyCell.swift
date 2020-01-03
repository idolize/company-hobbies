//
//  HobbyCell.swift
//  Hobbies
//
//  Created by David Idol on 7/7/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI

struct HobbyCell : View {
    var hobby: Hobby
    @ObservedObject var cache: BindableImageCache
    var placeholderImg: UIImage = UIImage(named: "spinner-third")!
    
    init(hobby: Hobby) {
        self.hobby = hobby
        cache = BindableImageCache(storagePath: hobby.gcsImagePath)
    }
    
    var hobbyImage: Image {
        return hobby.templateImage != nil ?
            Image(hobby.templateImage!) :
            Image(uiImage: cache.imageData ?? placeholderImg)
    }
    
    var body: some View {
        NavigationLink(destination: HobbyDetail(hobby: hobby)) {
            VStack(alignment: HorizontalAlignment.leading, spacing: 16.0) {
                hobbyImage
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300, height: 170)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                
                VStack(alignment: .leading, spacing: 5.0) {
                    Text(hobby.name)
                        .foregroundColor(.primary)
                        .font(.headline)
                    
                    Text(hobby.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .frame(height: 40)
                }
                
            }
        }
    }
}

#if DEBUG
struct HobbyCell_Previews : PreviewProvider {
    static var previews: some View {
        HobbyCell(hobby: testData[0])
    }
}
#endif
