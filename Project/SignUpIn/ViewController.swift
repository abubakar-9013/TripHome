//
//  ViewController.swift
//  Project
//
//  Created by apple on 4/11/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var TouristButton: UIButton!
    
    @IBOutlet weak var PropertyOwnerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.TouristButton.layer.cornerRadius = 25
        self.PropertyOwnerButton.layer.cornerRadius = 25
    }


}

