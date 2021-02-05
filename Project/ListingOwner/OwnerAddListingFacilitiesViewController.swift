//
//  OwnerAddListingFacilitiesViewController.swift
//  Project
//
//  Created by apple on 5/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import ImagePicker
import SVProgressHUD

class OwnerAddListingFacilitiesViewController: UIViewController {
    //tableView
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainHeader_3: UILabel!
    //Facilities
    let Facilities : [String] = ["AC", "Geaser", "Wifi","Telephone", "TV","Kitchen","Cable","Heater"]
    var FacilitiesChoosen : [String] = []
    let UserID = Auth.auth().currentUser!.uid
    
    //User defaults
    let defaults = UserDefaults.standard
    
    //Custom ImagePicker
    @IBOutlet weak var chooseImage: UIButton!
    @IBOutlet weak var uploadMenuLabel: UILabel!
    @IBOutlet weak var uploadMenuButton: UIButton!
    var isRestaurant = false
    var isRestaurantButtonClicked = false
    
    
    var imageViews:[UIImageView] = []
    var menuViews: [UIImageView] = []
    var urlArray:[String] = []
    
    //Variables for editing
    var path:String?
    var boolForEditing_3:Bool = false
    
    var array:[[String:String]] = [["":""]]

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        if boolForEditing_3 {
            mainHeader_3.text = "Edit Facilities"
        }
        
        StaticVariable.Increment.Hotels = CheckNumber(type: Keys.keys.numberOfHotels)
        StaticVariable.Increment.House = CheckNumber(type: Keys.keys.numberOfHouse)
        StaticVariable.Increment.Shared_Rooms = CheckNumber(type: Keys.keys.numberOfSharedRooms)
        StaticVariable.Increment.Private_Rooms = CheckNumber(type: Keys.keys.numberOfPrivateRooms)
        StaticVariable.Increment.Restaurant = CheckNumber(type: Keys.keys.numberOfRestaurant)
        tableView.allowsSelection = false
        
        //To Open Gallery + Camera
        chooseImage.addTarget(self, action: #selector(buttonTouched(button:)), for: .touchUpInside)
        
        //SVProgressHUD Attributes
        SVProgressHUD.setContainerView(self.view)
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultMaskType(.black)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("isRestaurant: \(isRestaurant)")
        uploadMenuButton.alpha = 1
        uploadMenuLabel.alpha = 1
        
        if !isRestaurant {
            uploadMenuButton.alpha = 0
            uploadMenuLabel.alpha = 0
        }
    }
    
