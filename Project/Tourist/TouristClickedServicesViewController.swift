//
//  TouristClickedServicesViewController.swift
//  Project
//
//  Created by apple on 5/1/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import PromiseKit
import Kingfisher

class TouristClickedServicesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mainHeading: UILabel!
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
    var ratingArray:[Float] = []
    
    var arrayOfListingImages:[String] = []
    var mainArrayOfListingImages:[[String]] = []
    
    //Array to store Facilities
    var arrayForFacilities:[String] = []
    var mainArrayOfFacilitites = [[String]]()
       
       
       var listingDetailArray = [New_CellComponents]()
       var collectionRef:CollectionReference!
       var whichListing = StaticVariable.listingSelectedTourist
       let userID = Auth.auth().currentUser!.uid
       var YesFlag = false
       var isPropertyPresent:Bool = false
       var myGroup = DispatchGroup()
    
    //When opened through Search from SearchViewController
    var ArrayToHoldSearchedListing:[New_CellComponents] = []
    var searchVar:Bool = false
    
    //Set ProgressHUD for condition when there is no listing at all
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad")
        //SVProgressHUD.setContainerView(tableView)
        SVProgressHUD.show()
        mainHeading.text = whichListing + "s"
        tableView.separatorStyle = .none
        
       if searchVar {
                
              ChainingForSearch()
       }
       else {
            Chaining()
        }

    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        SVProgressHUD.setContainerView(tableView)
        SVProgressHUD.setBackgroundColor(.clear)
        
        if searchVar {
            self.tabBarController?.tabBar.isHidden = true
        }
        
        
    }
    
}
    

extension TouristClickedServicesViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchVar {
            return ArrayToHoldSearchedListing.count
        }
        else {
            return listingDetailArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell") as! TouristClickedServicesTableViewCell
        cell.ListingImage.kf.indicatorType = .activity
        var stringUrl:String?
        
        if searchVar {
            let searchedData = ArrayToHoldSearchedListing[indexPath.row]
            cell.setListingData(array: searchedData)
             stringUrl = searchedData.imageUrl
            
        }
        else {
            let listingData = listingDetailArray[indexPath.row]
            cell.setListingData(array: listingData)
            stringUrl = listingData.imageUrl
        }
        if let stringUrl = stringUrl {
        let url = URL(string: stringUrl)
        let resource = ImageResource(downloadURL: url!, cacheKey: stringUrl)
        cell.ListingImage.kf.setImage(with: resource, placeholder: UIImage(named: "placeHolderImage"))
        cell.details.isEditable = false
       
      }
         return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexSelected = indexPath.row
        performSegue(withIdentifier: "fromTouristServicesTodetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromTouristServicesTodetail" {
            
            if let destVC = segue.destination as? TouristPropertyClickedViewController {
                
                if searchVar {
                    listingDetailArray = ArrayToHoldSearchedListing
                }
                
                destVC.arrayForListing = mainArrayOfFacilitites[indexSelected]
                destVC.valueForListingName = listingDetailArray[indexSelected].nameOfListing
                destVC.valueForListingCharges = String(listingDetailArray[indexSelected].charges)
                destVC.valueForListingCurrency = listingDetailArray[indexSelected].currency
                destVC.valueForListingDays = listingDetailArray[indexSelected].days
                destVC.valueForListingDetail = listingDetailArray[indexSelected].detail
                destVC.valueForCityName = listingDetailArray[indexSelected].cityName
                destVC.averageRatingVariable = ratingArray[indexSelected]
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
                
                tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
                
            }
        }
    }
}

extension TouristClickedServicesViewController {
    
    func Chaining() {
        firstly {
            Promise_getDataFromCollection()
        }.done { (data) in
            self.Promise_getDataFromDB(stringArray: data)
        }.catch { (error) in
            print("This is error \(error)")
        }
    }
    
