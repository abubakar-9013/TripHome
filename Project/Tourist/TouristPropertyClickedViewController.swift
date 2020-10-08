//
//  TouristPropertyClickedViewController.swift
//  Project
//
//  Created by apple on 4/27/20.
//  Copyright © 2020 apple. All rights reserved.
//toTouristListingDetail


import UIKit
import Firebase
import SVProgressHUD
import Kingfisher
import PromiseKit

class TouristPropertyClickedViewController: UIViewController {
    
    //MARK:- IBOutlets
    
    //Listing Outlets
    @IBOutlet weak var listingName: UILabel!
    @IBOutlet weak var listingDetail: UITextView!
    @IBOutlet weak var listingCity: UILabel!
    @IBOutlet weak var listingCurrency: UILabel!
    @IBOutlet weak var listingCharges: UILabel!
    @IBOutlet weak var listingDays: UILabel!
    @IBOutlet weak var phoneLabel: UIButton!
    @IBOutlet weak var guestsLabel: UILabel!
    @IBOutlet weak var roomsLabel: UILabel!
    @IBOutlet weak var bathroomLabel: UILabel!
    @IBOutlet weak var averageRating: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //Facilities Outlets
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var fourthLabel: UILabel!
    @IBOutlet weak var fifthLabel: UILabel!
    @IBOutlet weak var sixthLabel: UILabel!
    @IBOutlet weak var extraFacilityButton: UIButton!
    
    //Review Cell Outlets
    @IBOutlet weak var ReviewerName: UILabel!
    @IBOutlet weak var reviewText: UITextView!
    @IBOutlet weak var ratingNumber: UILabel!
    @IBOutlet weak var countOfReviews: UILabel!
    
    //Review Button Outlets
    @IBOutlet weak var viewImages: UIButton!
    @IBOutlet weak var reply: UIButton!
    @IBOutlet weak var allReviewsButton: UIButton!
    @IBOutlet var starButtons: [UIButton]!
    
    
    @IBOutlet var avgRatingStars: [UIButton]!
    
    
    //MARK:- Variables
    
    //Variables to use in receiving Segue Data
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
    var ReviewTextVariable:String?
    var RatingNumberVariable:String?
    var urlOfImageInReview:String?
    var averageRatingVariable:Float?
    var path:String?
    var urlObtained:String?
    var CountOfArray:Int = 0
    var countLoop = 0
    
    
    //Variables for loacation
    var locationLatitude:Double?
    var locationLongitude:Double?
    var locationAddress:String?
    
    //MARK:- Arrays and References
    
    //Arrays
    var arrayForListing:[String] = []
    var arrayOfLabels:[UILabel] = []
    var remainingFacilitiesArray:[String] = ["Empty","Empty","Empty","Empty","Empty","Empty"]
    var imageURLArray:[String] = []
    var downloadedImageArray:[UIImage] = []
    var allReviews:[ReviewComponents] = []
    var arrayOfDocID:[String] = []
    
    //Cache
    let imageCache = NSCache<NSString, UIImage>()
    
