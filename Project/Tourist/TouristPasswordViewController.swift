//
//  TouristPasswordViewController.swift
//  Project
//
//  Created by apple on 5/27/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class TouristPasswordViewController: UIViewController {
    
    @IBOutlet weak var currentPassword: UITextField!
    
    @IBOutlet weak var newPassword: UITextField!
    
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var ErrorLabel: UILabel!
    
    //NSConstraints
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func confirmPressed(_ sender: UIButton) {
        
        SVProgressHUD.show(withStatus: "Changing Password...")
        
        let error = ValidateFields()
        if error != nil {
            ErrorLabel.text = error!
            print(error!)
            ErrorLabel.alpha = 1
            SVProgressHUD.dismiss()
        }
        else {
                let user = Auth.auth().currentUser
                if let user = user {
                   let email = user.email
                
                let credential:AuthCredential = EmailAuthProvider.credential(withEmail: email!, password: currentPassword.text!)
                    user.reauthenticate(with: credential) { (result, error) in
                        if error != nil {
                            //Error
                            self.ErrorLabel.text = error!.localizedDescription
                            self.ErrorLabel.alpha = 1
                            print(error!)
                            SVProgressHUD.dismiss()
                        } else {
                            //User is authenticated
                                user.updatePassword(to: self.confirmPassword.text!) { (error) in
                                if error != nil {
                                    //Error
                                    self.ErrorLabel.text = error!.localizedDescription
                                    self.ErrorLabel.alpha = 1
                                    print(error!)
                                    SVProgressHUD.dismiss()
                                }
                                else {
                                    //Password Changed
                                    print("Password Changed")
                                    SVProgressHUD.showSuccess(withStatus: "Password Changed")
                                    SVProgressHUD.dismiss(withDelay: 1)
                                    self.dismiss(animated: true, completion: nil)
                                    
                                }
                            }
                        }
                
                   }
                }
            }
         }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SVProgressHUD
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setContainerView(self.view)
        
        tabBarController?.tabBar.isHidden = true

        // Do any additional setup after loading the view.
        
        //Delegates
        currentPassword.delegate = self
        newPassword.delegate = self
        confirmPassword.delegate = self
    }
    
    func ValidateFields() ->String? {
        if currentPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || newPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || confirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            ErrorLabel.text = "Please fill in all fields"
            ErrorLabel.alpha = 1
            return ErrorLabel.text
        }
        
        
        let newPass = newPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPass = confirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if newPass != confirmPass {
            ErrorLabel.text = "Confirm Passwords doesn't match new Password"
            ErrorLabel.alpha = 1
            return ErrorLabel.text
        }
        
//        let validate = Validation()
//        let error = validate.isValidPassword(confirmPass!)
//        if error {
//            ErrorLabel.text = "Password Should be Minimum 8 characters with at least 1 Alphabet and 1 Number"
//            ErrorLabel.alpha = 1
//            return ErrorLabel.text
//        }
        
        return nil
    }
}

extension TouristPasswordViewController:UITextFieldDelegate {
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
