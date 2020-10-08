//
//  Signup2ViewController.swift
//  Project
//
//  Created by apple on 4/11/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import SVProgressHUD


class Signup2ViewController: UIViewController {
    
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var NameField: TextFieldMinMaxCharachters!
    @IBOutlet weak var passwordFiled: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var touristBtn: UIButton!
    @IBOutlet weak var ownerBtn: UIButton!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    //Constraints to adjust Keyboard
    @IBOutlet weak var designableFieldTopConstraint: NSLayoutConstraint!
    
    

    
    var typeOfUser:String?
    
    @IBAction func choiceButton(_ sender: UIButton) {
        
        if sender.tag == 1 {
            touristBtn.isSelected = true
            ownerBtn.isSelected = false
            typeOfUser = "Tourist"
            print("Tourist")
        }
        else if sender.tag == 2 {
            touristBtn.isSelected = false
            ownerBtn.isSelected = true
            typeOfUser = "Owner"
            print("Owner")
        }
    }
    
    
    var imagePicker:UIImagePickerController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SVPROgressHUD
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setContainerView(self.view)
        
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(imageTap)
        profilePic.layer.cornerRadius = profilePic.bounds.height / 2
        profilePic.clipsToBounds = true
        
         imagePicker = UIImagePickerController()
         imagePicker.allowsEditing = true
         imagePicker.sourceType = .photoLibrary
         imagePicker.delegate = self
        
        //TextField Delgates
        Email.delegate = self
        NameField.delegate = self
        passwordFiled.delegate = self
        
        //Keyboard done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let toolbarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneTapped))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        toolbar.setItems([flexSpace,toolbarButton], animated: true)
        Email.inputAccessoryView = toolbar
        NameField.inputAccessoryView = toolbar
        passwordFiled.inputAccessoryView = toolbar
        
        //TextField Delegar
        NameField.delegate = self
        NameField.maxLength = 14
        
        
        
        
    
        // Do any additional setup after loading the view.
    }
    
    @objc func doneTapped() {
        
           Email.endEditing(true)
           NameField.endEditing(true)
           passwordFiled.endEditing(true)
    }
    
    
    @objc func openImagePicker(_ sender:Any) {
        // Open Image Picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    func ValidateFields() -> String? {
        
        if NameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || Email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordFiled.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields"
        }
        let validation = Validation()
        
        if !(validation.isValidEmail(email: Email.text!)) {
             ErrorLabel.text = "Incorrect Email Format"
             ErrorLabel.alpha = 1
            return ErrorLabel.text
        }
        if !(validation.isValidPassword(passwordFiled.text!)) {
            ErrorLabel.text = "Password Should be Minimum 8 characters with at least 1 Alphabet and 1 Number"
            ErrorLabel.alpha = 1
            return ErrorLabel.text
        }
        
        if touristBtn.isSelected == false && ownerBtn.isSelected == false {
            ErrorLabel.text = "Please Select from Tourist or Owner"
                     ErrorLabel.alpha = 1
                     return ErrorLabel.text
        }
        
        return nil
    }
    
    
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
         guard let uid = Auth.auth().currentUser?.uid else { return }
           let storageRef = Storage.storage().reference().child("user/\(uid)")

        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }

           let metaData = StorageMetadata()
           metaData.contentType = "image/jpg"

           storageRef.putData(imageData, metadata: metaData) { metaData, error in
               if error == nil, metaData != nil {

                   storageRef.downloadURL { url, error in
                       completion(url)
                       // success!
                   }
                   } else {
                       // failed
                       completion(nil)
                   }
               }
    }
    
    
    
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "Signing up...")
        let error = ValidateFields()
        
        if error != nil {
            //there is an error
            print(error!)
            ErrorLabel.text = error!
            ErrorLabel.alpha = 1
            SVProgressHUD.dismiss()
        }
        else {
        //Fields are okay
            ErrorLabel.alpha = 0
        //Create clean Version of Data
            let Name = NameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = Email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let Password = passwordFiled.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            //let Role = roleField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let picture = profilePic.image else {return}
            
        Auth.auth().createUser(withEmail: email, password: Password) { (results, Err) in
            
            if  Err != nil {
                //Error in creating user  "\(Auth.auth().currentUser!.uid)"   results!.user.uid
                print(Err!)
                SVProgressHUD.showError(withStatus: "Error Creating User")
                SVProgressHUD.dismiss()
            }
            
            else {
                //User is created sucessfully
                    // 1. Upload the profile image to Firebase Storage
                    
                    self.uploadProfileImage(picture) { url in
                        
                        if url != nil {
                            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                            changeRequest?.photoURL = url
                            changeRequest?.displayName = Name
                            
                            changeRequest?.commitChanges { error in
                                if error == nil {
                                    print("User display name changed!")
                                    
                                    let db = Firestore.firestore()  //Refrence to firebase database object
                                    db.collection("Users").document("\(Auth.auth().currentUser!.uid)").setData(["Name" : Name, "Role" : self.typeOfUser!, "photoURL": url!.absoluteString]) { (error) in

                                                   if error != nil {
                                                       print(error!)
                                                       print("Error Reported jani")
                                                   }

                                               }
                                    
                                           }
                
                                       }
                         
                                   }
                             
                               }
         
                           }
                    
                        //At the end of create User
                        SVProgressHUD.showSuccess(withStatus: "Signup Successfull")
                        SVProgressHUD.dismiss()
                        self.transitionToHomeScreen()
                    
                    }
        
              }
 
         }
                
        
    

    
    func transitionToHomeScreen() {
        let homeVC:UITabBarController?
        if typeOfUser == "Tourist" {
        homeVC = storyboard?.instantiateViewController(identifier: "TouristHome") as? TouristHomeTabBarViewController
        
            view.window?.rootViewController = homeVC
                 view.window?.makeKeyAndVisible()
        }
        else {
        let OwnerhomeVC = storyboard?.instantiateViewController(identifier: "OwnerHome") as? UINavigationController
            view.window?.rootViewController = OwnerhomeVC
            view.window?.makeKeyAndVisible()
        
        }
        
     
    }
    
}
extension Signup2ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.originalImage] as? UIImage {
            self.profilePic.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}

extension Signup2ViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.designableFieldTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.designableFieldTopConstraint.constant = 57
            self.view.layoutIfNeeded()
        }
    }
}
