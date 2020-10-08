//
//  ImageCache.swift
//  Project
//
//  Created by apple on 6/26/20.
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation
import UIKit
class ImageCache {

    private init() {}
    
    
    static let shared = NSCache<NSString,UIImage>()
    static let reviewImageCache = NSCache<NSString, UIImage>()
    static let touristListingImageCache = NSCache<NSString, UIImage>()
    static let ownerListingImageCache = NSCache<NSString, UIImage>()
    static let ProfilePictureImageCache = NSCache<NSString, UIImage>()
    static let nameCache = NSCache<NSString, NSString>()
}



class NameCache {
    static let userNameCache = NSCache<NSString, NSString>()
}

class listingCache {
    static let listingNameCache = NSCache<NSString, NSString>()
}
