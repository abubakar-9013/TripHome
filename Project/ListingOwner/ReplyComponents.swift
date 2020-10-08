//
//  ReplyComponents.swift
//  Project
//
//  Created by apple on 6/14/20.
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation
import UIKit

class ReplyComponents {
    var profileName:String
    var userImage:UIImage
    var reply:String
    //var imageURL:String
    
    
    init(profileName:String, userImage:UIImage,reply:String) {
        self.profileName = profileName
        self.reply = reply
        self.userImage = userImage
    }
}