    func ChainingForSearch() {
        mainHeading.text = StaticVariable.searchPlace
        firstly {
            Promise_getDataFromCollection()
        }.then { (data) in
            return self.Promise_searchedDataFromDB(stringArray: data)
            
        }.done {(message) in
            print("This is \(message) and value of bool is \(self.isPropertyPresent)")
            
            if self.isPropertyPresent == false {
                self.makeEmptyView()
            }
        }.catch { (error) in
            print("This is error \(error)")
        }
    }
    
    
    func Promise_getDataFromCollection() -> Promise<[String]> {
        
        return Promise { Seal in
        
            var tempArray:[String] = []
            let db = Firestore.firestore()
            db.collection(whichListing).getDocuments { (snapshot, error) in
            if error != nil {
                Seal.reject(error!)
            }
            else {
                //Entered closure
                guard let snap = snapshot else {return}
                for document in snap.documents {
                    let DocID = document.documentID
                    tempArray.append(DocID)
                }
                
                Seal.fulfill(tempArray)
                
            }
          }
        }
    }
    
    
    
    
    func Promise_getDataFromDB(stringArray:[String]) {
        
        for id in stringArray {
            self.collectionRef = Firestore.firestore().collection(self.whichListing).document(id).collection(id + self.whichListing)
            collectionRef.getDocuments { (querySnapshot, error) in
            if error != nil {
                return
            }
            else {
                //closure started
                guard let snapshot = querySnapshot else {return}
                
                for document in snapshot.documents {
                    
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
                    let dataArray = New_CellComponents(image: self.arrayOfListingImages[0], typeOfListing: self.typeOfListing , charges: self.charges, rating: self.rating, nameOfListing: self.nameOfListing , cityName: self.cityName, detail: self.details, currency: self.currency, days: self.days)
                    self.listingDetailArray.append(dataArray)
                    
                    self.tableView.reloadData()
                }
                 
                  SVProgressHUD.dismiss()
            }
          }
        }
      }
    
    
    
    func Promise_searchedDataFromDB(stringArray:[String]) ->Promise<String> {
        
        return Promise{ Seal in
            
        //CityName is obtained from StaticVar.searchPlace and then search Listing of that place
        
        for id in stringArray {
            
            myGroup.enter()
        self.collectionRef = Firestore.firestore().collection(self.whichListing).document(id).collection(id + self.whichListing)
        collectionRef.getDocuments { (querySnapshot, error) in
            
            defer { self.myGroup.leave() }
            if error != nil {
                Seal.reject(error!)
            }
            else {
                //closure started
                guard let snapshot = querySnapshot else {return}

                for document in snapshot.documents {
                    
                    let myData = document.data()
                    if StaticVariable.searchPlace == myData["City"] as? String {
                        
                        self.isPropertyPresent = true
                        print("Bool is \(self.isPropertyPresent)")
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
                        let dataArray = New_CellComponents(image: self.arrayOfListingImages[0], typeOfListing: self.typeOfListing , charges: self.charges, rating: self.rating, nameOfListing: self.nameOfListing , cityName: self.cityName, detail: self.details, currency: self.currency, days: self.days)
                        self.ArrayToHoldSearchedListing.append(dataArray)
                        self.tableView.reloadData()
                        
                        
                    }
                    
                    
                    
                    SVProgressHUD.dismiss()
                  }
                }
              }
            }
            
            myGroup.notify(queue: .main) {
                
                if self.isPropertyPresent == false {
                    self.makeEmptyView()
                }
                Seal.fulfill("Fulfilled")
            
          }
      }
    }
    
    

    func makeEmptyView() {
        let View = UIView(frame: CGRect(x: (self.view.frame.width/2) - 150, y: (self.view.frame.height / 2) - 350, width: 400, height: 400))
        View.center = self.view.center
        View.backgroundColor = .white
        self.view.addSubview(View)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 20))
        label.lineBreakMode = .byWordWrapping
        label.text = "No \(self.whichListing + "s") to show in \(StaticVariable.searchPlace)"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.italicSystemFont(ofSize: 18)
        label.center = View.center
        self.view.addSubview(label)
    }
    
    
    
    
}
