//
//  OwnerHomeCellClickedViewController.swift
//  Project
//
//  Created by apple on 5/14/20.
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SVProgressHUD
import PromiseKit



class OwnerHomeCellClickedViewController: UIViewController {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var listingName: UILabel!
    @IBOutlet weak var listingDetail: UITextView!
    @IBOutlet weak var listingCurrency: UILabel!
    @IBOutlet weak var listingCharges: UILabel!
    @IBOutlet weak var listingDays: UILabel!
    @IBOutlet weak var guestsLabel: UILabel!
    @IBOutlet weak var roomsLabel: UILabel!
    @IBOutlet weak var bathroomLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var fourthLabel: UILabel!
    @IBOutlet weak var fifthLabel: UILabel!
    @IBOutlet weak var sixthLabel: UILabel!
    @IBOutlet weak var reviewText: UITextView!
    @IBOutlet weak var ratingNumber: UILabel!
    @IBOutlet weak var listingCity: UILabel!
    @IBOutlet weak var countOfReviews: UILabel!
    @IBOutlet var starButtons: [UIButton]!
    @IBOutlet weak var ReviewerName: UILabel!
    @IBOutlet weak var extraFacilityButton: UIButton!
    @IBOutlet weak var avgRatingLabel: UILabel!
    @IBOutlet weak var viewImages: UIButton!
    @IBOutlet weak var reply: UIButton!
    @IBOutlet weak var allReviewsButton: UIButton!
    @IBOutlet var avgRatingStars: [UIButton]!
    
    
    //MARK:- Variables
    
    var valueForListingName:String?
    var valueForListingDetail:String?
    var valueForListingCurrency:String?
    var valueForListingCharges:String?
    var valueForListingDays:String?
    var valueForCityName:String?
    var valueForContact:String?
    var valueForEmail:String?
    var valueForGuests:String?
    var valueForRooms:String?
    var valueForBathrooms:String?
    var path:String?
    var arrayForListing:[String] = []
    var CountOfArray:Int = 0
    var arrayOfLabels:[UILabel] = []
    var remainingFacilitiesArray:[String] = ["","","","","",""]
    var imageURLArray:[String] = []
    var allReviews:[ReviewComponents] = []
    var colletionRef:CollectionReference!
    var docRef:DocumentReference!
    var countLoop = 0
    var ReviewTextVariable:String?
    var RatingNumberVariable:String?
    var reviewImageURL:String?
    let imageCacheForOwner = NSCache<NSString, UIImage>()
    var arrayOfDocID:[String] = []
    var urlObtained:String?
    var avgRatingVariable:Float?
    
    
    //For map display when opened by Tourist or Owner
    var locationLatitude:Double?
    var locationLongitude:Double?
    var locationAddress:String?
    
    //MARK:- IBActions
    
    @IBAction func moreFacilitiesTapped(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toExtraFacilities", sender: sender)
        
    }
    
    @IBAction func editTapped(_ sender: UIBarButtonItem) {
        
        let VC = storyboard?.instantiateViewController(identifier: "add_edit_property") as! OwnerAddListingViewController
        VC.path = path
        VC.BoolVariableForEdit = true
        navigationController?.pushViewController(VC, animated: true)
        //self.present(VC, animated: true, completion: nil)
        
    }
    
    @IBAction func deleteTapped(_ sender: UIBarButtonItem) {
        
        let Alert = UIAlertController(title: "Delete Listing", message: "Are you sure you want to delete this listing?", preferredStyle: .alert)
        
        
        let Delete = UIAlertAction(title: "Delete", style: .default, handler: {(delete) in
            SVProgressHUD.show(withStatus: "Deleting")
            let db = Firestore.firestore()
            db.document(self.path!).delete(){(err) in
                if let err = err {
                    print("Error deleting document \(err.localizedDescription)")
                }
                else {
                    print("Listing removed successfully")
                    SVProgressHUD.showSuccess(withStatus: "Listing Deleted")
                    SVProgressHUD.dismiss(withDelay: TimeInterval(1.5))
                    self.transitionToVC()
                }
                
            }
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            self.dismiss(animated: true, completion: nil)
        })
        
        
        Alert.addAction(Delete)
        Alert.addAction(cancel)
        
        present(Alert, animated: true, completion: nil)
    }
    
