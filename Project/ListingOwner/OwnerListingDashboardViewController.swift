//
//  OwnerListingDashboardViewController.swift
//  Project
//
//  Created by apple on 5/16/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import Kingfisher

class OwnerListingDashboardViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mainHeadingLabel: UILabel!
    var indexSelected = 0
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
    var bathroomsArray:[String] = []
    var latitudeArray:[Double] = []
    var longitudeArray:[Double] = []
    var addressArray:[String] = []
    var roomsArray:[String] = []
    var guestsArray:[String] = []
    var arrayOfListingImages:[String] = []
    var mainArrayOfListingImages:[[String]] = []
    
    //Array to store Facilities
    var arrayForFacilities:[String] = []
    var mainArrayOfFacilitites = [[String]]()
    
    
    var listingDetailArray = [New_CellComponents]()
    var collectionRef:CollectionReference!
    var whichListing = StaticVariable.whichListingClicked
    let userID = Auth.auth().currentUser!.uid
    var YesFlag = false

    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setContainerView(tableView)
        SVProgressHUD.setBackgroundColor(.clear)
        SVProgressHUD.show()
        
        mainHeadingLabel.text = whichListing + "s"
        
        getDataFromCollection { (data) in
            for idOfUser in data {
                
                if idOfUser == self.userID {
                    self.YesFlag = true
                    self.getDataFromDB()
                }
            }
                
            if self.YesFlag == false {
                
                SVProgressHUD.dismiss()
                self.makeEmptyView()
            }
        }
        
        tableView.separatorStyle = .none
 }
    
    
    
    func makeEmptyView() {
        
        let View = UIView(frame: CGRect(x: (self.view.frame.width/2) - 150, y: (self.view.frame.height / 2) - 350, width: 400, height: 400))
        View.center = self.view.center
        View.backgroundColor = .white
        self.view.addSubview(View)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        label.text = "You have no \(self.whichListing + "s") to show"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.italicSystemFont(ofSize: 18)
        label.center = View.center
        self.view.addSubview(label)
    }
    
    
    
    func getDataFromCollection(completion: @escaping ([String]) ->()) {
        var tempArray:[String] = []
        let db = Firestore.firestore()
        db.collection(whichListing).getDocuments { (snapshot, error) in
            if error != nil {
                return
            }
            else {
                //Entered closure
                guard let snap = snapshot else {return}
                for document in snap.documents {
                    let DocID = document.documentID
                    tempArray.append(DocID)
                
                }
                completion(tempArray)
                
            }
        }
    }

    
    func getDataFromDB() {
        collectionRef = Firestore.firestore().collection(whichListing).document(userID).collection(userID + whichListing)
        collectionRef.getDocuments { (querySnapshot, error) in
            if error != nil {
                return
            }
            else {
                //closure started
                guard let snapshot = querySnapshot else {return}
                if snapshot.count < 1 {
                    print("Inside")
                    //No documents in snapshot
                    SVProgressHUD.dismiss()
                    self.makeEmptyView()
                }
                
                for document in snapshot.documents {
                    
                    let myData = document.data()
                    self.typeOfListing = myData["Type"] as? String ?? "Not Found"
                    self.charges = Int(myData["Charges"] as? String ?? "Not Found") ?? 0
                    self.nameOfListing = myData["Title"] as? String ?? "Not Found"
                    self.currency = myData["Currency"] as? String ?? "Not Found"
                    self.days = myData["Days"] as? String ?? "Not Found"
                    self.details = myData["Description"] as? String ?? "Not Found"
                    self.cityName = myData["City"] as? String ?? "Ghost"
                    let latitude = myData["Latitude"] as? Double ?? 37.3318
                    self.latitudeArray.append(latitude)
                    
                    let longitude = myData["Longitude"] as? Double ?? -122.0312
                    self.longitudeArray.append(longitude)
                    
                    let address = myData["Address"] as? String ?? "No Address Found"
                    self.addressArray.append(address)
                    self.contact = myData["Phone"] as? String ?? "Not Found"
                    self.contactArray.append(self.contact)
                    self.email = myData["EmailAddress"] as? String ?? "Not Found"
                    self.emailArray.append(self.email)
                    let guests = myData["Guests"] as? String ?? "-"
                    self.guestsArray.append(guests)
                        
                    let rooms = myData["Rooms"] as? String ?? "-"
                    self.roomsArray.append(rooms)
                        
                    let bathrooms = myData["Baths"] as? String ?? "-"
                    self.bathroomsArray.append(bathrooms)
                    self.arrayOfListingImages = myData["ListingImageURL"] as? [String] ?? [Variables.dummyVariable]
                                
                    if self.arrayOfListingImages == [] {
                        self.arrayOfListingImages = [Variables.dummyVariable]
                                }
                    
                   self.mainArrayOfListingImages.append(self.arrayOfListingImages)
                    let Path = document.reference.path
                    self.pathArray.append(Path)
                    self.arrayForFacilities = myData["Facilities"] as? [String] ?? [""]
                    self.mainArrayOfFacilitites.append(self.arrayForFacilities)
        
                    let dataArray = New_CellComponents(image: self.arrayOfListingImages[0], typeOfListing: self.typeOfListing , charges: self.charges, rating: 4.1, nameOfListing: self.nameOfListing , cityName: self.cityName, detail: self.details, currency: self.currency, days: self.days)
                    self.listingDetailArray.append(dataArray)
                    
                    self.tableView.reloadData()
                }
                
                SVProgressHUD.dismiss()
            }
        }
    }
}


