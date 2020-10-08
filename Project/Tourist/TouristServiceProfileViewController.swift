//
//  TouristServiceProfileViewController.swift
//  Project
//
//  Created by apple on 5/3/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import Kingfisher


class TouristServiceProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var password: UIButton!
    var Username:String = ""
    var docRef:DocumentReference!
    var userID = Auth.auth().currentUser?.uid
    let imagePickerController = UIImagePickerController()
    let user = Auth.auth().currentUser
    
    
    
    
    
    @IBAction func userNameTapped(_ sender: UIButton) {}
    @IBAction func passwordTapped(_ sender: UIButton) {}
    
    
    @IBAction func changeProfilePicture(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Profile Picture", message: "What do you want to do?", preferredStyle: .alert)
        
        let viewOption = UIAlertAction(title: "View Profile Picture", style: .default, handler: {action in
            let pictureVC = self.storyboard?.instantiateViewController(identifier: "picture") as! TouristPictureViewController
            if let user = self.user {
                
                pictureVC.profilePictureURL = user.photoURL?.absoluteString
                self.navigationController?.pushViewController(pictureVC, animated: true)
            }
            

        })
        
        let galleryOption = UIAlertAction(title: "Change Profile Picture", style: .default, handler: { action in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)})
        
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
        self.dismiss(animated: true, completion: nil)})
            
        alertController.addAction(viewOption)
        alertController.addAction(galleryOption)
        alertController.addAction(cancelOption)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SVProgressHUD
        SVProgressHUD.setContainerView(self.view)
       // SVProgressHUD.show()
        SVProgressHUD.setBackgroundColor(.clear)
    
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.modalPresentationStyle = .popover
        
        
 
        
        //:-MARK Calling Functions for Databs
            
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        

        getUserNameAndPassword()
        
        let user = Auth.auth().currentUser
        if let user = user {
            let url = user.photoURL
            let resource = ImageResource(downloadURL: url!, cacheKey: url!.absoluteString)
            profilePicture.kf.setImage(with: resource, placeholder: UIImage(named: "profilePlaceholder"))
            
            }
        }
    
    
    
    func getUserNameAndPassword(){
        
        docRef = Firestore.firestore().collection("Users").document("\(userID!)")
        docRef.getDocument { (docSnapshot, error) in
            guard let document = docSnapshot, document.exists else { print(error!) ; return }
            let myData = document.data()
            self.Username = myData!["Name"] as? String ?? "UserName"
        }
    }
    
    

    
    func getProfileImageURL(Completion:@escaping((String)->())) {
        let db = Firestore.firestore().collection("Users").document(userID!)
        db.getDocument { (docSnap, error) in
            guard let snap = docSnap, snap.exists else { return }
            guard let data = snap.data() else { return }
            let url = data["photoURL"] as! String
            Completion(url)
        }
    }
    
    
    func changePicture(image:UIImage){
        
        SVProgressHUD.setContainerView(profilePicture)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Changing Profile Picture...")
        profilePicture.alpha = 0.2
        
        let storageRef = Storage.storage().reference(withPath: "user/\(userID!)")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        if let data = image.jpegData(compressionQuality: 0.75) {
            storageRef.putData(data, metadata: metaData) { (metadata, error) in
                if error != nil {
                    return
                }
                else {
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            print("Failed with error \(error)")
                        }
                        else {
                            if let user = self.user {
                                let changeReq = user.createProfileChangeRequest()
                                changeReq.photoURL = url
                                changeReq.commitChanges { (error) in
                                    if error != nil {
                                        print("Funked with error \(error!.localizedDescription)")
                                                                        
                                    }
                                    else {
                                        self.profilePicture.image = image
                                        self.profilePicture.alpha = 1
                                        SVProgressHUD.showSuccess(withStatus: "Picture changed")
                                        SVProgressHUD.dismiss()
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserName" {
            if let destVC = segue.destination as? TouristUsernameViewController {
                destVC.nameOfUser = Username
                destVC.Delegate = self
            }
        }
    }
}

extension TouristServiceProfileViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        changePicture(image: image)
        dismiss(animated: true, completion: nil)
    }
}

extension TouristServiceProfileViewController:sendNameProtocol {
    func sendUsernameBack(username:String) {
        Username = username
    }
}
