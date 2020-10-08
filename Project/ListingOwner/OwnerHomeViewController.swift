//
//  OwnerHomeViewController.swift
//  Project
//
//  Created by apple on 5/12/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import PromiseKit
import Kingfisher


class OwnerHomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var listingDetailArray = [New_CellComponents]()
    var indexSelected = 0
    var collectionRef:CollectionReference!
    var collectionRef_2:CollectionReference!
    var typeOfListing:String = ""
    var charges:Int = 0
    var rating:Float = 0.0
    var nameOfListing:String = ""
    var cityName:String = ""
    var details:String = ""
    var currency:String = ""
    var days:String = ""
    var contact:String = ""
    var contactArray : [String] = []
    var email:String = ""
    var emailArray:[String] = []
    var pathArray:[String] = []
    var guests = ""
    var guestsArray:[String] = []
    var rooms = ""
    var roomsArray:[String] = []
    var bathrooms = ""
    var bathroomsArray:[String] = []
    var latitudeArray:[Double] = []
    var longitudeArray:[Double] = []
    var addressArray:[String] = []
    var ratingArray:[Float] = []
    
    //Array to store Facilities
    var arrayForFacilities:[String] = []
    var mainArrayOfFacilitites = [[String]]()
    
    //Array to store UserID's of users who added listings
    var UserIdOfListingOwners : String = ""
    var countOfUsers:Int = 0
    
    //Array to store ListingImages Url's
    var arrayOfListingImages:[String] = []
    var mainArrayOfListingImages:[[String]] = []
    
    var CountOfListingArray = 0
    let ListingArray = ["Hotel", "House", "Private Room", "Shared Room","Restaurant"]
    var YesFlag = false //It was true when the code was working
    var docExists:Bool?
    let userID = Auth.auth().currentUser?.uid
    var group = DispatchGroup()
    var checkCount = 0
    var myGroup = DispatchGroup()

    
    
    
    //MARK:- IBActions
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        let VC = storyboard?.instantiateViewController(identifier: "addPropertyPage") as! OwnerFirstPageViewController
        
        VC.showSkipButton = false
        navigationController?.pushViewController(VC, animated: true)
        //present(VC, animated: true, completion: nil)
        
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Getting OwnerName and Caching
        GenericFunctions.getNameAndCache()
        
        //svprogressHUD
        SVProgressHUD.setContainerView(self.tableView)
        SVProgressHUD.setBackgroundColor(.clear)
        SVProgressHUD.show()
        
        
        for Count in 0...4 {
            myGroup.enter()
            StaticVariable.countForLoop = Count
            getDataFromCollection{ (data) in
                for eachUserID in data {
                      self.myGroup.enter()
                    if eachUserID == self.userID {
                        self.myGroup.enter()
                        self.YesFlag = true
                        self.collectionRef = Firestore.firestore().collection(self.ListingArray[Count]).document(self.userID!).collection(self.userID! + self.ListingArray[Count] )
                        self.getDatafromDb()
                        
                    }
                    self.myGroup.leave()
                }
            }
        }
        
        myGroup.notify(queue: .main) {
            if self.docExists != true {
                self.showView()
            }
        }
        
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    
    func getDataFromCollection(completion:@escaping ([String])->()) {
        var tempArray:[String] = []
        let db = Firestore.firestore()
        
        db.collection(ListingArray[StaticVariable.countForLoop])
            .getDocuments() { (querySnapshot, err) in
                defer { self.myGroup.leave() }
                if let err = err {
                    print("Error Getting documets: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let DocID = (document.documentID)
                        tempArray.append(DocID)
                    }
                    completion(tempArray)
                }
            }
        }
    
    
    
    
    func getDatafromDb() {
        collectionRef.getDocuments { (docSnapshot, error) in
            defer { self.myGroup.leave() }
            if error != nil {
                print("Error getting Documents")
                return
            }
            else {
                guard let snap = docSnapshot else {return}
                if snap.count > 0 {
                    
                    self.removewView()
                    
                }
                for document in snap.documents {
                    let myData = document.data()
                    self.typeOfListing = myData["Type"] as? String ?? "Not Found"
                    self.charges = Int(myData["Charges"] as? String ?? "Not Found") ?? 0
                    self.nameOfListing = myData["Title"] as? String ?? "Not Found"
                    self.currency = myData["Currency"] as? String ?? "Not Found"
                    self.days = myData["Days"] as? String ?? "Not Found"
                    self.details = myData["Description"] as? String ?? "Not Found"
                    self.cityName = myData["City"] as? String ?? "Ghost"
                    self.contact = myData["Phone"] as? String ?? "Not Found"
                    self.contactArray.append(self.contact)
                    
                    self.email = myData["EmailAddress"] as? String ?? "Not Found"
                    self.emailArray.append(self.email)
                    
                    self.arrayForFacilities = myData["Facilities"] as? [String] ?? [""]
                    self.mainArrayOfFacilitites.append(self.arrayForFacilities)
                    
                    let latitude = myData["Latitude"] as? Double ?? 37.3318
                    self.latitudeArray.append(latitude)
                    
                    let longitude = myData["Longitude"] as? Double ?? -122.0312
                    self.longitudeArray.append(longitude)
                    
                    let address = myData["Address"] as? String ?? "No Address Found"
                    self.addressArray.append(address)
                    
                    self.guests = myData["Guests"] as? String ?? "-"
                    self.guestsArray.append(self.guests)
                    
                    self.rooms = myData["Rooms"] as? String ?? "-"
                    self.roomsArray.append(self.rooms)
                    
                    self.bathrooms = myData["Baths"] as? String ?? "-"
                    self.bathroomsArray.append(self.bathrooms)
                    
                    self.rating = myData["AvgRating"] as? Float ?? 0.0
                    self.ratingArray.append(self.rating)
                    
                    self.arrayOfListingImages = myData["ListingImageURL"] as? [String] ?? [Variables.dummyVariable]
                    
                    if self.arrayOfListingImages == [] {
                        self.arrayOfListingImages = [Variables.dummyVariable]
                    }
                    self.mainArrayOfListingImages.append(self.arrayOfListingImages)
                    
                    
                    let Path = document.reference.path
                    self.pathArray.append(Path)
                    
                    let data2 = New_CellComponents(image: self.arrayOfListingImages[0], typeOfListing: self.typeOfListing , charges: self.charges, rating: self.rating, nameOfListing: self.nameOfListing , cityName: self.cityName, detail: self.details, currency: self.currency, days: self.days)
                    
                    self.listingDetailArray.append(data2)
                    self.tableView.reloadData()
                    
                }
                
                SVProgressHUD.dismiss()
            }
            
        }
        
    }
    

    
    
    
    func showView() {
        let View = UIView(frame: CGRect(x: (self.view.frame.width/2) - 150, y: (self.view.frame.height / 2) - 350, width: 400, height: 400))
        View.tag = 198
        View.center = self.view.center
        View.backgroundColor = .white
        self.view.addSubview(View)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        label.tag = 199
        label.text = "You have no Listings to show"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.italicSystemFont(ofSize: 18)
        
        label.center = View.center
        self.view.addSubview(label)
        
    }
    
    
    
    func removewView() {
        if let viewWithTag = self.view.viewWithTag(198) {
            viewWithTag.removeFromSuperview()
            self.view.layoutIfNeeded()
        }
        if let labelWithTag = self.view.viewWithTag(199) {
            labelWithTag.removeFromSuperview()
            self.view.layoutIfNeeded()
        }
        self.docExists = true
    }
    
}

