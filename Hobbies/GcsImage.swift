//
//  GcsImage.swift
//  Hobbies
//
//  Created by David Idol on 7/5/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import SwiftUI
import Combine

//struct GcsImage : View {
//    var storagePath: String
//    @ObjectBinding var cache: BindableImageCache = BindableImageCache()
//    var placeholderImg: UIImage = UIImage(named: "spinner-third")!
//
//    var body: some View {
//        Image(uiImage: cache.imageData ?? placeholderImg)
//
//    }
//}




class BindableImageCache : BindableObject {
    let didChange = PassthroughSubject<UIImage?, Never>()
    
    var imageData: UIImage? = nil {
        didSet {
            didChange.send(imageData)
        }
    }
    
    var isPending: Bool {
        return imageData == nil
    }
    
    init(storagePath: String) {
        ImageCache.downloadImageFromStorage(storagePath: storagePath) { image, error in
            // TODO cache error and show it in UI?
            self.imageData = image
        }
    }
}
