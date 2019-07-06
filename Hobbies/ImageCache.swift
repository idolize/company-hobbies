//
//  ImageCache.swift
//  Hobbies
//
//  Created by David Idol on 7/5/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import UIKit
import Firebase

fileprivate let imageCache = NSCache<NSString, UIImage>()

class ImageCache {
    static func downloadImageFromStorage(storagePath: String, completion: @escaping (_ image: UIImage?, _ error: Error? ) -> Void) {
        if let cachedImage = imageCache.object(forKey: storagePath as NSString) {
            completion(cachedImage, nil)
        } else {
            let ref = Storage.storage().reference(withPath: storagePath)
            ref.getData(maxSize: 5000000) { data, error in
                if let error = error {
                    print(error)
                    completion(nil, error)
                } else if let data = data, let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: storagePath as NSString)
                    completion(image, nil)
                } else {
                    let errorMsg = "Unable to download image from GCS at \(storagePath)"
                    print(errorMsg)
                    completion(nil, RuntimeError(errorMsg))
                }
            }
        }
    }
}
