//
//  ReplyTableViewCell.swift
//  Project
//
//  Created by apple on 6/14/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class ReplyTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var reply: UITextView!
    
    @IBAction func viewImagesClicked(_ sender: UIButton) {
    }
    
    func setArray(array:ReplyComponents) {
        profileImage.image = array.userImage
        userName.text = array.profileName
        reply.text = array.reply
        reply.isEditable = false
        reply.isUserInteractionEnabled = false
    }
}