    @IBAction func replyButtonTapped(_ sender: UIButton) {
        
        //Making it false so that when in ReplyViewController, the value of Variable.DocIDInReply can be taken instead of DocID
        
        Variables.BoolForDocumentID = false
        let VC = storyboard?.instantiateViewController(identifier: "replyScreen") as! ReplyViewController
        VC.PathRecieved = path
        VC.userID = Auth.auth().currentUser!.uid
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    //Not Connected Actions
    
    //Show Location IBAction
    @IBAction func viewLocation(_ sender: UIButton) {
        
        let destVC = storyboard?.instantiateViewController(identifier: "mapVC") as! testViewController
        destVC.lat = locationLatitude
        destVC.lon = locationLongitude
        destVC.Address = locationAddress
        destVC.city = valueForCityName
        destVC.BoolToShowOnlyReadableMap = true
    
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    
    @IBAction func viewImagesTapped(_ sender: UIButton) {
        
        let VC = storyboard?.instantiateViewController(identifier: "picture") as! TouristPictureViewController
        VC.imageURL = urlObtained
        navigationController?.pushViewController(VC, animated: true)
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setContainerView(collectionView)
        SVProgressHUD.setBackgroundColor(.clear)
        SVProgressHUD.show()
        
        
        arrayOfLabels = [firstLabel,secondLabel,thirdLabel,fourthLabel,fifthLabel,sixthLabel]
        listingName.text = valueForListingName
        listingDetail.text = valueForListingDetail
        listingDays.text = valueForListingDays
        listingCurrency.text = valueForListingCurrency
        listingCharges.text = valueForListingCharges
        guestsLabel.text = valueForGuests
        roomsLabel.text = valueForRooms
        bathroomLabel.text = valueForBathrooms
        listingCity.text = valueForCityName
        
        //Disable Editing and Selection of Textviews and Textfields
        listingDetail.isEditable = false
        listingDetail.isSelectable = false
        reviewText.isEditable = false
        reviewText.isSelectable = false
        
        CountOfArray = arrayForListing.count
        if CountOfArray == 0 {
            
            //No Facility
            extraFacilityButton.backgroundColor = .lightGray
            extraFacilityButton.isEnabled = false
            return
        }
        else if (CountOfArray > 0 && CountOfArray < 7) {
            
            //No Extra Facility, only 6 to show
            extraFacilityButton.backgroundColor = .lightGray
            extraFacilityButton.isEnabled = false
            
            for count in 0...(CountOfArray - 1) {
                
                arrayOfLabels[count].text = arrayForListing[count]
                arrayOfLabels[count].alpha = 1
            }
            
        }
            
        else {
            for count in 0...5 {
                
                arrayOfLabels[count].text = arrayForListing[count]
                arrayOfLabels[count].alpha = 1
                
            }
            
            
            for count in 6...(CountOfArray - 1) {
                
                remainingFacilitiesArray[count - 6] = arrayForListing[count]
            }
        }
        
        getDataForReviews { (imgURL) in
            
            self.urlObtained = imgURL
            
        }
        
        if let avgRating = avgRatingVariable {
            avgRatingLabel.text = String(avgRating)
            let roundedRating = Int(avgRating.rounded())
            for count in 0..<roundedRating {
                avgRatingStars[count].setBackgroundImage(UIImage.init(named:"starFill"), for: .normal)
            }
        }
        
        
    }
    
    
    func getDataForReviews(completion: @escaping (String) -> ()){
        
        if let lastIndex = path!.lastIndex(of: "/"),
            case let index = path!.index(after: lastIndex), index != path!.endIndex
        {
            let result = path![index...]
            let string = path
            if let lastIndex = string?.lastIndex(of: "/")
                
            {
                let substring = string![..<lastIndex]
                colletionRef = Firestore.firestore().collection("\(substring)").document("\(result)").collection("All Reviews")
                
                colletionRef.getDocuments { (querySnapshot, error) in
                    if error != nil {
                        return
                    }
                    else {
                        
                        guard let snap = querySnapshot else {return}
                        if snap.count <= 1 {
                            //Doing that because if count is One, that means there is only Dummy Document in there and So replies button , view Images button and All reviews button should be disabled
                            self.reply.isEnabled = false
                            self.viewImages.isEnabled = false
                            self.allReviewsButton.isEnabled = false
                            self.reply.backgroundColor = .lightGray
                            self.viewImages.backgroundColor = .lightGray
                            self.allReviewsButton.backgroundColor = .lightGray
                            
                            self.countOfReviews.text = "0"
                            
                            
                            
                        } else {
                            
                            self.countOfReviews.text = String(snap.count - 1)
                            if snap.count > 2 {
                                for document in snap.documents {
                                    
                                    if document.documentID == "DummyDocument" {
                                        self.countLoop += 1
                                        print("In Dummy Doc")
                                        
                                        //Also put condition here incase count exceeds 2
                                        
                                    }
                                    else {
                                        self.countLoop += 1
                                        if self.countLoop > 2 {
                                            print("Hello")
                                            let myData = document.data()
                                            self.ReviewTextVariable = myData["Review"] as? String ?? "No review Found"
                                            self.RatingNumberVariable = String((myData["Rating"] as? Int ?? 0))
                                            self.reviewImageURL = myData["ImageURL"] as? String ?? Variables.dummyVariable
                                            let docIDForReply = document.documentID
                                            self.arrayOfDocID.append(docIDForReply)
                                            
                                            let Id = myData["RatingBy"] as? String ?? ""
                                            let data = ReviewComponents(profileImage: UIImage(named:"a")!, profileName: Id, ratingNumber: self.RatingNumberVariable!, review: self.ReviewTextVariable!, ReviewImgUrl: self.reviewImageURL!)
                                            self.allReviews.append(data)
                                            
                                            
                                            
                                        }
                                        else {
                                            
                                            print("In Second one")
                                            Variables.DocumentIDInReply = document.documentID
                                            let docId = document.documentID
                                            self.arrayOfDocID.append(docId)
                                            let myData = document.data()
                                            self.reviewText.text = myData["Review"] as? String ?? "No review Found"
                                            self.ratingNumber.text = String((myData["Rating"] as? Int ?? 0))
                                            
                                            if let countOfRating = Int(self.ratingNumber.text!) {
                                                for Count in 0..<countOfRating {
                                                    self.starButtons[Count].setBackgroundImage(UIImage.init(named: "starFill"), for: .normal)
                                                }
                                            }
                                            
                                            let Id = myData["RatingBy"] as? String ?? ""
                                            self.getName(uid: Id).done { (name) in
                                                self.ReviewerName.text = name
                                            }.catch { (error) in
                                                print("This is error \(error)")
                                            }
                                            
                                            self.reviewImageURL = myData["ImageURL"] as? String ?? Variables.dummyVariable
                                            
                                            let data = ReviewComponents(profileImage: UIImage(named:"a")!, profileName: Id, ratingNumber: self.ratingNumber.text!, review: self.reviewText.text, ReviewImgUrl : self.reviewImageURL!)
                                            self.allReviews.append(data)
                                            completion(self.reviewImageURL ?? Variables.dummyVariable)
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                            }
                            else {
                                for document in snap.documents {
                                    if document.documentID == "DummyDocument" {
                                        
                                    }
                                    else {
                                        Variables.DocumentIDInReply = document.documentID
                                        let docId = document.documentID
                                        self.arrayOfDocID.append(docId)
                                        let myData = document.data()
                                        self.reviewText.text = myData["Review"] as? String ?? "No review Found"
                                        self.ratingNumber.text = String((myData["Rating"] as? Int ?? 0))
                                        if let countOfRating = Int(self.ratingNumber.text!) {
                                            for Count in 0..<countOfRating {
                                                self.starButtons[Count].setBackgroundImage(UIImage.init(named: "starFill"), for: .normal)
                                            }
                                        }
                                        let Id = myData["RatingBy"] as? String ?? ""
                                        self.getName(uid: Id).done { (name) in
                                            self.ReviewerName.text = name
                                        }.catch { (error) in
                                            print("This is error \(error)")
                                        }
                                        
                                        
                                        self.reviewImageURL = myData["ImageURL"] as? String ?? Variables.dummyVariable
                                        
                                        let data = ReviewComponents(profileImage: UIImage(named:"a")!, profileName: Id, ratingNumber: self.ratingNumber.text!, review: self.reviewText.text, ReviewImgUrl : self.reviewImageURL!)
                                        self.allReviews.append(data)
                                        
                                        completion(self.reviewImageURL ?? Variables.dummyVariable)
                                    }
                                }
                            }
                            
                        }
                    }
                    
                }
                
            }
            
        }
    }
    
    func getName(uid:String) ->Promise<String> {
        
        return Promise { Seal in
            
            if let cachedName = NameCache.userNameCache.object(forKey: uid as NSString) {
                Seal.fulfill(cachedName as String)
            }
            else {
            let db = Firestore.firestore().collection("Users").document("\(uid)")
            db.getDocument { (docSnap, error) in
                if let error = error {
                    print("Error is \(error.localizedDescription)") ; Seal.reject(error)
                } else {
                    guard let snap = docSnap, snap.exists, let data = snap.data()
                        else { return }
                    let name = data["Name"] as! String
                    NameCache.userNameCache.setObject(name as NSString, forKey: uid as NSString)
                    Seal.fulfill(name)
                }
             }
          }
       }
    }
    
    func getName(userid:String) -> Promise<String>{
        
        return Promise { seal in
            let db = Firestore.firestore().collection("Users").document(userid)
            db.getDocument { (docSnapshot, error) in
                if error != nil {
                    seal.reject(error!)
                } else {
                    guard let snapshot = docSnapshot, snapshot.exists else {return}
                    guard let data = snapshot.data() else {return}
                    let Name = data["Name"] as! String
                    seal.fulfill(Name)
                }
            }
            
        }
        
    }
    
    
    
    
    
    func transitionToVC(){
        let VC = storyboard?.instantiateViewController(identifier: "OwnerHomeTabBar") as? UITabBarController
        view.window?.rootViewController = VC
        view.window?.makeKeyAndVisible()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toExtraFacilities" {
            if let destinationVC = segue.destination as? ExtraFacilitiesViewController {
                destinationVC.remainingFacilitiesFromPreviousVC = remainingFacilitiesArray
                
                
            }
            
        }
        
        if segue.identifier == "callButton" || segue.identifier == "messageButtonTapped" {
            if let destinationVC = segue.destination as? TouristCallViewController {
                
                destinationVC.Number = valueForContact
            }
        }
        
        if segue.identifier == "emailButton" {
            if let destVC = segue.destination as? TouristCallViewController {
                
                destVC.Number = valueForEmail
            }
        }
        
        if segue.identifier == "allReviews" {
            if let destVC = segue.destination as? TouristAllReviewController {
                destVC.ReviewArray = allReviews
                destVC.path = path
                destVC.docIDArray = arrayOfDocID
                //Making it TRUE so that when in ReplyViewController, the value of Variable.DocIDInReply can't be taken instead of DocID
                Variables.BoolForDocumentID = true
            }
        }
        
    }
    
    func downloadImageFromURL(Url:String, Completion:@escaping((UIImage?))->()) {
        
        if let cachedImage = imageCacheForOwner.object(forKey: Url as NSString) {
            
            Completion(cachedImage)
        }
        else {
            
            let storageRef = Storage.storage().reference(forURL: Url)
            storageRef.downloadURL { (url, error) in
                if error != nil {
                    print("Error Found") ; return
                }
                else {
                    
                    if let urlText = url {
                        let Imagedata = NSData(contentsOf: urlText)
                        let myImage = UIImage(data: Imagedata! as Data)
                        self.imageCacheForOwner.setObject(myImage!, forKey: url!.absoluteString as NSString)
                        Completion(myImage!)
                        
                    }
                }
            }
            
        }
        
    }
    
    
    
}

extension OwnerHomeCellClickedViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ownerCollectionCell", for: indexPath) as! OwnerCollectionViewCell
        
        let url = URL(string: self.imageURLArray[indexPath.row])
        if let cachedImage = ImageCache.ownerListingImageCache.object(forKey: url!.absoluteString as NSString) {
            
            DispatchQueue.main.async {
                cell.ListingImage.image = cachedImage
                SVProgressHUD.dismiss()
            }
            
            
        }
            
        else {
            
            DispatchQueue.global().async {
                
                if let data = try? Data(contentsOf: url!) {
                    DispatchQueue.main.async {
                        cell.ListingImage.image = UIImage(data: data)
                        ImageCache.ownerListingImageCache.setObject(UIImage(data: data)!, forKey: url!.absoluteString as NSString)
                        SVProgressHUD.dismiss()
                    }
                    
                }
                
            }
            
            
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        //Dont Know usage
    }
    
    
}

extension OwnerHomeCellClickedViewController:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}







extension OwnerHomeCellClickedViewController {
    
    
    func Promise_getDataForReviews() -> Promise<String>{
        return Promise { seal in
            if let lastIndex = path!.lastIndex(of: "/"),
                case let index = path!.index(after: lastIndex), index != path!.endIndex
            {
                let result = path![index...]
                let string = path
                if let lastIndex = string?.lastIndex(of: "/")
                    
                {
                    let substring = string![..<lastIndex]
                    colletionRef = Firestore.firestore().collection("\(substring)").document("\(result)").collection("All Reviews")
                    
                    colletionRef.getDocuments { (querySnapshot, error) in
                        if error != nil {
                            return
                        }
                        else {
                            
                            guard let snap = querySnapshot else {return}
                            if snap.count <= 1 {
                                //Doing that because if count is One, that means there is only Dummy Document in there and So replies button , view Images button and All reviews button should be disabled
                                self.reply.isEnabled = false
                                self.viewImages.isEnabled = false
                                self.allReviewsButton.isEnabled = false
                                self.reply.backgroundColor = .lightGray
                                self.viewImages.backgroundColor = .lightGray
                                self.allReviewsButton.backgroundColor = .lightGray
                                self.countOfReviews.text = "0"
                                return
                                
                                
                            } else {
                                
                                self.countOfReviews.text = String(snap.count - 1)
                                if snap.count > 2 {
                                    for document in snap.documents {
                                        
                                        if document.documentID == "DummyDocument" {
                                            self.countLoop += 1
                                            print("In Dummy Doc")
                                            
                                            //Also put condition here incase count exceeds 2
                                            
                                        }
                                        else {
                                            self.countLoop += 1
                                            if self.countLoop > 2 {
                                                
                                                let myData = document.data()
                                                self.ReviewTextVariable = myData["Review"] as? String ?? "No review Found"
                                                self.RatingNumberVariable = String((myData["Rating"] as? Int ?? 0))
                                                self.reviewImageURL = myData["ImageURL"] as? String ?? Variables.dummyVariable
                                                
                                                let data = ReviewComponents(profileImage: UIImage(named:"a")!, profileName: "DummyName", ratingNumber: self.RatingNumberVariable!, review: self.ReviewTextVariable!, ReviewImgUrl: self.reviewImageURL!)
                                                self.allReviews.append(data)
                                                let docIDForReply = document.documentID
                                                self.arrayOfDocID.append(docIDForReply)
                                                
                                                
                                            }
                                            else {
                                                
                                                print("In Second one")
                                                Variables.DocumentIDInReply = document.documentID
                                                let myData = document.data()
                                                self.reviewText.text = myData["Review"] as? String ?? "No review Found"
                                                self.ratingNumber.text = String((myData["Rating"] as? Int ?? 0))
                                                
                                                if let countOfRating = Int(self.ratingNumber.text!) {
                                                    for Count in 0..<countOfRating {
                                                        self.starButtons[Count].setBackgroundImage(UIImage.init(named: "starFill"), for: .normal)
                                                    }
                                                }
                                                
                                                let Id = myData["RatingBy"] as? String ?? ""
                                                  self.getName(uid: Id).done { (name) in
                                                        self.ReviewerName.text = name
                                                 }.catch { (error) in
                                                    print("Error is \(error)")
                                                 }
                                                
                                                self.reviewImageURL = myData["ImageURL"] as? String ?? Variables.dummyVariable
                                                
                                                let data = ReviewComponents(profileImage: UIImage(named:"a")!, profileName: "NameOfReviewer", ratingNumber: self.ratingNumber.text!, review: self.reviewText.text, ReviewImgUrl : self.reviewImageURL!)
                                                self.allReviews.append(data)
                                                seal.fulfill(self.reviewImageURL ?? Variables.dummyVariable)
                                                
                                            }
                                            
                                        }
                                        
                                        
                                    }
                                    
                                }
                                else {
                                    for document in snap.documents {
                                        if document.documentID == "DummyDocument" {
                                            
                                        }
                                        else {
                                            Variables.DocumentIDInReply = document.documentID
                                            let myData = document.data()
                                            self.reviewText.text = myData["Review"] as? String ?? "No review Found"
                                            self.ratingNumber.text = String((myData["Rating"] as? Int ?? 0))
                                            if let countOfRating = Int(self.ratingNumber.text!) {
                                                for Count in 0..<countOfRating {
                                                    self.starButtons[Count].setBackgroundImage(UIImage.init(named: "starFill"), for: .normal)
                                                }
                                            }
                                            let Id = myData["RatingBy"] as? String ?? ""
                                            self.getName(uid: Id).done { (name) in
                                                self.ReviewerName.text = name
                                            }.catch { (error) in
                                                print("Error is \(error)")
                                            }
                                            
                                            
                                            self.reviewImageURL = myData["ImageURL"] as? String ?? Variables.dummyVariable
                                            
                                            let data = ReviewComponents(profileImage: UIImage(named:"a")!, profileName: "NameOfReviewer", ratingNumber: self.ratingNumber.text!, review: self.reviewText.text, ReviewImgUrl : self.reviewImageURL!)
                                            self.allReviews.append(data)
                                            
                                            seal.fulfill(self.reviewImageURL ?? Variables.dummyVariable)
                                        }
                                    }
                                }
                                
                            }
                        }
                        
                    }
                    
                }
                
            }
        }
    }
}
