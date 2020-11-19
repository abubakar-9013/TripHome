//
//  TouristHomeScreenViewController.swift
//  Project
//
//  Created by apple on 4/22/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import Kingfisher
import PromiseKit

class TouristHomeScreenViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var listingDetailArray:[New_CellComponents] = []
    var filteredListingDetailArray : [New_CellComponents] = []
    var typeOfListing:String = ""
    var charges:Int = 0
    var rating:Float = 0.0
    var ratingArray:[Float] = []
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
    var indexSelected = 0
    var guests = ""
    var guestsArray:[String] = []
    var rooms = ""
    var roomsArray:[String] = []
    var bathrooms = ""
    var bathroomsArray:[String] = []
    var latitudeArray:[Double] = []
    var longitudeArray:[Double] = []
    var addressArray:[String] = []
    
    
    
    //Arrays related to fetching data
    var listingNamesArray:[String] = ["Hotel", "House", "Private Room", "Shared Room","Restaurant"]
    var arrayForFacilities:[String] = []
    var mainArrayOfFacilitites = [[String]]()
    var arrayOfListingImages:[String] = []
    var mainArrayOfListingImages:[[String]] = []
    
    //Database Variable
    var collectionRef : CollectionReference!
    var collectionRef_2:CollectionReference!
    
    
    var myGroup = DispatchGroup()
    var filterApplied = false   // When filter is applied, it will be true and will filter out charges info
    var minVal = 0
    var maxVal = 0
    var listingData:New_CellComponents?
    
    
    
    
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            print("Min \(minVal),maxVal \(maxVal)")
            
            //SVProgressHUD
              SVProgressHUD.show()
            
            //Getting Username and caching
            GenericFunctions.getNameAndCache()
        
            tableView.delegate = self
            tableView.dataSource = self
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            for count in 0...4 {

            StaticVariable.countForLoop = count
            getDatafromCollection { (data) in

                if data == [""] {
                    return
                }
                else {
                    for UserID in data {

                        self.collectionRef = Firestore.firestore().collection(self.listingNamesArray[count]).document(UserID).collection(UserID + self.listingNamesArray[count])
                        self.getDataFromDB()

                    }
                }
            }
        }
        
        //Create BarButton
        let filterButton = UIImageView(image: UIImage(named: "filter"))
        let filterBarButton = UIBarButtonItem(customView: filterButton)
        self.navigationItem.rightBarButtonItem = filterBarButton
        
        let filterGest = UITapGestureRecognizer(target: self, action: #selector(openFilter))
        filterButton.addGestureRecognizer(filterGest)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        //To change back the text to TRIPHOME again after changing to 'Back' in didSelect
        SVProgressHUD.setContainerView(tableView)
        SVProgressHUD.setBackgroundColor(.clear)
        
            self.navigationItem.title = "TripHome"
        
            let uiImage = UIImage(named: "background.jpg")
            let backgroundColor = UIColor(patternImage: uiImage!)
            self.navigationController?.navigationBar.barTintColor = backgroundColor
    }
    
    @objc func openFilter() {
        
        let vc = storyboard?.instantiateViewController(identifier: "filterVC") as! FilterViewController
        self.present(vc, animated: true, completion: nil)
    }
    

    
    
    
    func getDatafromCollection(completion:@escaping([String]) ->()) {
        
        var tempArray:[String] = []
            let db = Firestore.firestore()
        db.collection(listingNamesArray[StaticVariable.countForLoop]).getDocuments { (querySnapshot, error) in

            if error != nil {
                return
            }
            else {
                
                for document in querySnapshot!.documents {
                    
                    let docID = document.documentID
                    tempArray.append(docID)
                }
                    completion(tempArray)
            }
        
        }
        
    }
    
    
    func getDataFromDB() {
        
        collectionRef.getDocuments { (querySnapshot, error) in
            
            if error != nil {
                return
            }
            else {
                guard let snap = querySnapshot else {return}
                for document in snap.documents {
                    
                    let myData = document.data()
                    self.typeOfListing = myData["Type"] as? String ?? "Not Found"
                    self.charges = Int(myData["Charges"] as? String ?? "Not Found") ?? 0
                    self.nameOfListing = myData["Title"] as? String ?? "Not Found"
                    self.currency = myData["Currency"] as? String ?? "Not Found"
                    self.days = myData["Days"] as? String ?? "Not Found"
                    self.details = myData["Description"] as? String ?? "Not Found"
                    self.cityName = myData["City"] as? String ?? "Ghost"
                    
                    self.rating = myData["AvgRating"] as? Float ?? 0.0
                    self.ratingArray.append(self.rating)
                    
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
                    
                    self.arrayForFacilities = myData["Facilities"] as? [String] ?? [""]
                    self.mainArrayOfFacilitites.append(self.arrayForFacilities)
                    
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
                    //If there is listing image array, then get its first element and display
                    
                    let data = New_CellComponents(image: self.arrayOfListingImages[0], typeOfListing: self.typeOfListing, charges: self.charges, rating: self.rating, nameOfListing: self.nameOfListing, cityName: self.cityName, detail: self.details, currency: self.currency, days: self.days)
                    
                    if self.filterApplied {
                        
                        if self.charges >= self.minVal && self.charges <= self.maxVal {
                            self.filteredListingDetailArray.append(data)
                        }
                    }
                    else {
                            
                        self.listingDetailArray.append(data)
                    }
                    
                    self.tableView.reloadData()
                    
                                
                            }
                        }
                            SVProgressHUD.dismiss()
                    }
                }
                
}

    
    
    extension TouristHomeScreenViewController:UITableViewDataSource,UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            if filterApplied {
                return filteredListingDetailArray.count
            }
            else {
                return listingDetailArray.count
            }
            
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            
            if filterApplied {
                listingData = filteredListingDetailArray[indexPath.row]
            }
            else {
                listingData = listingDetailArray[indexPath.row]
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TouristHomeCell") as! TouristHomeScreenTableViewCell
            cell.setListingData(array: listingData!)
            
            cell.ListingImage.kf.indicatorType = .activity
            let stringUrl = listingData!.imageUrl
            let url = URL(string: stringUrl)
            let resource = ImageResource(downloadURL: url!, cacheKey: stringUrl)
            cell.ListingImage.kf.setImage(with: resource, placeholder: UIImage(named: "placeHolderImage"))
            cell.details.isEditable = false
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            indexSelected = indexPath.row
            //To change the TEXT of the back button of the next VC
            self.navigationItem.title = "Back"
            performSegue(withIdentifier: "toTouristListingDetail", sender: self)
            
        }
        
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toTouristListingDetail" {
                if let destVC = segue.destination as? TouristPropertyClickedViewController {
                    
                    if filterApplied {
                        listingDetailArray = filteredListingDetailArray
                    }
                    
                    destVC.arrayForListing = mainArrayOfFacilitites[indexSelected]
                    destVC.valueForListingName = listingDetailArray[indexSelected].nameOfListing
                    destVC.valueForListingCharges = String(listingDetailArray[indexSelected].charges)
                    destVC.valueForListingCurrency = listingDetailArray[indexSelected].currency
                    destVC.valueForListingDays = listingDetailArray[indexSelected].days
                    destVC.valueForListingDetail = listingDetailArray[indexSelected].detail
                    destVC.valueForCityName = listingDetailArray[indexSelected].cityName
                    destVC.valueForContact = contactArray[indexSelected]
                    destVC.valueForEmail = emailArray[indexSelected]
                    destVC.averageRatingVariable = ratingArray[indexSelected]
                    destVC.path = pathArray[indexSelected]
                    destVC.imageURLArray = mainArrayOfListingImages[indexSelected]
                    destVC.valueForGuests = guestsArray[indexSelected]
                    destVC.valueForRooms = roomsArray[indexSelected]
                    destVC.valueForBathrooms = bathroomsArray[indexSelected]
                    destVC.locationLatitude = latitudeArray[indexSelected]
                    destVC.locationLongitude = longitudeArray[indexSelected]
                    destVC.locationAddress = addressArray[indexSelected]
                      tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
                    
                }
            }
        
        }
        
        

    }
    