extension OwnerListingDashboardViewController:UITableViewDataSource,UITableViewDelegate {
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listingDetailArray.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let listingData = listingDetailArray[indexPath.row]
           let cell = tableView.dequeueReusableCell(withIdentifier: "OwnerListingDashboardCell") as! OwnerListingDashboardTableViewCell
           cell.setListingData(array: listingData)
           
        let Url = URL(string: listingData.imageUrl)
        if let Url = Url {
            let resource = ImageResource(downloadURL: Url, cacheKey: Url.absoluteString)
            cell.ListingImage.kf.setImage(with: resource, placeholder: UIImage(named:"placeHolderImage"))
        }
           cell.details.isEditable = false
           return cell
       }
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           indexSelected  = indexPath.row
           performSegue(withIdentifier: "FromDashboardToListingDetail", sender: self)
       }


       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "FromDashboardToListingDetail" {
           if let destVC = segue.destination as? OwnerHomeCellClickedViewController {
               destVC.valueForListingName = listingDetailArray[indexSelected].nameOfListing
               destVC.valueForListingCharges = String(listingDetailArray[indexSelected].charges)
               destVC.valueForListingCurrency = listingDetailArray[indexSelected].currency
               destVC.valueForListingDays = listingDetailArray[indexSelected].days
               destVC.valueForListingDetail = listingDetailArray[indexSelected].detail
               destVC.valueForCityName = listingDetailArray[indexSelected].cityName
               destVC.arrayForListing = mainArrayOfFacilitites[indexSelected]
               destVC.valueForContact = contactArray[indexSelected]
               destVC.valueForEmail = emailArray[indexSelected]
               destVC.path = pathArray[indexSelected]
               destVC.imageURLArray = mainArrayOfListingImages[indexSelected]
               destVC.valueForGuests = guestsArray[indexSelected]
               destVC.valueForRooms = roomsArray[indexSelected]
               destVC.valueForBathrooms = bathroomsArray[indexSelected]
               destVC.locationLatitude = latitudeArray[indexSelected]
               destVC.locationAddress = addressArray[indexSelected]
               destVC.locationLongitude = longitudeArray[indexSelected]
                tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
           }
       }

       }

    
    
   }
   
