//
//  OwnerAddListingViewController.swift
//  Project
//
//  Created by apple on 5/4/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase


class OwnerAddListingViewController: UIViewController {
    
    @IBOutlet weak var mainHeading: UILabel!
    @IBOutlet weak var titleField: TextFieldMinMaxCharachters!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var typeOfListingField: UITextField!
    @IBOutlet weak var typeOfListingPicker: UIPickerView!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    let defaults = UserDefaults.standard
    var BoolVariableForEdit = false
    var path:String?
    var docRef:DocumentReference!
    
    
    
    
    let DataForTypeOfListing:[String] = ["Hotel","Shared Room", "Private Room", "House", "Restaurant"]


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if BoolVariableForEdit {
            mainHeading.text = "Edit Property"
            editFields()
        }
        StaticVariable.Increment.Hotels = CheckNumber(type: Keys.keys.numberOfHotels)
        StaticVariable.Increment.House = CheckNumber(type: Keys.keys.numberOfHouse)
        StaticVariable.Increment.Shared_Rooms = CheckNumber(type: Keys.keys.numberOfSharedRooms)
        StaticVariable.Increment.Private_Rooms = CheckNumber(type: Keys.keys.numberOfPrivateRooms)
        StaticVariable.Increment.Restaurant = CheckNumber(type: Keys.keys.numberOfRestaurant)
        
        
        typeOfListingField.inputView = typeOfListingPicker
        
