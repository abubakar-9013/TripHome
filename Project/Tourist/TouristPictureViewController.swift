//
//  TouristPictureViewController.swift
//  Project
//
//  Created by apple on 6/4/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class TouristPictureViewController: UIViewController {
    
    @IBOutlet weak var picture: UIImageView!
    var imageURL:String?
    var profilePictureURL:String?
    var imageForAllReviews:String?  //When opened 'All reviews' and then in view Images, this url has value
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = imageURL {
            gettingImage(url: imageURL!)
        }

        else if let _ = imageForAllReviews {
            gettingImage(url: imageForAllReviews!)
        }
        
        else if let _ = profilePictureURL {
            gettingImage(url: profilePictureURL!)
        }

}
    
    
    func gettingImage(url:String) {
        
        picture.kf.indicatorType = .activity
        let Url = URL(string: url)
        if let Url = Url {
            let resource = ImageResource(downloadURL: Url, cacheKey: Url.absoluteString)
            
            if let _ = profilePictureURL {
                //Placeholder will be of profile
                    picture.kf.setImage(with: resource, placeholder: UIImage(named: "profilePlaceholder"))
            }
            else {
                //Placeholder will be of property
                    picture.kf.setImage(with: resource, placeholder: UIImage(named: "placeHolderImage"))
            }
        }
    }
        

    

}
