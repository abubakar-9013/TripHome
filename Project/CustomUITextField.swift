//
//  CustomUITextField.swift
//  Project
//
//  Created by apple on 4/12/20.
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation
import UIKit
 
class MyCustomTextField : UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 20.0
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1.5
        
        //self.backgroundColor = UIColor.
        
    }
    
    
}
