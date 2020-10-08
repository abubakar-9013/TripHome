//
//  CheckViewController.swift
//  Project
//
//  Created by apple on 8/4/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class CheckViewController: UIViewController {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tf: TextFieldMinMaxCharachters!
    override func viewDidLoad() {
        super.viewDidLoad()
        let toolBar = GenericFunctions.createToolBar()
        tf.inputAccessoryView = toolBar

        // Do any additional setup after loading the view.
    }
    


}

extension CheckViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 667 + 260
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 667
        }
    }
}