    @objc func buttonTouched(button: UIButton) {
      let config = Configuration()
      config.doneButtonTitle = "Done"
      config.noImagesTitle = "Sorry! There are no images here!"
      config.recordLocation = false
      config.allowVideoSelection = false
      let imagePicker = ImagePickerController(configuration: config)
      imagePicker.delegate = self
      present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func uploadMenu(_ sender: UIButton) {
        isRestaurantButtonClicked = true
        let config = Configuration()
        config.doneButtonTitle = "Done"
        config.noImagesTitle = "Sorry! There are no images here!"
        config.recordLocation = false
        config.allowVideoSelection = false
        let imagePicker = ImagePickerController(configuration: config)
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func CheckNumber(type: String) -> Int {
        let Number = self.defaults.integer(forKey: type)
        return Number
    }
    
    func UpdateNumber(type: String) {
        let Number = self.defaults.integer(forKey: type)
               let NewNumber = Number + 1
               self.defaults.set(NewNumber, forKey: type)
    }
    func addListingImagesAndURLtoStorageAndDB(ImageViewArray:[UIImageView], Completion: @escaping(([String]) -> ())){
        let myGroup = DispatchGroup()
        for Count in 0..<ImageViewArray.count {
            myGroup.enter()
            let storageRef = Storage.storage().reference(withPath: "ListinImages/\(StaticVariable.WhichType)\(StaticVariable.WhichNumber)/\(Count)")
            if let data = ImageViewArray[Count].image!.jpegData(compressionQuality: 0.75) {
                storageRef.putData(data, metadata: nil) { (metadata, error) in
                    if error != nil {print("Error is found");return}
                    else {
                        //print("No error here")
                        storageRef.downloadURL { (url, error) in
                            if let urlText = url?.absoluteString {
                                print("Step2")
                                //print("It is \(Count) urlText \(urlText)")
                                self.urlArray.append(urlText)
                                myGroup.leave()
                            }
                        }
                    }
                }
            }
        }
        myGroup.notify(queue: .main){
            if !self.isRestaurant {
                SVProgressHUD.dismiss()
                SVProgressHUD.showSuccess(withStatus: "Listing Added Successfully")
            }
            Completion(self.urlArray)
        }
    }
    
    func addMenu(ImageViewArray:[UIImageView], Completion: @escaping(([String]) -> ())){
        let myGroup = DispatchGroup()
        for Count in 0..<ImageViewArray.count {
            myGroup.enter()
            let storageRef = Storage.storage().reference(withPath: "Menu/\(StaticVariable.WhichType)\(StaticVariable.WhichNumber)/\(Count)")
            if let data = ImageViewArray[Count].image!.jpegData(compressionQuality: 0.75) {
                storageRef.putData(data, metadata: nil) { (metadata, error) in
                    if error != nil {print("Error is found");return}
                    else {
                        //print("No error here")
                        storageRef.downloadURL { (url, error) in
                            if let urlText = url?.absoluteString {
                                print("Step2")
                                //print("It is \(Count) urlText \(urlText)")
                                self.urlArray.append(urlText)
                                myGroup.leave()
                            }
                        }
                    }
                }
            }
        }
        myGroup.notify(queue: .main){
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "Listing Added Successfully")
            Completion(self.urlArray)
        }
    }
    
    func transitionToOwnerHomeScreen() {
        let VC = storyboard?.instantiateViewController(withIdentifier: "OwnerHomeTabBar") as? UITabBarController
        view.window?.rootViewController = VC
        view.window?.makeKeyAndVisible()
    }
    
    @IBAction func addListingTapped(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "Listing is being added")
        addListingImagesAndURLtoStorageAndDB(ImageViewArray: imageViews) { (ObtainedArrayOfURLs) in
            
            if self.isRestaurant {
                self.addMenu(ImageViewArray: self.menuViews) { (obtainedMenuURLs) in
                    
                    let db = Firestore.firestore()
                    if self.boolForEditing_3 {
                        db.document(self.path!).setData(["Facilities": self.FacilitiesChoosen, "ListingImageURL" : ObtainedArrayOfURLs, "Menu": obtainedMenuURLs], merge: true){(error) in
                            
                            if error != nil {
                                
                            }
                            else {
                                self.transitionToOwnerHomeScreen()
                                
                            }
                        }
                    }
                    else {
                        
                        db.collection(StaticVariable.WhichType).document(self.UserID).setData(["DummyField" : "Dummy Data"])
                        db.collection(StaticVariable.WhichType).document(self.UserID).collection(self.UserID + StaticVariable.WhichType).document(StaticVariable.WhichType + "\(StaticVariable.WhichNumber)").setData(["Facilities": self.FacilitiesChoosen, "ListingImageURL" : ObtainedArrayOfURLs, "CountOfRatings": 0.001, "AvgRating": 0.0, "Menu": obtainedMenuURLs], merge: true){(error) in
                            
                            if error != nil {
                                //There is error
                                print("Error: \(error!.localizedDescription)")
                            }
                            else {
                                
                                self.UpdateNumber(type: StaticVariable.WhichType)
                                self.transitionToOwnerHomeScreen()
                            }
                        }
                    }
                }
            }
            else {
                
                let db = Firestore.firestore()
                if self.boolForEditing_3 {
                    db.document(self.path!).setData(["Facilities": self.FacilitiesChoosen, "ListingImageURL" : ObtainedArrayOfURLs], merge: true){(error) in
                        
                        if error != nil {
                            
                        }
                        else {
                            print("Posted")
                            self.transitionToOwnerHomeScreen()
                        }
                    }
                }
                else {
                    
                    db.collection(StaticVariable.WhichType).document(self.UserID).setData(["DummyField" : "Dummy Data"])
                    db.collection(StaticVariable.WhichType).document(self.UserID).collection(self.UserID + StaticVariable.WhichType).document(StaticVariable.WhichType + "\(StaticVariable.WhichNumber)").setData(["Facilities": self.FacilitiesChoosen, "ListingImageURL" : ObtainedArrayOfURLs, "CountOfRatings": 0.001, "AvgRating": 0.0], merge: true){(error) in
                        
                        if error != nil {
                            //There is error
                            print("Error: \(error!.localizedDescription)")
                        }
                        else {
                            
                            self.UpdateNumber(type: StaticVariable.WhichType)
                            self.transitionToOwnerHomeScreen()
                        }
                    }
                }
            }
        }
    }
}

extension OwnerAddListingFacilitiesViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Facilities.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FacilitiesTableViewCell
        cell.facility.text = Facilities[indexPath.row]
        cell.SetCheckMark(cell.checkMark)
        cell.tapButton = {
            if cell.checkMark.isSelected == false {
             
                self.FacilitiesChoosen.append(self.Facilities[indexPath.row])
            }
            else {
                if let facility = self.FacilitiesChoosen[safe: indexPath.row] {
                    self.FacilitiesChoosen = self.FacilitiesChoosen.filter{ $0 != facility }
                }
                else {
                    print("Index Out of range")
                }
                
            }
               }
        
        
        return cell
    }

}

extension OwnerAddListingFacilitiesViewController:ImagePickerDelegate {
    
     func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
        imagePicker.dismiss(animated: true, completion: nil)
      }

      func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {}

      func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        for Count in 0..<images.count {
            let imageView = UIImageView(image: images[Count])
            imageView.frame = CGRect(x: (0 * (110 * Count)), y: 0, width: 50, height: 50)
            if isRestaurantButtonClicked {
                menuViews.append(imageView)
            }
            else {
                imageViews.append(imageView)
            }
            
        }
        
            imagePicker.dismiss(animated: true, completion: nil)
      }
    
}

extension Collection {
    subscript (safe index: Index) -> Element? {
            return indices.contains(index) ? self[index] : nil
        }
}

