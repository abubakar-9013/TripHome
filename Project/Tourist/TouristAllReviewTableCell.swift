//
//  TouristAllReviewTableCell.swift
//  Project
//
//  Created by apple on 4/29/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class TouristAllReviewTableCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var ratingNumber: UILabel!
    @IBOutlet weak var review: UITextView!
    
    @IBOutlet var starButtons: [UIButton]!
    var btnTapped : (()-> ())?
    var replyBtnTapped: (() ->())?
     
    func SetReviews(array:ReviewComponents) {
        
        profileImage.image = array.profileImage
      //  profileName.text = array.profileName
        ratingNumber.text = array.ratingNumber
        review.text = array.review
        review.isEditable = false
        
    }
    
    @IBAction func viewImagesBtnTapped(_ sender: UIButton) {
        btnTapped?()
        
    }
    
    @IBAction func repliesButtonTapped(_ sender: UIButton) {
        
        replyBtnTapped?()
    }
    
    
    
    
    
    

}


//For Round Corners of Review View, Use the table below in UserDefine Properties
   /*
    
     0 = no corner is being rounded
     1 = top left corner rounded only
     2 = top right corner rounded only
     3 = top left and top right corners rounded only
     4 = bottom left corner rounded only
     5 = top left and bottom left corners rounded only
     6 = top right and bottom left corners rounded only
     7 = top left, top right and bottom left corners rounded only
     8 = bottom right corner rounded only
     9 = top left and bottom right corners rounded only
    10 = top right and bottom right corners rounded only
    11 = top left, top right and bottom right corners rounded only
    12 = bottom left and bottom right corners rounded only
    13 = top left, bottom left and bottom right corners rounded only
    14 = top right, bottom left and bottom right corners rounded only
    15 = all corners rounded
    */