extension OwnerHomeViewController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return listingDetailArray.count
        return listingDetailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listingData = listingDetailArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "OwnerHomeCell") as! OwnerHomeTableViewCell
        cell.setListingData(array: listingData)
        
        let Url = URL(string: listingData.imageUrl)
        if let Url = Url {
            let resource = ImageResource(downloadURL: Url, cacheKey: Url.absoluteString)
            cell.ListingImage.kf.setImage(with: resource,placeholder: UIImage(named:"placeHolderImage"))
            
        }
        
        
        cell.details.isEditable = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexSelected  = indexPath.row
        performSegue(withIdentifier: "toListingDetail", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toListingDetail" {
            if let destVC = segue.destination as? OwnerHomeCellClickedViewController {
                
                destVC.valueForListingName = listingDetailArray[indexSelected].nameOfListing
                destVC.valueForListingCharges = String(listingDetailArray[indexSelected].charges)
                destVC.valueForListingCurrency = listingDetailArray[indexSelected].currency
                destVC.valueForListingDays = listingDetailArray[indexSelected].days
                destVC.valueForCityName = listingDetailArray[indexSelected].cityName
                destVC.valueForListingDetail = listingDetailArray[indexSelected].detail
                destVC.arrayForListing = mainArrayOfFacilitites[indexSelected]
                destVC.valueForContact = contactArray[indexSelected]
                destVC.valueForEmail = emailArray[indexSelected]
                destVC.path = pathArray[indexSelected]
                destVC.imageURLArray = mainArrayOfListingImages[indexSelected]
                destVC.valueForGuests = guestsArray[indexSelected]
                destVC.valueForRooms = roomsArray[indexSelected]
                destVC.valueForBathrooms = bathroomsArray[indexSelected]
                destVC.locationLatitude = latitudeArray[indexSelected]
                destVC.locationLongitude = longitudeArray[indexSelected]
                destVC.locationAddress = addressArray[indexSelected]
                destVC.avgRatingVariable = ratingArray[indexSelected]
                tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
            }
        }
        
    }
    
}







