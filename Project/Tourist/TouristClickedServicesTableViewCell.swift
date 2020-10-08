//
//  TouristClickedServicesTableViewCell.swift
//  Project
//
//  Created by apple on 5/1/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class TouristClickedServicesTableViewCell: UITableViewCell {
    @IBOutlet weak var ListingImage: UIImageView!
    @IBOutlet weak var typeOfListing: UILabel!
    @IBOutlet weak var ListingName: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var charges: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var details: UITextView!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var days: UILabel!

    
    func setListingData(array:New_CellComponents) {
     
       // ListingImage.image = array.image
        typeOfListing.text = array.typeOfListing
        charges.text = String(array.charges)
        rating.text = String(array.rating)
        ListingName.text = array.nameOfListing
        cityName.text = array.cityName
        details.text = array.detail
        currency.text = array.currency
        days.text = array.days
         
        
    }



}
