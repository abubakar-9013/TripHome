//
//  OwnerSettingsViewController.swift
//  Project
//
//  Created by apple on 5/30/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import PromiseKit
import AwaitKit

class OwnerSettingsViewController: UIViewController {
    
     @IBOutlet weak var Ownerprofile: UIButton!
     @IBOutlet weak var OwnerReviews: UIButton!
     @IBOutlet weak var about: UIButton!
     @IBOutlet weak var logout: UIButton!
    
     var collectionRef:CollectionReference!
     var userID = Auth.auth().currentUser!.uid
     var docRef:DocumentReference!
    
     //Variables for Review
     var ArrayOfReview:[ReviewComponents] = []
     var Review:String = ""
     var Rating:String = ""
     var ListingName:String = ""
     let ListingArray = ["Hotel", "House", "Private Room", "Shared Room","Restaurant"]
     var YesFlag = false
     var reviewImageURL:String?
     var documentIdArrayFromSettingVC:[String] = []
     var pathOfReviewArray:[String] = []
    
    
    
    //MARK:- IBActions
    
    
      @IBAction func profileButtonTapped(_ sender: UIButton) {
            performSegue(withIdentifier: "ownerUsernameAndPassword", sender: sender)
        }
        
    
      @IBAction func reviewTapped(_ sender: UIButton) {
            performSegue(withIdentifier: "toOwnerReview", sender: sender)
        }
    

      @IBAction func aboutTaooed(_ sender: UIButton) {
            
            performSegue(withIdentifier: "toAboutFromOwner", sender: sender)
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

     override func viewDidLoad() {
        super.viewDidLoad()
        
           Ownerprofile.imageView?.contentMode = .scaleToFill
           Ownerprofile.imageView?.layer.cornerRadius = 25
           Ownerprofile.imageView?.layer.masksToBounds = true
           Ownerprofile.imageView?.clipsToBounds = true
           Ownerprofile.imageView?.layer.borderWidth = 0.5
           Ownerprofile.imageEdgeInsets = UIEdgeInsets(top: 0, left: -160, bottom: 0, right: 0)
           
           GenericFunctions.assignProfilePicture(button: Ownerprofile)

    
    //     Do any additional setup after loading the view.
        for Count in 0...4 {
            StaticVariable.loopCount = Count
            getIDOfOwnerFromCollection { (id) in
                for eachUserID in id {
                    if eachUserID == self.userID {
                        self.YesFlag = true
                        self.collectionRef =  Firestore.firestore().collection(self.ListingArray[Count]).document(self.userID).collection(self.userID + self.ListingArray[Count])
                                //StaticVariable.loopCount = Count
                         self.getOwnerListings { (data) in
                            print("These are Listing ID's in \(self.ListingArray[Count]) and ID's are \(data)")
                         for eachListing in data {
                                        //Use staticVariable.idfornameoflisting to pass id
                            self.collectionRef = Firestore.firestore().collection(self.ListingArray[Count]).document(self.userID).collection(self.userID + self.ListingArray[Count]).document(eachListing).collection("All Reviews")
                                  self.getReviews()

                            }
                        }
                    }
                }
            }
        }
        
       
        
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserName()
    }
    
    func getUserName(){
        
        //Caching name at the start of app in App delegate
        if let cachedName = NameCache.userNameCache.object(forKey: userID as NSString) {
            Ownerprofile.setTitle(cachedName as String, for: .normal)
        }
        else {
            Ownerprofile.setTitle("Username", for: .normal)
        }
    }
    
    
    
    
    func getIDOfOwnerFromCollection(completionHandler:@escaping (([String]) ->())){
        
        var tempArr:[String] = []
        let db = Firestore.firestore()
        db.collection(ListingArray[StaticVariable.loopCount]).getDocuments { (querySnapShot, error) in
            if error != nil {
                print("No Documents"); return
            }
            else {
                for document in querySnapShot!.documents {
                    let id = document.documentID
                    tempArr.append(id)
                    
                    
                }
                
                completionHandler(tempArr)
            }
        }
        
    
    }
    
    func getOwnerListings(completionHandler: @escaping ([String]) -> ()) {
        
        var tempArray:[String] = []
        collectionRef.getDocuments { (querySnapshot, error) in
            if error != nil {
                return
            }
            else {
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                   
                    let listingName = document.documentID
                    tempArray.append(listingName)
                   
                }
                
                completionHandler(tempArray)
                
            }
        }
        
    }
    
    
    func getReviews() {
        
        collectionRef.getDocuments { (querySnapshot, error) in
            
            if error != nil {
                print("Error Found");return
                
            }
            else {
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    
                    if document.documentID == "DummyDocument" {
                        
                    } else {
                    
                    let myData = document.data()
                    self.Review = myData["Review"] as? String ?? "No Review"
                    self.Rating = String((myData["Rating"] as? Int ?? 0))
                    self.reviewImageURL = myData["ImageURL"] as? String ?? "No URL"
                    let Id = myData["RatingBy"] as? String ?? ""
                        print("This is Review \(self.Review) with path \(self.collectionRef.path) and docId is \(document.documentID)")
                    
                    //This is ListingID. To get listingName, make refrence to other Collections
                        let docID = document.documentID
                        self.documentIdArrayFromSettingVC.append(docID)
                        
                        //It is newly Added, so might the app be crashed sometime becuase not every review has a pathOfReview. 
                        let pathOfReview = myData["PathOfReview"] as? String ?? "No Path"
                        self.pathOfReviewArray.append(pathOfReview)
                        
                        
                        
                        
                    
                    let data = ReviewComponents(profileImage: UIImage(named: "a")!, profileName: Id, ratingNumber: self.Rating, review: self.Review, ReviewImgUrl: self.reviewImageURL!)
                    self.ArrayOfReview.append(data)
                }
            }
        }
    }
}
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "toOwnerReview" {
               if let destVC = segue.destination as? TouristAllReviewController {
                   destVC.ReviewArray = ArrayOfReview
                   destVC.docIDArray = documentIdArrayFromSettingVC
                   destVC.pathArray = pathOfReviewArray
                   destVC.isReviewsOnOwnerListings = true
                  
                   //Making it true so that when in Reply View Controller, some shit can happen
                   Variables.BoolForDocumentID = true
               }
           }
       }
    

}


