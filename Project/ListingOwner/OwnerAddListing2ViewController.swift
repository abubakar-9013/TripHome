//
//  OwnerAddListing2ViewController.swift
//  Project
//
//  Created by apple on 5/5/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase

class OwnerAddListing2ViewController: UIViewController {
    
    
    @IBOutlet weak var mainHeading_2: UILabel!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var currencyField: UITextField!
    @IBOutlet weak var chargesField: TextFieldMinMaxCharachters!
    @IBOutlet weak var daysField: UITextField!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var daysPicker: UIPickerView!
    @IBOutlet weak var phoneField: TextFieldMinMaxCharachters!
    @IBOutlet weak var emailField: TextFieldMinMaxCharachters!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var RoomsField: UITextField!
    @IBOutlet weak var guestsField: UITextField!
    @IBOutlet weak var bathsField: UITextField!
    
    
    @IBOutlet weak var parentStack: UIStackView!
    @IBOutlet weak var stackViewWithRoomsAndGuests: UIStackView!
    @IBOutlet weak var roomsStackView: UIStackView!
    @IBOutlet weak var guestsStackView: UIStackView!
    @IBOutlet weak var bedsStackView: UIStackView!
    
    //Constraints
    @IBOutlet weak var parentStackTopToCurrency: NSLayoutConstraint!
    @IBOutlet weak var parentStackTopToTextField: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var parentStackHeight: NSLayoutConstraint!
    @IBOutlet weak var emailAddressViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nextButtonTopDistanceToErrorLabel: NSLayoutConstraint!
    
    
    //Variable to receive data from testViewController through protocol and delegate
    var delegateToReceieveData:HandleMapSearch? = nil
    
    
    let defaults = UserDefaults.standard
    var WhichNumberOfListing:Int = 0
    let Lst = StaticVariable.WhichType
    
    //Variables for editing Property
    var path:String?
    var BoolForEditing_2 = false
    var docRef:DocumentReference!
    
    
    
