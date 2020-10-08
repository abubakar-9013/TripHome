//
//  ReplyViewController.swift
//  Project
//
//  Created by apple on 6/14/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase

class ReplyViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ReplytextField: UITextField!
    @IBOutlet weak var sendButton: DesignableButton!
    var ArrayOfReplies:[ReplyComponents] = []
    var userID:String?
    var PathRecieved:String?
    var docID:String?
    var userName:String?
    var collectionRef:DocumentReference!
    var isEmptyArray:Bool?
    
    
    
    @IBOutlet weak var textFieldBottomContraint: NSLayoutConstraint!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        ReplytextField.delegate = self
        
        
        //When Reply View Controller is opened from tourist property clicked, i.e.  single review Window's reply is clicked then the value of Variables.DocID is Valid and taken that. And if All reviews are clicked then Doc ID's are in an array and so Variable.DocID value is replaced with DocID Array indexPAth
        
        if Variables.BoolForDocumentID {
            
            Variables.DocumentIDInReply = docID!
        }
        
        getName()
        retrieveReply()
   
    }
    

    
    @IBAction func replyPressed(_ sender: DesignableButton) {

        guard let pathrecieved = PathRecieved, pathrecieved != "No Path"
            else { print ("No path recieved"); return }
        if ReplytextField.text == "" || ReplytextField.text == "You Reply" {
            
            return
        
        } else {
        ReplytextField.endEditing(true)
        ReplytextField.isEnabled = false
        sendButton.isEnabled = false
            
      
        let db = Firestore.firestore().document("\(pathrecieved)/All Reviews/\(Variables.DocumentIDInReply)")
        let replyDictionary = ["UserName": userName, "Reply":ReplytextField.text!]
        db.updateData([
        
            "Replies":FieldValue.arrayUnion([
                replyDictionary
        ])
        
        ]){(error) in
            if error != nil {
                print("Error ", error!.localizedDescription)
            } else {
                    print("Reply Posted")
                    self.retrieveSingleReply()
                
            }
            
            self.ReplytextField.text = ""
            self.sendButton.isEnabled = true
            self.ReplytextField.isEnabled = true
        }
     
    }
}
    
    func getName(){
        
        let db = Firestore.firestore().document("Users/\(userID!)")
        db.getDocument { (docSnapshot, error) in
            if error != nil {
                print("Error is ",error!.localizedDescription)
            } else {
                    
                guard let Snapshot = docSnapshot else {return}
                guard let Data = Snapshot.data() else {return}
                self.userName = Data["Name"] as? String ?? "User"
            }
        }
    }
    
    
    func retrieveReply(){
        
        guard let pathrecieved = PathRecieved, pathrecieved != "No Path"
            else { print("No Path recieved in retireving all Rep"); return }
        let db = Firestore.firestore().document("\(pathrecieved)/All Reviews/\(Variables.DocumentIDInReply)")
        db.getDocument(completion: { (docSnapShot, error) in
            guard let Snapshot = docSnapShot else {return}
            guard let Data = Snapshot.data() else {return}
            
            guard let RepliesArray = Data["Replies"] as? [[String:Any]]
                else {
                    //No Replies yet
                    self.isEmptyArray = true
                    self.showEmptyView(title: "This Review has no replies yet", Y_Axis: (self.view.frame.height/2) - 617)
                    self.view.layoutIfNeeded()
                    return
                 }
            
            for reply in RepliesArray {
                self.isEmptyArray = false
                let replyGiven = reply["Reply"] as? String ?? "Reply"
                let user = reply["UserName"] as? String ?? "User"
                let replyObject = ReplyComponents(profileName: user, userImage: UIImage(named:"a")!, reply: replyGiven)
                self.ArrayOfReplies.append(replyObject)
                self.tableView.reloadData()
                
            }
        }
    )}

    
    
    func retrieveSingleReply(){
            guard let pathrecieved = PathRecieved, pathrecieved != "No Path in retr Sing Rep"
                else { print("No Path recieved"); return }
            let db = Firestore.firestore().document("\(pathrecieved)/All Reviews/\(Variables.DocumentIDInReply)")
            db.addSnapshotListener { (docSnapShot, error) in
            guard let Snapshot = docSnapShot else {return}
            guard let Data = Snapshot.data() else {return}
            
            guard let RepliesArray = Data["Replies"] as? [[String:Any]] else {return}
            let Count = RepliesArray.count
            let replyGiven = RepliesArray[Count - 1]["Reply"] as? String ?? "Reply"
            let user = RepliesArray[Count - 1]["UserName"] as? String ?? "User"
            let replyObject = ReplyComponents(profileName: user, userImage: UIImage(named:"a")!, reply: replyGiven)
            self.ArrayOfReplies.append(replyObject)
            self.tableView.reloadData()
                
        }
        
    }
    
        func showEmptyView(title:String, Y_Axis:CGFloat) {
        
            let View = UIView(frame: CGRect(x: (self.view.frame.width/2) - 175, y:Y_Axis, width: 400, height: 100))
            View.tag = 98
            View.center = self.view.center
            View.backgroundColor = .white
            self.view.addSubview(View)
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
            label.tag = 99
            label.text = title
            label.textAlignment = .center
            label.textColor = .lightGray
            label.font = UIFont.italicSystemFont(ofSize: 18)
            label.center = View.center
            self.view.addSubview(label)
                      
    }
    
    func removeEmptyView() {
        
        if let viewWithTag = self.view.viewWithTag(98) {
            viewWithTag.removeFromSuperview()
        }
        
        if let labelWithTag = self.view.viewWithTag(99) {
            labelWithTag.removeFromSuperview()
        }
        self.view.layoutIfNeeded()
    }
    
    //MARK:- Problem to resolve
    //The addSnapshot listener doesnt work inside document change, so have to tackle that.
        
}
    
    

extension ReplyViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArrayOfReplies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let replyArrayComponent = ArrayOfReplies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "replyCell") as! ReplyTableViewCell
        cell.setArray(array: replyArrayComponent)
        
        return cell
    }
    
    
    
    
    
}

extension ReplyViewController:UITextFieldDelegate {
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        removeEmptyView()
        UIView.animate(withDuration: 0.5) {
            self.textFieldBottomContraint.constant = 259
            self.view.layoutIfNeeded()
    }
}
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.textFieldBottomContraint.constant = 0
            if (self.ReplytextField.text == "" || self.ReplytextField.text == "Your Reply") && self.isEmptyArray == true {
                self.showEmptyView(title: "This Review has no replies yet", Y_Axis: (self.view.frame.height/2) - 617)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ReplytextField.endEditing(true)
    }
}