//MARK:- Promises

extension OwnerSettingsViewController {
    
    
    
    func chaining() {
        
        firstly {
                Promise_getIDOfOwnerFromCollection()
            
        }.then { (IdsInCollection)-> Promise<[String]> in
            
            return self.Promise_getOwnerListings(IDs: IdsInCollection)
                
            }.then { (ownerListings) ->Promise<Void> in
                return self.Promise_getReviews(ListingIDs: ownerListings)
                
            }.done { (arg0) in
                
                
                let () = arg0
                print("Work Done")
                
            }.catch { (error) in
                print("Error is \(error.localizedDescription)")
        }
  }
    
    
  
    

func Promise_getIDOfOwnerFromCollection() -> Promise<[String]> {
    print("Count in getID-Owner is \(StaticVariable.loopCount) and Listing is \(ListingArray[StaticVariable.loopCount])")
    return Promise{ seal  in
        var tempArr:[String] = []
        let db = Firestore.firestore()
        db.collection(ListingArray[StaticVariable.loopCount]).getDocuments { (querySnapShot, error) in
            if error != nil {
                seal.reject(error!)
                print("No Documents"); return
            }
            else {
                for document in querySnapShot!.documents {
                    let id = document.documentID
                    tempArr.append(id)
                    }
                        seal.fulfill(tempArr)
                }
            }
        }
    }
    
    
    
    func Promise_getOwnerListings(IDs: [String]) -> Promise<[String]> {
        print("Count in getOwner-Listing is \(StaticVariable.loopCount)")
        print("Listing ID is \(IDs)")
        return Promise {seal in
            var tempArray:[String] = []
            self.YesFlag = false
            for ID in IDs {
                print("Count is \(StaticVariable.loopCount)")
                if ID == self.userID {
                    self.YesFlag = true
                    print("Flag is \(self.YesFlag) with Listing \(ListingArray[StaticVariable.loopCount])")
                    self.collectionRef = Firestore.firestore().collection(self.ListingArray[StaticVariable.loopCount]).document(self.userID).collection(self.userID + self.ListingArray[StaticVariable.loopCount])
                    collectionRef.getDocuments { (querySnapshot, error) in
                        if error != nil {
                            seal.reject(error!)
                            return
                        }
                        else {
                            guard let snap = querySnapshot else {return}
                            for document in snap.documents {
                                let listingName = document.documentID
                                tempArray.append(listingName)
                                
                            }
                            
                            seal.fulfill(tempArray)
                            
                        }
                    }
                }
            }
            
            if self.YesFlag == false {
                
            }
        }
    }
    
    
    
    
    func Promise_getReviews(ListingIDs: [String])->Promise<Void> {
        print("Count in review is \(StaticVariable.loopCount)")
        return Promise { seal in
            for eachListing in ListingIDs {
                self.collectionRef = Firestore.firestore().collection(self.ListingArray[StaticVariable.loopCount]).document(self.userID).collection(self.userID + self.ListingArray[StaticVariable.loopCount]).document(eachListing).collection("All Reviews")
                collectionRef.getDocuments { (querySnapshot, error) in
                    if error != nil {
                        print("Error Found")
                        seal.reject(error!)
                        return
                        
                    }
                    else {
                        guard let snap = querySnapshot else {return}
                        for document in snap.documents {
                            if document.documentID == "DummyDocument" {
                                print("Dummy")
                            } else {
                                
                                let myData = document.data()
                                self.Review = myData["Review"] as? String ?? "No Review"
                                self.Rating = String((myData["Rating"] as? Int ?? 0))
                                self.reviewImageURL = myData["ImageURL"] as? String ?? "No URL"
                                print("This is Review \(self.Review)")
                                
                                //This is ListingID. To get listingName, make refrence to other Collections
                                self.ListingName = document.documentID
                                let docID = document.documentID
                                self.documentIdArrayFromSettingVC.append(docID)
                                
                                let data = ReviewComponents(profileImage: UIImage(named: "a")!, profileName: self.ListingName, ratingNumber: self.Rating, review: self.Review, ReviewImgUrl: self.reviewImageURL!)
                                self.ArrayOfReview.append(data)
                            }
                        }
                        
                        seal.fulfill_()
                    }
                }
            }
        }
    }
    


}


