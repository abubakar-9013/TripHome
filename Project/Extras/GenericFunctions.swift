//
//  GenericFunctions.swift
//  Project
//
//  Created by apple on 6/29/20.
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Kingfisher

class GenericFunctions {
    
    static var arrayOfTextFields: [UITextField] = []
    
    
    static func createToolBar()->UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let toolbarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(GenericFunctions.doneTapped(withArray:)))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        toolbar.setItems([flexSpace,toolbarButton], animated: true)
        
        return toolbar
    }
    
    @objc static func doneTapped(withArray array: [UITextField]) {
        for count in 0...array.count {
            array[count].endEditing(true)
        }
    }
    
    
    
    static func getNameAndCache() {
        
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            let db = Firestore.firestore().collection("Users").document("\(uid)")
            db.getDocument { (docSnap, error) in
                if let error = error {
                    print("This is error \(error)")
                }
                else {
                    guard let snap = docSnap, snap.exists else { return }
                    guard let data = snap.data() else { return }
                    let name = data["Name"] as! String
                    NameCache.userNameCache.setObject(name as NSString, forKey: uid as NSString)
                }
            }
        }
    }
    
    
    static func assignProfilePicture(button:UIButton) {
        let user = Auth.auth().currentUser
        if let user = user {
            let url = user.photoURL
            let resource = ImageResource(downloadURL: url!)
            KingfisherManager.shared.retrieveImage(with: resource) { (result) in
                
                switch result {
                case .success(let value):
                    
                    let newImage = self.scaleImageToSize(img: value.image, size: CGSize(width: 50, height: 50))
                    button.setImage(newImage, for: .normal)
                    
                    
                case .failure(let value):
                    print("Error is \(value.errorDescription!)")
                    
                }
            }
        }
    }
    
    static func scaleImageToSize(img: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        img.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    
    
    static var citiesNames = [
        "Karachi",
        "Lahore",
        "Faisalabad",
        "Serai",
        "Rawalpindi",
        "Multan",
        "Gujranwala",
        "Hyderabad",
        "Peshawar",
        "Abbottabad",
        "Islamabad",
        "Quetta",
        "Bannu",
        "Bahawalpur",
        "Sargodha",
        "Sialkot",
        "Sukkur",
        "Larkana",
        "Sheikhupura",
        "Mirpur Khas",
        "Rahimyar Khan",
        "Kohat",
        "Gujrat",
        "Bardar",
        "Kasūr",
        "DG Khan",
        "Masiwala",
        "Nawabshah",
        "Okara",
        "Gilgit",
        "Chiniot",
        "Sadiqabad",
        "Turbat",
        "DI Khan",
        "Chaman",
        "Zhob",
        "Mehra",
        "Parachinar",
        "Gwadar",
        "Kundian",
        "Haripur",
        "Matiari",
        "Lodhran",
        "Batgram",
        "Thatta",
        "Bagh",
        "Badin",
        "Mansehra",
        "Ziarat",
        "Muzaffargarh",
        "Karak",
        "Mardan",
        "Hafizabad",
        "Kotli",
        "Loralai",
        "Dera Bugti",
        "Jhang",
        "Sahiwal",
        "Sanghar",
        "Pakpattan",
        "Chakwal",
        "Khushab",
        "Ghotki",
        "Kohlu",
        "Khuzdar",
        "Awaran",
        "Nowshera",
        "Charsadda",
        "Bahawalnagar",
        "Dadu",
        "Aliabad",
        "Lakki Marwat",
        "Chilas",
        "Pishin",
        "Tank",
        "Chitral",
        "Qila Saifullah",
        "Shikarpur",
        "Panjgūr",
        "Mastung",
        "Kalat",
        "Gandava",
        "Khanewal",
        "Narowal",
        "Khairpur",
        "Malakand",
        "Vihari",
        "Saidu Sharif",
        "Jhelum",
        "Mandi Bahauddin",
        "Bhakkar",
        "Toba Tek Singh",
        "Jamshoro",
        "Kharan",
        "Umarkot",
        "Hangu",
        "Timargara",
        "Gakuch",
        "Jacobabad",
        "Alpūrai",
        "Mianwali",
        "Mūsa Khel Bazar",
        "Naushahro Firoz",
        "New Mirpur",
        "Daggar",
        "Eidgah",
        "Sibi",
        "Dalbandin",
        "Rajanpur",
        "Leiah",
        "Upper Dir",
        "Tando Muhammad Khan",
        "Attock",
        "Rawala Kot",
        "Swabi",
        "Kandhkot",
        "Dasu",
        "Athmuqam"
  ]
}
