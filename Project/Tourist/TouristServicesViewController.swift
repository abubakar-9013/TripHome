//
//  TouristServicesViewController.swift
//  Project
//
//  Created by apple on 4/30/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class TouristServicesViewController: UIViewController {
    
    //IBOutlets
    @IBOutlet weak var hotelButton: UIButton!
    @IBOutlet weak var privateRooms: UIButton!
    @IBOutlet weak var sharedRooms: UIButton!
    @IBOutlet weak var home: UIButton!
    @IBOutlet weak var restaurants: UIButton!
    @IBOutlet weak var heading: UILabel!
    
    var searchVariable:Bool = false
    
    //IBActions
    @IBAction func hotelTapped(_ sender: UIButton){
        
        StaticVariable.listingSelectedTourist = "Hotel"
        performSegue(withIdentifier: "touristServiceClicked", sender: sender)
    
    }
    
    @IBAction func privateRoomTapped(_ sender: UIButton) {
        
        StaticVariable.listingSelectedTourist = "Private Room"
        performSegue(withIdentifier: "touristServiceClicked", sender: sender)
    }
    
    @IBAction func sharedRoomTapped(_ sender: UIButton) {
        
        StaticVariable.listingSelectedTourist = "Shared Room"
        performSegue(withIdentifier: "touristServiceClicked", sender: sender)
    }
    
    @IBAction func homeTapped(_ sender: UIButton) {
        
        StaticVariable.listingSelectedTourist = "House"
        performSegue(withIdentifier: "touristServiceClicked", sender: sender)
    }
    
    @IBAction func restaurantTapped(_ sender: UIButton) {
        
        StaticVariable.listingSelectedTourist = "Restaurant"
        performSegue(withIdentifier: "touristServiceClicked", sender: sender)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if searchVariable {
            heading.text = "Services in \(StaticVariable.searchPlace)"
            heading.font = heading.font.withSize(24)
            
        }
        

        // Do any additional setup after loading the view.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "touristServiceClicked" {
            if searchVariable {
            let VC = segue.destination as! TouristClickedServicesViewController
            VC.searchVar = true
           }
        }
     }
    

}
