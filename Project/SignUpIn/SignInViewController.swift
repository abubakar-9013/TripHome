//
//  SignInViewController.swift
//  Project
//
//  Created by apple on 4/13/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var ErrorLabel:UILabel!

    var docRef: DocumentReference!
    var homeVC:UITabBarController? = nil
    
    //StackView Contraints to Adjust keyboard
    
    @IBOutlet weak var bottom_StackView: UIStackView!
    @IBOutlet weak var loginTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldStackViewTopConstraint: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
        passwordField.isSecureTextEntry = true
        
        //SVProgressHUD
        SVProgressHUD.setContainerView(self.view)
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultMaskType(.black)
        
        //ToolBar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let toolbarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneTapped))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        toolbar.setItems([flexSpace,toolbarButton], animated: true)
        emailField.inputAccessoryView = toolbar
        passwordField.inputAccessoryView = toolbar
        

    }
    
    @IBAction func navigateToSignup(_ sender: UIButton) {
        let controller = storyboard?.instantiateViewController(identifier: "signUpScreen") as! Signup2ViewController
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @objc func doneTapped() {
        emailField.endEditing(true)
        passwordField.endEditing(true)
    }
    
    func ValidateFields() -> String? {
        
        if emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            ErrorLabel.text = "Please fill in all fields"
            ErrorLabel.alpha = 1
            return ErrorLabel.text
        }
        let validation = Validation()
        
        if !(validation.isValidEmail(email: emailField.text!)) {
             ErrorLabel.text = "Incorrect Email Format"
             ErrorLabel.alpha = 1
            return ErrorLabel.text
        }
            
        
        return nil
    }
    
    @IBAction func signinButtonTapped(_ sender: UIButton) {
        
        emailField.endEditing(true)
        passwordField.endEditing(true)
        SVProgressHUD.show(withStatus: "Logging in...")
        loginButton.isUserInteractionEnabled = false
        //loginButton.backgroundColor = .lightGray
        //Validate the fields
        let error = ValidateFields()
        if error != nil {
            SVProgressHUD.dismiss()
            loginButton.isUserInteractionEnabled = true
            ErrorLabel.text = error!
            ErrorLabel.alpha = 1
            return
        }
        
        else {
        
        //Get cleaned Fields Data
        
        let CleanedEmail = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let CleanedPassword = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //Signin the user
        Auth.auth().signIn(withEmail: CleanedEmail , password: CleanedPassword) { (result, error) in
            
            if error != nil {
                //Not logged in
                print("This is the error \(error!.localizedDescription)")
                self.ErrorLabel.text = error!.localizedDescription
                self.ErrorLabel.alpha = 1
                self.loginButton.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
            }
            else {
                self.ErrorLabel.alpha = 0

                if Auth.auth().currentUser != nil {
                    //User is signed in
                    print("User is logged in")
                    self.docRef = Firestore.firestore().document("Users/\(Auth.auth().currentUser!.uid)")
                    self.docRef.getDocument { (docSnapshot, error) in
                        guard let docSnapshot = docSnapshot, docSnapshot.exists else { print("Error Founddddd");return}
                        let myData = docSnapshot.data()
                        let type = myData?["Role"] as? String ?? ""
                        print(type)
                        
                        if type == "Owner" {
                            self.homeVC = self.storyboard?.instantiateViewController(identifier: "OwnerHomeTabBar") as? UITabBarController
                            self.view.window?.rootViewController = self.homeVC
                            self.view.window?.makeKeyAndVisible()
                            
                        }
                        else {
                            self.homeVC = self.storyboard?.instantiateViewController(identifier: "TouristHome") as? UITabBarController
                            self.view.window?.rootViewController = self.homeVC
                            self.view.window?.makeKeyAndVisible()
                        }
                        
                        SVProgressHUD.dismiss()
                     }
                 }
             }
         }
     }
  }
}

extension SignInViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.bottom_StackView.isHidden = true
            self.loginTopConstraint.constant = 45
            self.textFieldStackViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
                  self.bottom_StackView.isHidden = false
                  self.loginTopConstraint.constant = 83
                  self.textFieldStackViewTopConstraint.constant = 45.5
                  self.view.layoutIfNeeded()

              
              }
        
    }
}

