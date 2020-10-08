//
//  TouristClickedServicesClickedPropertyViewController.swift
//  Project
//
//  Created by apple on 5/1/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

class TouristClickedServicesClickedPropertyViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var ImageArr = [UIImage(named: "a"),UIImage(named: "b"),UIImage(named: "c")]
                    
                    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
}

extension TouristClickedServicesClickedPropertyViewController:UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell123", for: indexPath) as? UICollectionViewCell
       // cell?.imgView.image = ImageArr[indexPath.row]
        return cell!
    }
    
    
}

extension TouristClickedServicesClickedPropertyViewController:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}
