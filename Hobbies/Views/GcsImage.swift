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




class BindableImageCache : ObservableObject {
    let storagePath: String
    private var isFetching = false
    
    @Published private var rawImageData: UIImage? = nil
    
    var imageData: UIImage? {
        if rawImageData != nil {
            return rawImageData
        }
        if !isFetching {
            ImageCache.downloadImageFromStorage(storagePath: storagePath) { image, error in
                // TODO cache error and show it in UI?
                self.rawImageData = image
                self.isFetching = false
            }
            isFetching = true
        }
        return nil
    }
    
    var isPending: Bool {
        return imageData == nil
    }
    
    init(storagePath: String) {
        self.storagePath = storagePath
    }
}