        //FOR PLACEHOLDER IN TEXTVIEW
        textView.delegate = self
        textView.text = "Description"
        textView.textColor = UIColor.lightGray
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 1, bottom: 2, right: 0)
        
        //TextField Delegate and set lenght
        titleField.delegate = self
        titleField.maxLength = 15
        
        let toolBar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolBar.sizeToFit()
        toolBar.setItems([flexSpace,doneButton], animated: true)
        textView.inputAccessoryView = toolBar
        
        
     }
    
    @objc func done() {
           textView.endEditing(true)
           self.dismiss(animated: true, completion: nil)
       }
    
    func CheckNumber(type:String) -> Int {
        let Number = self.defaults.integer(forKey: type)
        return Number
    }
    
    
    
    func ValidateFields() ->String? {
        
        //Get Data from fields
        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let typeOfListing = typeOfListingField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //Check for empty Fields
        if title == "" || description == "" || typeOfListing == "" {
            errorLabel.text = "Please Fill All fields"
            errorLabel.alpha = 1
            return errorLabel.text
        }
        
        return nil
    }
    
    
    func editFields(){
        let db = Firestore.firestore()
        docRef = db.document(path!)
        docRef.getDocument { (docSnapshot, error) in
            guard let snapshot = docSnapshot, snapshot.exists else {return}
            guard let myData = snapshot.data() else {return}
            self.titleField.text = myData["Title"] as? String ?? "No Title"
            self.textView.text = myData["Description"] as? String ?? "No Description"
            self.textView.textColor = .black
            self.typeOfListingField.text = myData["Type"] as? String ?? "No Type"
            
        }
    }
    

    
    
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
        
        //Get reference to firebase Database
        let db = Firestore.firestore()
        
        let UserID = Auth.auth().currentUser!.uid
        
        let error = ValidateFields()
        if error != nil {
            print(error!)
        }
        else {
    
        //Get data from All fields
        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let typeOfListing = typeOfListingField.text
         
        //If its not Add Property, but edit Property
        if BoolVariableForEdit{
            print("Its Edit Property")
            StaticVariable.WhichType = typeOfListing!
            db.document(path!).setData(["Title": title!, "Description" : description, "Type" : typeOfListing!],merge: true){(error) in
                if error != nil {
                    
                }
                else {
                    print("Edited sucessfully")
                    self.performSegue(withIdentifier: "AddPropertyOne", sender: sender)
                }
            }
            
        }
        
        else {
        
        //Send Value Of typeOfListing class StaticVariableAndStuff to be accesible by other VC
        StaticVariable.WhichType = typeOfListing!

    //Post data tw database
        
        switch typeOfListing {
        case "Hotel":
            db.collection("Hotel").document("\(Auth.auth().currentUser!.uid)").collection(UserID + "Hotel").document("Hotel" + "\(StaticVariable.Increment.Hotels)").collection("All Reviews").document("DummyDocument").setData(["Dummy": "Data"])
                
            db.collection("Hotel").document("\(Auth.auth().currentUser!.uid)").collection(UserID + "Hotel").document("Hotel" + "\(StaticVariable.Increment.Hotels)").setData(["Title": title!, "Description" : description, "Type" : typeOfListing!]) {(error) in
                   if error != nil {
                    
                   }
                      else {
                             print("Data Posted Succesfully")
                          }
              }
            
        case "House":
            db.collection("House").document("\(Auth.auth().currentUser!.uid)").collection(UserID + "House").document("House" + "\(StaticVariable.Increment.House)").collection("All Reviews").document("DummyDocument").setData(["Dummy": "Data"])
            
                db.collection("House").document(UserID).collection(UserID + "House").document("House" + "\(StaticVariable.Increment.House)").setData(["Title": title!, "Description" : description, "Type" : typeOfListing!]) {(error) in
                    if error != nil {
                        
                    }
                       else {
                              print("Data Posted Succesfully")
                           }
             }

            
        case "Private Room":
            db.collection("Private Room").document("\(Auth.auth().currentUser!.uid)").collection(UserID + "Private Room").document("Private Room" + "\(StaticVariable.Increment.Private_Rooms)").collection("All Reviews").document("DummyDocument").setData(["Dummy": "Data"])
            
                db.collection("Private Room").document(UserID).collection(UserID + "Private Room").document("Private Room" + "\(StaticVariable.Increment.Private_Rooms)").setData(["Title": title!, "Description" : description, "Type" : typeOfListing!]) {(error) in
                     if error != nil {
                         
                     }
                        else {
                               print("Data Posted Succesfully")
                            }
              }

            
        case "Shared Room":
            db.collection("Shared Room").document("\(Auth.auth().currentUser!.uid)").collection(UserID + "Shared Room").document("Shared Room" + "\(StaticVariable.Increment.Shared_Rooms)").collection("All Reviews").document("DummyDocument").setData(["Dummy": "Data"])
            
                db.collection("Shared Room").document(UserID).collection(UserID + "Shared Room").document("Shared Room" + "\(StaticVariable.Increment.Shared_Rooms)").setData(["Title": title!, "Description" : description, "Type" : typeOfListing!]) {(error) in
                     if error != nil {
                         
                     }
                        else {
                               print("Data Posted Succesfully")
                            }
              }

            
            
        case "Restaurant":
            db.collection("Restaurant").document("\(Auth.auth().currentUser!.uid)").collection(UserID + "Restaurant").document("Restaurant" + "\(StaticVariable.Increment.Restaurant)").collection("All Reviews").document("DummyDocument").setData(["Dummy": "Data"])
            
                db.collection("Restaurant").document(UserID).collection(UserID + "Restaurant").document("Restaurant" + "\(StaticVariable.Increment.Restaurant)").setData(["Title": title!, "Description" : description, "Type" : typeOfListing!]) {(error) in
                     if error != nil {
                         
                     }
                        else {
                               print("Data Posted Succesfully")
                            }
              }

            
        default:
            print("Hotel")
        }
            
            performSegue(withIdentifier: "AddPropertyOne", sender: sender)
    
    }
  }
}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddPropertyOne" {
            
            if let destVC = segue.destination as? OwnerAddListing2ViewController {
                
    //Because when not Editing property, the value of Path will be nil, so have to check bool
                if BoolVariableForEdit {
                    print("Bool is \(BoolVariableForEdit)")
                    destVC.path = path
                    destVC.BoolForEditing_2 = true
          }
        }
      }
    }
  }

    
    
    


extension OwnerAddListingViewController : UITextViewDelegate {
    
    //TEXTVIEW DELEGATE METHODS
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.lightGray
        }
    }
    
}

extension OwnerAddListingViewController: UIPickerViewDataSource,UIPickerViewDelegate {
    
    //PICKERVIEW DELEGATE METHODS
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
  
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      
            return DataForTypeOfListing.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
            return DataForTypeOfListing[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
            typeOfListingField.text = DataForTypeOfListing[row]
             
    }
    
}

extension OwnerAddListingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var value:Bool?
        
        if let sdcTextField = textField as? TextFieldMinMaxCharachters {
            value = sdcTextField.verifyFields(shouldChangeCharactersIn: range, replacementString: string)
        }
        return value!
    }
    
}
