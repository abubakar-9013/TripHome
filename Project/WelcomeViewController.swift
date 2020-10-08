//
//  WelcomeViewController.swift
//  Project
//
//  Created by apple on 5/8/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import Firebase
import Lottie


class WelcomeViewController: UIViewController {

    let animationView = AnimationView()
    @IBOutlet weak var headingLabel: UILabel!
    
    var docRef:DocumentReference!
    var Uid:String?
    var homeVC:UITabBarController? = nil
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fontColor()

        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        strtAnimation()
        if Auth.auth().currentUser != nil {
            //User is signed in
            print("User is logged in")
            docRef = Firestore.firestore().document("Users/\(Auth.auth().currentUser!.uid)")
            docRef.getDocument { (docSnapshot, error) in
                guard let docSnapshot = docSnapshot, docSnapshot.exists else { print("Error Founddddd");return}
                let myData = docSnapshot.data()
                let type = myData?["Role"] as? String ?? ""
                print(type)
                
                if type == "Owner" {
                    self.homeVC = self.storyboard?.instantiateViewController(identifier: "OwnerHomeTabBar") as? UITabBarController
                    self.view.window?.rootViewController = self.homeVC
                    self.view.window?.makeKeyAndVisible()
                    
                }
                else {
                    self.homeVC = self.storyboard?.instantiateViewController(identifier: "TouristHome") as? TouristHomeTabBarViewController
                    self.view.window?.rootViewController = self.homeVC
                    self.view.window?.makeKeyAndVisible()
                    
                }
            }
        
        }
        
          else {
                 print("User is loggedout")
                //Send User to Login/Signup Screen
           // let Storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let LoginVC = storyboard?.instantiateViewController(identifier: "FirstScreen") as! ViewController
            self.view.window!.rootViewController = LoginVC 
            self.view.window?.makeKeyAndVisible()
            
            
            
            }
        
    }
    
    func strtAnimation(){
        
        animationView.animation = Animation.named("4694-travel-the-world")
        animationView.contentMode = .scaleAspectFit
        animationView.frame = CGRect(x:(view.frame.width - 240) / 2, y: (view.frame.height - 177) / 2, width: 240, height: 177)
        animationView.backgroundColor = .clear
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
        
    }
    
    func fontColor(){
        
          let uiImage = UIImage(named: "ColorForText.jpeg")!
//        let backgroundColor = UIColor(patternImage: uiImage)
//            headingLabel.textColor = backgroundColor
        
        headingLabel.textColor = UIColor(patternImage: uiImage)
        
    }
    

  
    
}
    

