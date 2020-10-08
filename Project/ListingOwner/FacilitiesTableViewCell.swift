//
//  FacilitiesTableViewCell.swift
//  Project
//
//  Created by apple on 5/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class FacilitiesTableViewCell: UITableViewCell {
    @IBOutlet weak var facility: UILabel!
    @IBOutlet weak var checkMark: UIButton!
    
    var tapButton: (() -> Void)? = nil
    
    
    @IBAction func SetCheckMark(_ sender: UIButton) {
        if checkMark.isSelected == true {
                   checkMark.setImage(UIImage(named: "Checkbox"), for: .normal)
                   checkMark.isSelected = false


               }
               else {
                   checkMark.setImage(UIImage(named: "UnCheckbox"), for: .normal)
                    checkMark.isSelected = true

               }
        
        tapButton?()
    }
    
    
   
 
}
