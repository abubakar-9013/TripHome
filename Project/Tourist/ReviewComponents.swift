//
//  ReviewComponents.swift
//  Project
//
//  Created by apple on 5/23/20.
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation
import UIKit

class ReviewComponents {
    
    var profileImage : UIImage
    var profileName : String
    var ratingNumber:String
    var review: String
    var ReviewImgUrl:String
    
    init(profileImage: UIImage, profileName: String, ratingNumber:String, review:String, ReviewImgUrl:String) {
        self.profileImage = profileImage
        self.profileName = profileName
        self.ratingNumber = ratingNumber
        self.review = review
        self.ReviewImgUrl = ReviewImgUrl
    }
}



