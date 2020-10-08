//
//  TouristUsernameViewController.swift
//  Project
//
//  Created by apple on 5/4/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

protocol sendNameProtocol {
    func sendUsernameBack(username:String)
}

class TouristUsernameViewController: UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var newUsername: UITextField!
    @IBOutlet weak var confirmUsername: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var nameOfUser:String = ""
    var docRef:DocumentReference!
    var UserID = Auth.auth().currentUser?.uid
    var Delegate:sendNameProtocol? = nil
    
    //NSConstraints
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    
    
    
    
    @IBAction func confirmButton(_ sender: UIButton) {
        SVProgressHUD.setContainerView(view)
        SVProgressHUD.setBackgroundColor(.clear)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Changing Username...")
        
        let error = validateFields()
        if error != nil {
            SVProgressHUD.showError(withStatus: "Failed")
            SVProgressHUD.dismiss()
            return
        }
        else {
            docRef = Firestore.firestore().collection("Users").document("\(UserID!)")
            docRef.updateData(["Name" : confirmUsername.text!]) { error in
                
                if error != nil {
                    SVProgressHUD.showError(withStatus: "Failed")
                    SVProgressHUD.dismiss()
                    return
                }
                else {
                    ImageCache.nameCache.setObject(self.confirmUsername.text! as NSString, forKey: "Name")
                    self.Delegate?.sendUsernameBack(username: self.confirmUsername.text!)
                    SVProgressHUD.showSuccess(withStatus: "Username updated Successfully")
                    SVProgressHUD.dismiss()
                    self.dismiss(animated: true, completion: nil)
                    print("Succesfully Updated Document")
                }
            }
        }
        
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        nameLabel.text = nameOfUser
        
        // Do any additional setup after loading the view.
        
        //Set Delegates
        newUsername.delegate = self
        confirmUsername.delegate = self
        
        
    }
    
    func validateFields() -> String? {
        if newUsername.text == "" || confirmUsername.text == "" {
            errorLabel.text = "Fill all fields"
            errorLabel.alpha = 1
            return errorLabel.text
        }
        else if (newUsername.text) != (confirmUsername.text) {
            errorLabel.text = "Fields dont match"
            errorLabel.alpha = 1
            return errorLabel.text
            
        }
        else {
            
            return nil
        }
    }
    
}

extension TouristUsernameViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.viewHeightConstraint.constant = -30
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.viewHeightConstraint.constant = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
