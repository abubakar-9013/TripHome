//
//  ProfilePictureViewController.swift
//  Project
//
//  Created by apple on 4/14/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class ProfilePictureViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //To round the profile picture Image View
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.black.cgColor
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        profilePicture.clipsToBounds = true

    }
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    
    @IBAction func signup(_ sender: UIButton) {
    }
    
    @IBAction func ChooseImage(_ sender: UIButton) {
        
        let imagePickerController = UIImagePickerController()
               imagePickerController.delegate = self
               
               let action = UIAlertController(title: "Source", message: "Choose Profile Picture", preferredStyle: .actionSheet)
               
               action.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
                   if UIImagePickerController.isSourceTypeAvailable(.camera) {
                   
                       imagePickerController.sourceType = .camera
                       self.present(imagePickerController, animated: true, completion: nil)
                       
                   }
                   else {
                       print("Camera not available")
                   }
                   
               } ))
               
               action.addAction(UIAlertAction(title: "PhotoLibrary", style: .default, handler: { (action: UIAlertAction) in
                   imagePickerController.sourceType = .photoLibrary
                   self.present(imagePickerController, animated: true, completion: nil)
                   
               } ))
               
               action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
               
               self.present(action, animated: true, completion: nil)
               
               
           }
           
           func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
               let image = info[.originalImage] as! UIImage
               profilePicture.image = image
               picker.dismiss(animated: true, completion: nil)
           }
           
           func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
               picker.dismiss(animated: true, completion: nil)
           }


    }
    
   

