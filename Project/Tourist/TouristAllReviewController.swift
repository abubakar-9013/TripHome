//
//  TouristAllReviewController.swift
//  Project
//
//  Created by apple on 4/29/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import PromiseKit

class TouristAllReviewController: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    var ReviewArray:[ReviewComponents] = []
    var Index:Int?
    
//MARK:- Variables for segue from TouristPropertyClicked to display Replies
    var path:String? //This is the path recieved from Tourist propertyClicked view Controller.
    var userID = Auth.auth().currentUser!.uid
    var docIDArray:[String] = []  //A review is posted with an auto-ID. THis is array of that ID's recieved from Settings view controller and read from Review / userID / All Reviews Collection. Some DocId or pathArray might not be present as this was added afterwards.
    var pathArray:[String] = []  //This path array will contain the paths to the reviews which the loggedIn user posted. This array will populate from SettingsViewController where the path will be extracted from Review Posted by the user.
    var isLoggedinUserReviews:Bool = false  //This bool is needed because Tourist all review can be opened either from settings in which case All reviews posted by Logged in users will be displayed and so `PathRecieved` Variable of ReplyVC should recieve PathArray[IndexPath] which is on above line. And if All reviews is opened from Property clicked, then simply `Path` is sent to Pathrecived Variable.
    
    var isReviewsOnOwnerListings:Bool = false
    
//MARK:- IBActions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.separatorStyle = .none
        tableview.allowsSelection = false
        print("DocIDArray: \(docIDArray)")
        if ReviewArray.count == 0 {
            makeEmptyView()
        }
        else {
            removeEmptyView()
        }
    

        // Do any additional setup after loading the view.
    }
    
    func makeEmptyView() {
        
        let View = UIView(frame: CGRect(x: (self.view.frame.width/2) - 150, y: (self.view.frame.height / 2) - 350, width: 400, height: 400))
        View.tag = 298
        View.center = self.view.center
        View.backgroundColor = .white
        self.view.addSubview(View)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        label.tag = 299
        label.text = "No Reviews posted yet"
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.italicSystemFont(ofSize: 18)
        label.center = View.center
        self.view.addSubview(label)
        
    }
    
    func removeEmptyView() {
        
        if let viewWithTag = self.view.viewWithTag(298) {
            viewWithTag.removeFromSuperview()
        }
        
        if let labelWithTag = self.view.viewWithTag(299) {
            labelWithTag.removeFromSuperview()
        }
        self.view.layoutIfNeeded()
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
    
    func getListingName(path:String) ->Promise<String> {
        
        return Promise{ Seal in
            let db = Firestore.firestore().document(path)
            db.getDocument { (docSnap, error) in
                
                if let error = error {
                    print("This is error \(error)")
                    Seal.reject(error)
                    
                } else {
                    guard let snap = docSnap, snap.exists, let data = snap.data()
                        else { return }
                    let listingName = data["Title"] as! String
                    return Seal.fulfill(listingName)
                    
                }
                
                
                
            }
        }
    }

}


extension TouristAllReviewController:UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reviewData = ReviewArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TouristAllReviewTableCell
        cell.SetReviews(array: reviewData)
        
        if self.isLoggedinUserReviews {
            
            if let cachedName = listingCache.listingNameCache.object(forKey: reviewData.profileName as NSString) {
                cell.profileName.text = cachedName as String
            }
            else {
            getListingName(path: reviewData.profileName).done { (nameOfListing) in
                cell.profileName.text = nameOfListing
                listingCache.listingNameCache.setObject(nameOfListing as NSString, forKey: reviewData.profileName as NSString)
            }.catch { (error) in
                print("This is error \(error)")
            }
        }
    }
            
        else {
                
            if let cachedName = NameCache.userNameCache.object(forKey: reviewData.profileName as NSString){
             
                cell.profileName.text = cachedName as String
            }
            else {
                
                getName(uid: reviewData.profileName).done { (name) in
                cell.profileName.text = name
                    NameCache.userNameCache.setObject(name as NSString, forKey: reviewData.profileName as NSString)
            }.catch { (error) in
                print("This is error \(error)")
            }
        }
    }
        
        if let countOfRating = Int(cell.ratingNumber.text!) {
            
            for Count in 0..<countOfRating {
                cell.starButtons[Count].setBackgroundImage(UIImage.init(named: "starFill"), for: .normal)
                }
            }
        
        cell.btnTapped = {
            let nextVC = self.storyboard?.instantiateViewController(identifier: "picture") as? TouristPictureViewController
            nextVC?.imageForAllReviews = self.ReviewArray[indexPath.row].ReviewImgUrl
            self.navigationController?.pushViewController(nextVC!, animated: true)
        }
        
        cell.replyBtnTapped = {
            
            let VC = self.storyboard?.instantiateViewController(identifier: "replyScreen") as! ReplyViewController
            VC.docID = self.docIDArray[indexPath.row]
            VC.userID = self.userID
            
            if self.isLoggedinUserReviews {
                
                //In that case, the All Reviews that are going to be displayed are of logged in user and so path will be taken pathArray[indexPath.row]
                VC.PathRecieved = self.pathArray[indexPath.row]
                
            } else {
                
                //While in that case, the All Reviews that are going to be displayed are of Single listing and thus path is the one that is coming from all over TouristPropertyClicked
                VC.PathRecieved = self.path
            }
            
            if self.isReviewsOnOwnerListings {
                
                VC.PathRecieved = self.pathArray[indexPath.row]
            }
            
            
            
            self.navigationController?.pushViewController(VC, animated: true)
            
           // self.performSegue(withIdentifier: "replyInAllReviews", sender: self)
        }
        return cell
    }
    
    

    

}
