//
//  TouristReviewViewController.swift
//  Project
//
//  Created by apple on 4/28/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class TouristReviewViewController: UIViewController {
     @IBOutlet weak var textView: UITextView!
     @IBOutlet var starButtons: [UIButton]!
     @IBOutlet weak var selcetedImage: UIImageView!
     @IBOutlet weak var errorLabel: UILabel!
     @IBOutlet weak var postButton: UIButton!
    
     //AddReview height constraint to adjust the view when keyboard is presented
     @IBOutlet weak var addReviewLabelHeight: NSLayoutConstraint!
     @IBOutlet weak var starsTopDistanceConstraint: NSLayoutConstraint!
    
    
     var path:String?
     var rating:Int?
     var hotelID:String = ""
     var picker = UIImagePickerController()
     var imageURL:String?
     var userID = Auth.auth().currentUser?.uid
     var isPictureSelected = false  //Validation to check if picture for review selected

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SVProgressHUD Attributes
        SVProgressHUD.setContainerView(self.view)
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultMaskType(.black)
        
        //TextView Delegate
        textView.delegate = self
        textView.text = "Your Review"
        textView.textColor = UIColor.lightGray
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 2, right: 2)
        
        //Image Picker
        picker.delegate = self
        picker.allowsEditing = true
        
        
        //To add 'Done' toolbar button to keyboard to exit the keyboard when pressed it.
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        
        //To move Done button on right
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        toolBar.setItems([flexibleSpace, doneButton], animated: true)
        textView.inputAccessoryView = toolBar
        
        //Adding Navigation item
        let leftButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButton))
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.title = "TripHome"



    }
    
        @objc func doneClicked(){
            
            textView.endEditing(true)
            
        }

    
        @objc func backButton() {
        
         self.dismiss(animated: true, completion: nil)
            
       }
    

   
    
    @IBAction func starButtonTapped(_ sender: UIButton) {
        rating = sender.tag
        for button in starButtons {
                      if button.tag <= sender.tag {
                          button.setBackgroundImage(UIImage.init(named: "starFill"), for: .normal)   //selectted
                      } else {
                                button.setBackgroundImage(UIImage.init(named: "starEmpty"), for: .normal)    //not selectted
                      }
                  }
           
             }
    
    

    @IBAction func addImages(_ sender: UIButton) {
        
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func reviewPosted(_ sender: UIButton) {
        
        if textView.text == "" || textView.text == "Your Review" {
            errorLabel.alpha = 1
            errorLabel.text = "Review Field can not be empty!"
            return
        }
        
        if rating == nil {
            errorLabel.alpha = 1
            errorLabel.text = "Please give the rating Stars!"
            return
        }
        
        else {
            errorLabel.text = ""
            errorLabel.alpha = 0
        SVProgressHUD.show(withStatus: "Review Posting...")
        
        let db = Firestore.firestore()
        let review = textView.text
        let ratingGiven = rating
        let userID = Auth.auth().currentUser?.uid
        if let lastIndex = path!.lastIndex(of: "/"),
           case let index = path!.index(after: lastIndex), index != path!.endIndex  {
           let result = path![index...]
            StaticVariable.result_AKA_ListingID = String(result)
            
            uploadPictureToStorage { (urlOfImage) in
            //First line is to avoid italic grey doc in db
            db.collection("Reviews").document(userID!).setData(["Data" : "Dummy"])
            
            let string = self.path
            if let lastIndex = string?.lastIndex(of: "/") {
            let substring = string![..<lastIndex]
                
                let generatedDocId = db.collection("\(substring)").document("\(result)").collection("All Reviews").document().documentID
                print("Generated DocID is \(generatedDocId)")
                
                print("Doc Id is \(generatedDocId), Review Path is \(self.path!)")
                
                db.collection("Reviews").document(userID!).collection("All Reviews").document("\(result)").setData(["Review":review!, "Rating" : ratingGiven!, "RatingBy" : userID!, "ImageURL" : urlOfImage, "PathOfReview": self.path!, "DocID": generatedDocId])
                
                
                db.collection("\(substring)").document("\(result)").collection("All Reviews").document(generatedDocId).setData(["Review":review!, "Rating" : ratingGiven!, "RatingBy" : userID!, "ImageURL" : urlOfImage, "PathOfReview": self.path!]){(error) in
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: "Error Posting Review")
                        SVProgressHUD.dismiss(withDelay: 1)
                        print("Error is \(error!.localizedDescription)")
                        
                    } else {
                             //Add rating to Firestore to handle Avg Rating
                        
                        
                        db.collection("\(substring)").document("\(result)").getDocument { (docSnap, error) in
                            if let error = error {
                                print("Error is \(error)")
                                return
                            }
                            else {
                                guard let snap = docSnap, snap.exists
                                    else { return }
                                guard let data = snap.data()
                                    else { return }
                                
                                guard var avgRating = data["AvgRating"] as? Float
                                        else { return }
                                guard var count = data["CountOfRatings"] as? Float
                                    else { return }
                               
                                print("Count is \(count) and Rating is \(avgRating)")
                                count += 1.0
                                avgRating += Float(ratingGiven!)
                                avgRating = avgRating / count
                                print("Now Count is \(count) and Rating is \(avgRating)")
                                db.collection("\(substring)").document("\(result)").updateData([
                                "CountOfRatings" : count,
                                "AvgRating": avgRating
                                ])
                                
                            }
                        }
                        
                        
                        
                            
                        
                        
                        SVProgressHUD.showSuccess(withStatus: "Review Posted")
                        SVProgressHUD.dismiss(withDelay: 0.5)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                            print("This code is Executed")
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}
    
}
    
    
    func uploadPictureToStorage(completion: @escaping (String) ->()){
        
        var imgURL:String = ""
        let storageRef = Storage.storage().reference(withPath: "Reviews/\(userID!)/\(StaticVariable.result_AKA_ListingID)")
        if let data = selcetedImage.image?.jpegData(compressionQuality: 0.75) {
            storageRef.putData(data, metadata: nil) { (metadata, error) in
                if error != nil {
                    return
                }
                else {
                    storageRef.downloadURL { (url, error) in
                        if let urlText = url?.absoluteString {
                            imgURL = urlText
                            completion(imgURL)
                        }
                    }
                }
            }
        } else {
            //In case no Picture is Posted
            completion(Variables.dummyVariable)
        }
    }
    
}



extension TouristReviewViewController:UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        addReviewLabelHeight.constant = 38
        starsTopDistanceConstraint.constant = 30
        self.view.layoutIfNeeded()
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        addReviewLabelHeight.constant = 50
        starsTopDistanceConstraint.constant = 50
        self.view.layoutIfNeeded()
        if textView.text.isEmpty {
            textView.text = "Your Review"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension TouristReviewViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.selcetedImage.image = image
        isPictureSelected = true
        dismiss(animated: true, completion: nil)
    }
}
