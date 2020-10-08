//
//  HomeTabBarViewController.swift
//  Project
//
//  Created by apple on 5/8/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase

class TouristHomeTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser?.uid != nil {
            print("Not Nill")
        } else {
            print(" Nill")
             let startVC = storyboard?.instantiateViewController(identifier: "FirstScreen") as? ViewController
             view.window?.rootViewController = startVC
             view.window?.makeKeyAndVisible()
         }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
