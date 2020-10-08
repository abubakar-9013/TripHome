//
//  OwnerDashboardViewController.swift
//  Project
//
//  Created by apple on 5/16/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase

class OwnerDashboardViewController: UIViewController {
    @IBOutlet weak var hotelButton: UIButton!
    @IBOutlet weak var privateRooms: UIButton!
    @IBOutlet weak var sharedRooms: UIButton!
    @IBOutlet weak var home: UIButton!
    @IBOutlet weak var restaurants: UIButton!
    
    
    @IBAction func hotelsTapped(_ sender: UIButton) {
        
        StaticVariable.whichListingClicked = "Hotel"
        performSegue(withIdentifier: "listingButtonTapped", sender: sender)
        
    }
    
    @IBAction func privateRoomTapped(_ sender: UIButton) {
        
        StaticVariable.whichListingClicked = "Private Room"
        performSegue(withIdentifier: "listingButtonTapped", sender: sender)
    }
    
    @IBAction func sharedRoomTapped(_ sender: UIButton) {
        
        StaticVariable.whichListingClicked = "Shared Room"
        performSegue(withIdentifier: "listingButtonTapped", sender: sender)
    }
    
    
    @IBAction func homeTapped(_ sender: UIButton) {
        
        StaticVariable.whichListingClicked = "House"
        performSegue(withIdentifier: "listingButtonTapped", sender: sender)
    }
    
    
    @IBAction func restaurantTapped(_ sender: UIButton) {
        
        StaticVariable.whichListingClicked = "Restaurant"
        performSegue(withIdentifier: "listingButtonTapped", sender: sender)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
}
