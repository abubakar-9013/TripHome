//
//  ExtraFacilitiesViewController.swift
//  Project
//
//  Created by apple on 5/18/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class ExtraFacilitiesViewController: UIViewController {
    
    @IBOutlet weak var extraLabel1: UILabel!
    @IBOutlet weak var extraLabel2: UILabel!
    @IBOutlet weak var extraLabel3: UILabel!
    @IBOutlet weak var extraLabel4: UILabel!
    @IBOutlet weak var extraLabel5: UILabel!
    @IBOutlet weak var extraLabel6: UILabel!
    
    @IBAction func doneTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    var remainingFacilitiesFromPreviousVC:[String] = []
    var arrayForExtraLabel:[UILabel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
    
     

        arrayForExtraLabel = [extraLabel1,extraLabel2,extraLabel3,extraLabel4,extraLabel5,extraLabel6]
        
        if remainingFacilitiesFromPreviousVC.count == 0 {
            return
        }
        else {
        for count in 0...remainingFacilitiesFromPreviousVC.count - 1 {
            
            arrayForExtraLabel[count].text = remainingFacilitiesFromPreviousVC[count]
        }
    
    }
    
    
    
    }
    


}
