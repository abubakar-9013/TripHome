//
//  OwnerFirstPageViewController.swift
//  Project
//
//  Created by apple on 5/4/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit


class OwnerFirstPageViewController: UIViewController {
    
    var showSkipButton:Bool = true
    
    @IBOutlet weak var skipButton: UIBarButtonItem!
    
    @IBAction func SkipPressed(_ sender: UIBarButtonItem) {
        
        let OwnerHome = storyboard?.instantiateViewController(identifier: "OwnerHomeTabBar") as? UITabBarController
        view.window?.rootViewController = OwnerHome
        view.window?.makeKeyAndVisible()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if showSkipButton == false {
            skipButton.isEnabled = false
            skipButton.tintColor = .clear
        }
   
    }
    

}
