//
//  TouristSettingViewController.swift
//  Project
//
//  Created by apple on 5/2/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import PromiseKit

class TouristSettingViewController: UIViewController {
    @IBOutlet weak var profile: UIButton!
    @IBOutlet weak var reviews: UIButton!
    @IBOutlet weak var currency: UIButton!
    @IBOutlet weak var about: UIButton!
    @IBOutlet weak var logout: UIButton!
    
    var userID = Auth.auth().currentUser?.uid
    var docRef:DocumentReference!
    var collectionRef:CollectionReference!
    
    //Variables for Review
    var ArrayOfReview:[ReviewComponents] = []
    
    //var mainArray:
    var Review:String = ""
    var Rating:String = ""
    var ListingName:String = ""
    var reviewImageURL:String?
    var documentIDArray:[String] = []
    var pathOfReviewArray:[String] = []
    
    
    //Caching Username
    
    
    @IBAction func profileButtonTapped(_ sender: UIButton) {
        
      performSegue(withIdentifier: "usernameAndPassword", sender: sender)
        
    }
    
    @IBAction func reviewTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toReview", sender: sender)
    }
    
    @IBAction func aboutTaooed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toAbout", sender: sender)
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        if Auth.auth().currentUser != nil {
            
            do {
                try Auth.auth().signOut()
                let LoginVC = storyboard?.instantiateViewController(identifier: "FirstScreen") as! ViewController
                self.view.window!.rootViewController = LoginVC
                self.view.window?.makeKeyAndVisible()
            }
            catch let signOutError as NSError{
                print("Error SigningOut: ",signOutError)
            }
        }
        
    }
    
    
    @IBAction func currencyTapped(_ sender: UIButton) {}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profile.imageView?.contentMode = .scaleAspectFill
        profile.imageView?.layer.cornerRadius = 25
        profile.imageView?.layer.masksToBounds = true
        profile.imageView?.clipsToBounds = true
        profile.imageView?.layer.borderWidth = 0.5
      //  profile.imageView!.leadingAnchor.constraint(equalToSystemSpacingAfter: profile.leadingAnchor, multiplier: -100.0).isActive = true
        
        profile.imageEdgeInsets = UIEdgeInsets(top: 0, left: -160, bottom: 0, right: 0)
        
        
        
        // Do any additional setup after loading the view.
        getReviews()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getUserName()
        GenericFunctions.assignProfilePicture(button: profile)
    }
    


    
    func getUserName(){
        
        //Caching name at the start of app in App delegate
        if let cachedName = NameCache.userNameCache.object(forKey: userID! as NSString) {
            profile.setTitle(cachedName as String, for: .normal)
        }
        else {
            profile.setTitle("Username", for: .normal)
        }
    }
    
    
    func getReviews() {
        
        collectionRef = Firestore.firestore().collection("Reviews").document("\(userID!)").collection("All Reviews")
        collectionRef.getDocuments { (querySnapshot, error) in
            
            if error != nil {
                return
            }
            else {
                
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    
                    let myData = document.data()
                    self.Review = myData["Review"] as? String ?? "No Review"
                    self.Rating = String((myData["Rating"] as? Int ?? 0))
                    self.reviewImageURL = myData["ImageURL"] as? String ?? "No URL"
                  //  self.ListingName = document.documentID //This is ListingID. To get listingName, make refrence to other Collections
                    let pathOfReview = myData["PathOfReview"] as? String ?? "No Path"
                    self.pathOfReviewArray.append(pathOfReview)
                    
                    let docID = myData["DocID"] as? String ?? "No ID"
                    self.documentIDArray.append(docID)
                    
                    let data = ReviewComponents(profileImage: UIImage(named: "a")!, profileName: pathOfReview, ratingNumber: self.Rating, review: self.Review, ReviewImgUrl: self.reviewImageURL!)
                    self.ArrayOfReview.append(data)
                                           
                }
            }
        }
        
    }
    
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "usernameAndPassword" {
            if let destVC = segue.destination as? TouristServiceProfileViewController {
                //Pass on the profile Image to Next screen
            }
        }
        
        if segue.identifier == "toReview" {
            if let destVC = segue.destination as? TouristAllReviewController {
                destVC.ReviewArray = ArrayOfReview
                destVC.docIDArray = documentIDArray
                destVC.pathArray = pathOfReviewArray
                destVC.isLoggedinUserReviews = true
                
                //Added that line so that when in ReplyView controller, `Variable.DocID ` variables should be replaced with the docID array indexPath we are sending from here.
                Variables.BoolForDocumentID = true
            }
        }
    }
    
    
    
}