    let DataForCurrency : [String] = ["USD", "Rs"]
    let DataForDays : [String] = ["PerNight", "PerWeek", "PerMonth"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if StaticVariable.WhichType == "Restaurant" {
            stackViewWithRoomsAndGuests.isHidden = true
            currencyField.text = "Rs"
            currencyField.isUserInteractionEnabled = false
            currencyField.isEnabled = false
            chargesField.text = "-"
            chargesField.isUserInteractionEnabled = false
            chargesField.isEnabled = false
            daysField.text = "Dish"
            daysField.isUserInteractionEnabled = false
            daysField.isEnabled = false
            self.view.layoutIfNeeded()
        }
        
        if StaticVariable.WhichType == "Hotel" {
            
            bedsStackView.isHidden = true
            stackViewWithRoomsAndGuests.distribution = .fillEqually
            
        }
        
        if StaticVariable.WhichType == "Restaurant" {
            currencyPicker.isHidden = true
            daysPicker.isHidden = true
            parentStackTopToTextField.constant = 20
            parentStackHeight.constant = 115
            emailAddressViewHeight.constant = 50
            nextButtonTopDistanceToErrorLabel.constant = 165
            
            self.view.layoutIfNeeded()
        }
        else {
            currencyField.inputView = currencyPicker
            daysField.inputView = daysPicker
        }
        
        if BoolForEditing_2{
            print("In Editing Again")
            mainHeading_2.text = "Edit Property"
            editFields_2()
        }
    
        StaticVariable.Increment.Hotels = CheckNumber(type: Keys.keys.numberOfHotels)
        StaticVariable.Increment.House = CheckNumber(type: Keys.keys.numberOfHouse)
        StaticVariable.Increment.Shared_Rooms = CheckNumber(type: Keys.keys.numberOfSharedRooms)
        StaticVariable.Increment.Private_Rooms = CheckNumber(type: Keys.keys.numberOfPrivateRooms)
        StaticVariable.Increment.Restaurant = CheckNumber(type: Keys.keys.numberOfRestaurant)
        
        //["Hotel","Shared Room", "Private Room", "House", "Restaurant"]
        
        switch Lst {
        case Keys.keys.numberOfHotels :
                WhichNumberOfListing = StaticVariable.Increment.Hotels
        case Keys.keys.numberOfHouse:
                WhichNumberOfListing = StaticVariable.Increment.House
        case Keys.keys.numberOfSharedRooms:
                WhichNumberOfListing = StaticVariable.Increment.Shared_Rooms
        case Keys.keys.numberOfPrivateRooms:
                WhichNumberOfListing = StaticVariable.Increment.Private_Rooms
        case Keys.keys.numberOfRestaurant:
                WhichNumberOfListing = StaticVariable.Increment.Restaurant

        default:
                WhichNumberOfListing = 100
        }
        
        //disbaling UserInteraction
        currencyField.isUserInteractionEnabled = false
        daysField.isUserInteractionEnabled = false
        
        
        //TextField Delegates
        chargesField.delegate = self
        phoneField.delegate = self
        daysField.delegate = self
        phoneField.delegate = self
        emailField.delegate = self
        RoomsField.delegate = self
        guestsField.delegate = self
        bathsField.delegate = self
        chargesField.valueType = .onlyNumbers
        phoneField.valueType = .phoneNumber
        
        //For differentiating between House and other listing, convert placeholder to number of rooms instead of no of beds if its a house
        
        
        //TapGesture for location
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openMap))
        locationField.addGestureRecognizer(tapGesture)
        
        let toolBar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolBar.sizeToFit()
        toolBar.setItems([flexSpace,doneButton], animated: true)
        emailField.inputAccessoryView = toolBar
        
        
    }
    
    @objc func done() {
        emailField.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func openMap(){
        print("OpenMap")
        let VC = storyboard?.instantiateViewController(identifier: "mapVC") as! testViewController
        VC.delegateToSendData = self
        VC.varForWhichNumber = WhichNumberOfListing
        if BoolForEditing_2 {
            VC.pathOfListing = path
            VC.boolForEditListing = true
        }
        
        navigationController?.pushViewController(VC, animated: true)
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
    
    
    func ValidateFields() ->String? {
        
        //Check for empty Fields  (Do for location in future)
        if currencyField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           chargesField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           daysField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           phoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            errorLabel.text = "Please Fill All fields"
            errorLabel.alpha = 1
            return errorLabel.text
            
            
            /*
             || RoomsField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || guestsField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
             */
        }
        
        let validation = Validation()
        if !(validation.isValidEmail(email: emailField.text!)) {
            
            errorLabel.text = "Email Format is not valid"
            errorLabel.alpha = 1
            return errorLabel.text
        }
        
        if (phoneField.text?.count != 11) {
            errorLabel.text = "Your Phone number is incorrect, Please follow the given format i.e 03XXXXXXXX"
            errorLabel.alpha = 1
            return errorLabel.text
        }
    
        return nil
    }
    
    func editFields_2() {
        
        let db = Firestore.firestore()
        docRef = db.document(path!)
        docRef.getDocument { (docSnapshot, error) in
            if error != nil {
                
            }
            else {
                guard let snapshot = docSnapshot, snapshot.exists else {return}
                guard let myData = snapshot.data() else {return}
                self.currencyField.text = myData["Currency"] as? String ?? "No Currency"
                self.chargesField.text = myData["Charges"] as? String ?? "No Charges"
                self.daysField.text = myData["Days"] as? String ?? "No Days"
                self.bathsField.text = myData["Baths"] as? String ?? "No Baths"
                self.RoomsField.text = myData["Rooms"] as? String ?? "No Rooms"
                self.guestsField.text = myData["Guests"] as? String ?? "No Guests"
                self.phoneField.text = myData["Phone"] as? String ?? "No Number"
                self.emailField.text = myData["EmailAddress"] as? String ?? "No Email"
                
            }
        }
    }
    
    
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let db = Firestore.firestore()
        let UserID = Auth.auth().currentUser!.uid
        
        let error = ValidateFields()
        if error != nil {
            return
        }
        else {
        
        let currency = currencyField.text
        let charges = chargesField.text
        let days = daysField.text
        let phone = phoneField.text
        let email = emailField.text
        let totalRooms = RoomsField.text
        let totalGuests = guestsField.text
        let totalBaths = bathsField.text
            
            if BoolForEditing_2{
                
                db.document(path!).setData(["Currency": currency!, "Charges" : charges!, "Days" : days!, "Phone" : phone!, "EmailAddress" : email!, "Rooms": totalRooms!, "Guests":totalGuests!, "Baths":totalBaths!], merge: true){(error) in
                    
                    if error != nil {
                        
                    }
                    else {
                        print("Posted Successfully")
                        self.performSegue(withIdentifier: "AddPropertyTwo", sender: sender)

                    }
                    
                    }
            }
            else {
            
        
                db.collection(StaticVariable.WhichType).document(UserID).collection(UserID + StaticVariable.WhichType).document(StaticVariable.WhichType + "\(WhichNumberOfListing)").setData(["Currency": currency!, "Charges" : charges!, "Days" : days!, "Phone" : phone!, "EmailAddress" : email!, "Rooms": totalRooms!, "Guests":totalGuests!, "Baths":totalBaths!], merge: true) {(error) in
                    if error != nil {
                        
                    }
                    else {
                        print("Data Posted Succesfully")
                        StaticVariable.WhichNumber = self.WhichNumberOfListing
                        self.performSegue(withIdentifier: "AddPropertyTwo", sender: sender)
                    }
                    
                }
        
          }
 
    }
    
}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddPropertyTwo" {
            if let destVC = segue.destination as? OwnerAddListingFacilitiesViewController {
                if BoolForEditing_2 {
                    destVC.path = path
                    destVC.boolForEditing_3 = true
                }
            }
        }
    }
    
}



extension OwnerAddListing2ViewController:UIPickerViewDataSource,UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == currencyPicker {
            return DataForCurrency.count
        }
        else {
            return DataForDays.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == currencyPicker {
                   return DataForCurrency[row]
               }
               else {
                   return DataForDays[row]
               }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == currencyPicker {
            
            currencyField.text = DataForCurrency[row]
        }
        else {
            daysField.text = DataForDays[row]
        }
        
               
    }
}

extension OwnerAddListing2ViewController: UITextFieldDelegate {
    
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            
            self.heightConstraint.constant = 622+280
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 622
        }
    }
    
}

extension OwnerAddListing2ViewController:CheckLocation{
    func enteredLocation(Value: Bool) {
        if Value {
            locationField.text = "Location Saved"
            locationField.textColor = .green
        }
    }
    

}