    //Firestore Reference
    var colletionRef:CollectionReference!
    
    
    //MARK:- IBActions
    
    
    //Review IBActions
    @IBAction func replyButtonTapped(_ sender: UIButton) {
        
        //Making it false so that when in ReplyViewController, the value of Variable.DocIDInReply can be taken instead of DocID
        Variables.BoolForDocumentID = false
        let VC = storyboard?.instantiateViewController(identifier: "replyScreen") as! ReplyViewController
        VC.PathRecieved = path
        VC.userID = Auth.auth().currentUser!.uid
        self.navigationController?.pushViewController(VC, animated: true)
        
    }
    
    
    //Location IBAction
    @IBAction func viewLocation(_ sender: UIButton) {
        
        let destVC = storyboard?.instantiateViewController(identifier: "mapVC") as! testViewController
        destVC.lat = locationLatitude
        destVC.lon = locationLongitude
        destVC.Address = locationAddress
        destVC.city = valueForCityName
        destVC.BoolToShowOnlyReadableMap = true
        
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    
    //Listing IBActions
    @IBAction func callButtonTapped(_ sender: UIButton) {}
    @IBAction func messageButtonTapped(_ sender: UIButton) {}
    @IBAction func emailButtonTapped(_ sender: UIButton) {}
    
    
    //Facilities IBActions
    @IBAction func moreFacilitiesTapped(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toTouristExtraFacilities", sender: sender)
        
    }
    
    //MARK:- ViewDidLoad
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        
        arrayOfLabels = [firstLabel,secondLabel,thirdLabel,fourthLabel,fifthLabel,sixthLabel]
        listingName.text = valueForListingName
        listingDetail.text = valueForListingDetail
        listingDays.text = valueForListingDays
        listingCity.text = valueForCityName
        listingCurrency.text = valueForListingCurrency
        listingCharges.text = valueForListingCharges
        guestsLabel.text = valueForGuests
        roomsLabel.text = valueForRooms
        bathroomLabel.text = valueForBathrooms
        if let avgRating = averageRatingVariable {
            averageRating.text = String(avgRating)
            let roundedRating = Int(avgRating.rounded())
            for count in 0..<roundedRating {
                avgRatingStars[count].setBackgroundImage(UIImage.init(named:"starFill"), for: .normal)
            }
            
        }
        
        
        
        
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
            if imgURL == "Empty" {
                return
            }
                
            else {
                self.urlObtained = imgURL
            }
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //SVProgressHUD
        SVProgressHUD.setContainerView(collectionView)
        SVProgressHUD.setBackgroundColor(.clear)
    }
    
    
    //MARK:- Firestore Functions to retrieve Data
    
    
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
                        //if Reviews are more than 2, then we have to shift extra reviews to next VC
                        if snap.count <= 1 {
                            //Doing that because if count is One, that means there is only Dummy Document in there and So replies button , view Images button and All reviews button should be disabled
                            self.reply.isEnabled = false
                            self.viewImages.isEnabled = false
                            self.allReviewsButton.isEnabled = false
                            self.reply.backgroundColor = .lightGray
                            self.viewImages.backgroundColor = .lightGray
                            self.allReviewsButton.backgroundColor = .lightGray
                            self.countOfReviews.text = "0"
                            
                            
                            
                        }
                        else {
                            self.countOfReviews.text = String(snap.count - 1)
                            if snap.count > 2 {
                                //Reviews are more than 2
                                for document in snap.documents {
                                    if document.documentID == "DummyDocument" {
                                        self.countLoop += 1
                                        print("In Dummy Doc")
                                        //Also put condition here incase count exceeds 2
                                    }
                                    else {
                                        self.countLoop += 1
                                        if self.countLoop > 2 {
                                            //if self.countLoop > 2, that means we have to now shift reviews on other VC.If not > 2, then go to else below i.e the one review which will be shown in this VC.
                                            
                                            let myData = document.data()
                                            self.ReviewTextVariable = myData["Review"] as? String ?? "No review Found"
                                            self.RatingNumberVariable = String((myData["Rating"] as? Int ?? 0))
                                            self.urlOfImageInReview = myData["ImageURL"] as? String ?? Variables.dummyVariable
                                            let docIDForReply = document.documentID
                                            self.arrayOfDocID.append(docIDForReply)
                                            let Id = myData["RatingBy"] as? String ?? ""
                                            
                                            let data = ReviewComponents(profileImage: UIImage(named:"a")!, profileName: Id, ratingNumber: self.RatingNumberVariable!, review: self.ReviewTextVariable!, ReviewImgUrl : self.urlOfImageInReview!)
                                            self.allReviews.append(data)
                                        }
                                        else {
                                            print("In Second one")
                                            Variables.DocumentIDInReply = document.documentID
                                            let myData = document.data()
                                            self.reviewText.text = myData["Review"] as? String ?? "No review Found"
                                            self.ratingNumber.text = String((myData["Rating"] as? Int ?? 0))
                                            self.urlOfImageInReview = myData["ImageURL"] as? String ?? Variables.dummyVariable
                                            let docIDForReply = document.documentID
                                            self.arrayOfDocID.append(docIDForReply)
                                            
                                            if let countOfRating = Int(self.ratingNumber.text!) {
                                                for Count in 0..<countOfRating {
                                                    self.starButtons[Count].setBackgroundImage(UIImage.init(named: "starFill"), for: .normal)
                                                }
                                            }
                                            
                                            let Id = myData["RatingBy"] as? String ?? ""
                                            self.getName(uid: Id).done { (name) in
                                                self.ReviewerName.text = name
                                                
                                            }.catch{(error) in
                                                print("This is error \(error)")
                                            }
                                            
                                            let data = ReviewComponents(profileImage: UIImage(named:"a")!, profileName: Id, ratingNumber: self.ratingNumber.text!, review: self.reviewText.text, ReviewImgUrl : self.urlOfImageInReview!)
                                            self.allReviews.append(data)
                                            
                                            completion(self.urlOfImageInReview ?? "Empty")
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
                                        self.urlOfImageInReview = myData["ImageURL"] as? String ?? Variables.dummyVariable
                                        let docIDForReply = document.documentID
                                        self.arrayOfDocID.append(docIDForReply)
                                        
                                        if let countOfRating = Int(self.ratingNumber.text!) {
                                            for Count in 0..<countOfRating {
                                                self.starButtons[Count].setBackgroundImage(UIImage.init(named: "starFill"), for: .normal)
                                            }
                                        }
                                        
                                        let Id = myData["RatingBy"] as? String ?? ""
                                        self.getName(uid: Id).done { (name) in
                                            self.ReviewerName.text = name
                                            
                                        }.catch{(error) in
                                            print("This is error \(error)")
                                        }
                                        
                                        let data = ReviewComponents(profileImage: UIImage(named:"a")!, profileName: Id, ratingNumber: self.ratingNumber.text!, review: self.reviewText.text, ReviewImgUrl : self.urlOfImageInReview!)
                                        self.allReviews.append(data)
                                       
                                        completion(self.urlOfImageInReview ?? "Empty")
                                        
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
    
    
    
    //MARK:- Prepare for Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTouristExtraFacilities" {
            if let destinationVC = segue.destination as? TouristExtraFacilitiesViewController {
                destinationVC.remainingFacilitiesFromPreviousVC = remainingFacilitiesArray
            }
            
        }
        
        if segue.identifier == "callButtonTapped" || segue.identifier == "messageButtonTapped" {
            if let destinationVC = segue.destination as? TouristCallViewController {
                
                destinationVC.Number = valueForContact
            }
        }
        
        if segue.identifier == "emailButtonTapped" {
            if let destVC = segue.destination as? TouristCallViewController {
                
                destVC.Number = valueForEmail
            }
        }
        
        if segue.identifier == "toAddReview" {
            let navVC = segue.destination as? UINavigationController
            if let destVC = navVC?.viewControllers.first as? TouristReviewViewController {
                destVC.path = path
                print(path ?? "Not found")
            }
        }
        
        if segue.identifier == "allReviewsClicked" {
            if let destVC = segue.destination as? TouristAllReviewController {
                destVC.ReviewArray = allReviews
                destVC.path = path
                destVC.docIDArray = arrayOfDocID
                //Making it TRUE so that when in ReplyViewController, the value of Variable.DocIDInReply can't be taken instead of DocID
                Variables.BoolForDocumentID = true
                
            }
        }
        
        if segue.identifier == "viewImages" {
            if let destVC = segue.destination as? TouristPictureViewController {
                destVC.imageURL = urlObtained
            }
        }
        
    }
    
}


//MARK:- Extensions

extension TouristPropertyClickedViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDataSourcePrefetching {
    
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        //Dont know the usage of it
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "touristCollectionCell", for: indexPath) as? TouristCollectionViewCell
        let url = URL(string: self.imageURLArray[indexPath.row])
        if let cachedImage = ImageCache.touristListingImageCache.object(forKey: url!.absoluteString as NSString) {
            DispatchQueue.main.async {
                cell?.listingImage.image = cachedImage
            }
            
        }
        else {
            if let url = url {
                cell?.listingImage.kf.indicatorType = .activity
                let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
                cell?.listingImage.kf.setImage(with: resource, placeholder: UIImage(named: "placeHolderImage"))
                
            }
            
        }
        
        return cell!
    }
}




extension TouristPropertyClickedViewController:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    
}
