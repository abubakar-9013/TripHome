//
//  TouristCurrencyViewController.swift
//  Project
//
//  Created by apple on 5/4/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class TouristCurrencyViewController: UIViewController {
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func confirmPressed(_ sender: UIButton) {
    }
    
    let Data:[String] = ["USD", "PKR"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        
        //DataSource and Delegate set in StoryBoard
        
    }

}

extension TouristCurrencyViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Data[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //Use Data[row] to get Value of row picked
    }
}
