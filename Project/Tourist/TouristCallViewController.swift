//
//  TouristCallViewController.swift
//  Project
//
//  Created by apple on 5/19/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class TouristCallViewController: UIViewController {

    @IBOutlet weak var phoneNumberDisplay: UILabel!
    var Number:String?
    
    @IBAction func doneTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func call_Message_Email(_ sender: UIButton) {
    
    //If Call is tapped
    
        
    //If Message is tapped
       
    }
    
    func message () {
        
        let phoneNumber = Number!
        let text = "Enter Your Message"
        guard let messageURL = NSURL(string: "sms:\(phoneNumber)&body=\(text)")
               else { return }
        if UIApplication.shared.canOpenURL(messageURL as URL) {
           UIApplication.shared.open(messageURL as URL, options: [:], completionHandler: nil)
        }
    }
    
    
    func call() {
        
        guard let url = URL(string: "telprompt://\(Number!)"),
                        UIApplication.shared.canOpenURL(url)
                        else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    
    func email() {
        if let email = Number {
        if let url = URL(string: "mailto:\(email)") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
         }
       }
     }
  }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneNumberDisplay.text = Number

}
    
    
}