extension OwnerHomeViewController {
    
    func Promise_getDataFromCollection() ->Promise<[String]> {
        return Promise { seal in
            var tempArray:[String] = []
            let db = Firestore.firestore()
            db.collection(ListingArray[StaticVariable.countForLoop]).getDocuments { (querySnp, error) in
                if error != nil {
                    seal.reject(error!)
                }
                else {
                    
                    for doc in querySnp!.documents {
                        let docid = doc.documentID
                        tempArray.append(docid)
                    }
                    
                    seal.fulfill(tempArray)
                }
            }
            
        }
    }
    
    
    
    
    func Promise_getDatafromDb() ->Promise<Bool> {
        print("Inside with \(StaticVariable.aewin)")
        return Promise{ seal in
            print("Inside data from coll with \(StaticVariable.aewin)")
            
            collectionRef.getDocuments { (docSnapshot, error) in
                if error != nil {
                    print("Error getting Documents")
                    seal.reject(error!)
                    return
                }
                else {
                    guard let snap = docSnapshot else {return}
                    if snap.count > 0 {
                        if let viewWithTag = self.view.viewWithTag(198) {
                            viewWithTag.removeFromSuperview()
                            self.view.layoutIfNeeded()
                        }
                        if let labelWithTag = self.view.viewWithTag(199) {
                            labelWithTag.removeFromSuperview()
                            self.view.layoutIfNeeded()
                        }
                        self.docExists = true
                        
                    }
                    for document in snap.documents {
                        let myData = document.data()
                        self.typeOfListing = myData["Type"] as? String ?? "Not Found"
                        self.charges = Int(myData["Charges"] as? String ?? "Not Found") ?? 0
                        self.nameOfListing = myData["Title"] as? String ?? "Not Found"
                        self.currency = myData["Currency"] as? String ?? "Not Found"
                        self.days = myData["Days"] as? String ?? "Not Found"
                        self.details = myData["Description"] as? String ?? "Not Found"
                        self.cityName = myData["City"] as? String ?? "Ghost"
                        self.contact = myData["Phone"] as? String ?? "Not Found"
                        self.contactArray.append(self.contact)
                        
                        self.email = myData["EmailAddress"] as? String ?? "Not Found"
                        self.emailArray.append(self.email)
                        
                        self.arrayForFacilities = myData["Facilities"] as? [String] ?? [""]
                        self.mainArrayOfFacilitites.append(self.arrayForFacilities)
                        
                        let latitude = myData["Latitude"] as? Double ?? 37.3318
                        self.latitudeArray.append(latitude)
                        
                        let longitude = myData["Longitude"] as? Double ?? -122.0312
                        self.longitudeArray.append(longitude)
                        
                        let address = myData["Address"] as? String ?? "No Address Found"
                        self.addressArray.append(address)
                        
                        self.guests = myData["Guests"] as? String ?? "-"
                        self.guestsArray.append(self.guests)
                        
                        self.rooms = myData["Rooms"] as? String ?? "-"
                        self.roomsArray.append(self.rooms)
                        
                        self.bathrooms = myData["Baths"] as? String ?? "-"
                        self.bathroomsArray.append(self.bathrooms)
                        
                        self.arrayOfListingImages = myData["ListingImageURL"] as? [String] ?? [Variables.dummyVariable]
                        
                        if self.arrayOfListingImages == [] {
                            self.arrayOfListingImages = [Variables.dummyVariable]
                        }
                        self.mainArrayOfListingImages.append(self.arrayOfListingImages)
                        
                        
                        let Path = document.reference.path
                        self.pathArray.append(Path)
                        
                        let data2 = New_CellComponents(image: self.arrayOfListingImages[0], typeOfListing: self.typeOfListing , charges: self.charges, rating: 4.2, nameOfListing: self.nameOfListing , cityName: self.cityName, detail: self.details, currency: self.currency, days: self.days)
                        self.listingDetailArray.append(data2)
                        self.tableView.reloadData()
                        
                    }
                    
                    SVProgressHUD.dismiss()
                    seal.fulfill(self.docExists ?? false)
                    
                }
                
            }
            
        }
    }
    
    
    
    
    //Trying promise Chain
    func chaining() {
        
        for Count in 0...4 {
            StaticVariable.countForLoop = Count
            firstly{
                
                self.Promise_getDataFromCollection()
                
            }.then {
                
                (arrayOfUsersInListing) -> Promise<Bool> in
                return Promise{ seal in
                    self.YesFlag = false
                    for eachUserID in arrayOfUsersInListing {
                        
                        if eachUserID == self.userID {
                            self.YesFlag = true
                        }
                    }
                    
                    if self.YesFlag == true {
                        self.collectionRef = Firestore.firestore().collection(self.ListingArray[Count]).document(self.userID!).collection(self.userID! + self.ListingArray[Count] )
                        StaticVariable.aewin = self.ListingArray[Count]
                        let promise = self.Promise_getDatafromDb()
                        promise.done { (boolean) in
                            seal.fulfill(boolean)
                        }.catch { (error) in
                            print(error)
                        }
                    }
                }
                
            }.done { (complete) in
                self.checkCount += 1
                if self.checkCount == 5 {
                    if complete != true {
                        
                        SVProgressHUD.dismiss()
                        let View = UIView(frame: CGRect(x: (self.view.frame.width/2) - 150, y: (self.view.frame.height / 2) - 350, width: 400, height: 400))
                        View.tag = 198
                        View.center = self.view.center
                        View.backgroundColor = .white
                        self.view.addSubview(View)
                        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
                        label.tag = 199
                        label.text = "You have no Listings to show"
                        label.textAlignment = .center
                        label.textColor = .lightGray
                        label.font = UIFont.italicSystemFont(ofSize: 18)
                        
                        label.center = View.center
                        self.view.addSubview(label)
                    }
                }
                
                
            }.catch { (error) in
                print("Error:  \(error)")
            }
        }
        
    }
    

    
    
}



