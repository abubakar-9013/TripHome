//
//  FilterViewController.swift
//  Project
//
//  Created by Abu Bakar on 11/18/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import WARangeSlider
import Firebase

class FilterViewController: UIViewController {
    
    let rangeSlider1 = RangeSlider(frame: CGRect.zero)
    
    var leftLabel:UILabel = {
    
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Min"
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return lbl
        
    }()
    
    
    var rightLabel:UILabel = {
    
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Max"
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return lbl
        
    }()
    
    
    
    
    var minLabel:UILabel = {
       
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "2000"
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return lbl
        
    }()
    
    var maxLabel:UILabel = {
       
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.text = "8000"
        return lbl
        
    }()
    
    var doneButton:UIButton = {
       
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 25
        btn.setTitle("Filter", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
        return btn
        
    }()
    
    @objc func donePressed() {
        
        print("Min \(minLabel.text!), Max \(String(describing: maxLabel.text!))")
        
        
        let vc = storyboard?.instantiateViewController(identifier: "TouristHomeScreen") as! TouristHomeScreenViewController
        
        vc.minVal = (minLabel.text as! NSString).integerValue
        vc.maxVal = (maxLabel.text as! NSString).integerValue
        vc.filterApplied = true
        self.present(vc, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        view.addSubview(rangeSlider1)
        view.addSubview(leftLabel)
        view.addSubview(rightLabel)
        view.addSubview(minLabel)
        view.addSubview(maxLabel)
        view.addSubview(doneButton)
               
        NSLayoutConstraint.activate([
        
            leftLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            leftLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            
            rightLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            rightLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            
            
            
            minLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            minLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            
            maxLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            maxLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 150),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
            
        
        
        ])
        
        rangeSlider1.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
        
        
    }
    
    override func viewDidLayoutSubviews() {
            
        rangeSlider1.frame = CGRect(x: 20.0, y: 100,
            width: 330, height: 31.0)
            
        }
        
        @objc func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
            
            minLabel.text = String((rangeSlider.lowerValue * 10000).rounded())
            maxLabel.text = String((rangeSlider.upperValue * 10000).rounded())
        }
    



    
}
