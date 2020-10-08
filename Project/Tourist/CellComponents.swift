//
//  CellComponents.swift
//  Project
//
//  Created by apple on 4/22/20.
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation
import UIKit

class CellComponents {
    
       var image: UIImage
       var typeOfListing:String
       var charges:Int
       var rating:Float
       var nameOfListing: String
       var cityName : String
       var detail : String
       var currency:String
       var days:String

    
    
    init (image:UIImage, typeOfListing:String, charges:Int, rating:Float, nameOfListing:String, cityName:String, detail:String, currency: String, days:String)
{
    self.image = image
    self.typeOfListing = typeOfListing
    self.charges = charges
    self.rating = rating
    self.nameOfListing = nameOfListing
    self.cityName = cityName
    self.detail = detail
    self.currency = currency
    self.days = days
    
}
        
}

class New_CellComponents {
    
       var imageUrl: String
       var typeOfListing:String
       var charges:Int
       var rating:Float
       var nameOfListing: String
       var cityName : String
       var detail : String
       var currency:String
       var days:String

    
    
    init (image:String, typeOfListing:String, charges:Int, rating:Float, nameOfListing:String, cityName:String, detail:String, currency: String, days:String)
{
    self.imageUrl = image
    self.typeOfListing = typeOfListing
    self.charges = charges
    self.rating = rating
    self.nameOfListing = nameOfListing
    self.cityName = cityName
    self.detail = detail
    self.currency = currency
    self.days = days
    
}
        
}
