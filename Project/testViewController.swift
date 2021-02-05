//
//  testViewController.swift
//  Project
//
//  Created by apple on 6/1/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SVProgressHUD

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

protocol CheckLocation {
    func enteredLocation(Value:Bool)
}

class testViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var pinView : MKAnnotationView!
    let mapViewReuseId = "pin"
    var finalCoordinates:CLLocationCoordinate2D!
    var delegateToSendData:CheckLocation!
    
    //For posting Data to Firebase, and to store values from previousVC
    let UserID = Auth.auth().currentUser!.uid
    var boolValue:Bool?
    var varForWhichNumber:Int?
    
    //Variables to receive location and address from TouristPropertyClicked
    var lat:Double?
    var lon:Double?
    var Address:String?
    var city:String?
    var BoolToShowOnlyReadableMap:Bool = false
    
    //When opened for editing listing
    var pathOfListing:String?         //Contains path of the listing and lat\lon will be posted there. Receiving from OwnerAddListing2 VC
    var boolForEditListing:Bool?   //True value indicates map is opened when listing is being edited
    
    
    @objc func mapViewTapped(gestureRecognizer:UIGestureRecognizer) {
        if BoolToShowOnlyReadableMap {
            
            //Do Nothing when the map is opened by tourist
            
        } else {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        finalCoordinates = coordinate
        addPin(coordinate: coordinate)
        
        }
    }
    
    func addPin(coordinate:CLLocationCoordinate2D){
        
        mapView.removeAnnotations(mapView.annotations)
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = coordinate
        
        convertLatLongToAddress(latitude: coordinate.latitude, longitude: coordinate.longitude) { (placeMark) in
            if let name = placeMark.name {
                newAnnotation.title = name
            }
             
            guard let streetAddress = placeMark.thoroughfare else {return}
            guard let cityName = placeMark.locality else {return}
            
            newAnnotation.subtitle = ("\(streetAddress)") +  "," + ("\(cityName)")
            
            self.mapView.addAnnotation(newAnnotation)
            self.mapView.selectAnnotation(newAnnotation, animated: true)
            
        }
    }
        
        
        
        func addPinOnLoad(Coordinate:CLLocationCoordinate2D) {
            mapView.removeAnnotations(mapView.annotations)
                   let newAnnotation = MKPointAnnotation()
                   newAnnotation.coordinate = Coordinate
            mapView.addAnnotation(newAnnotation)
            mapView.selectAnnotation(newAnnotation, animated: true)

        }
    
    //Use this to style the headings in the Textfields when Tourist Opens map
    func addString(Text:String) -> NSMutableAttributedString {
        let text = NSMutableAttributedString(string: Text, attributes: [NSAttributedString.Key.font : UIFont(name: "AvenirNext-Bold", size: 24) as Any])
        return text
    }
        
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        //For UISearchTable
        let locationSearchTable = storyboard!.instantiateViewController(identifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        
        //SetUp Search Bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search For Places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        
        //Configure the UISearchController appearance
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        
        //This passes along a handle of the mapView from the main View Controller onto the locationSearchTable.
        locationSearchTable.mapView = mapView
        
        //Handle protocol "HandleMapSearch"
        locationSearchTable.handleMapSearchDelegate = self
        
        //To Move Pin
     let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapViewTapped))
        tapGesture.delegate = self as? UIGestureRecognizerDelegate
        mapView.addGestureRecognizer(tapGesture)
        
        //TextView PlaceHolder and Color
        addressTextView.text = "Enter Address"
        addressTextView.textColor = .lightGray
        
        
        //MARK:- Map Opened by Tourist
        
        //Add Anotation to Listing Location when the map is opened by Tourist
        if BoolToShowOnlyReadableMap {
            
            addPinOnLoad(Coordinate: CLLocationCoordinate2D(latitude: lat!, longitude: lon!))
            resultSearchController?.searchBar.isHidden = true
        //Add Address and city name to respective textFields
            
            addressTextView.text = "Address: " + Address!
            cityTextField.text = city ?? "City Name is Missing"
            addressTextView.isEditable = false
            cityTextField.isUserInteractionEnabled = false
            addressTextView.textColor = .black
        }
        
        
        let OpenCititestapGesture = UITapGestureRecognizer(target: self, action: #selector(openCities))
        cityTextField.addGestureRecognizer(OpenCititestapGesture)
        
        let toolBar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolBar.sizeToFit()
        toolBar.setItems([flexSpace,doneButton], animated: true)
        addressTextView.inputAccessoryView = toolBar
        
    }
    
    @objc func done() {
        addressTextView.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func openCities() {
        let Vc = storyboard?.instantiateViewController(identifier: "searchVC") as! SearchViewController
        Vc.delegateToHandleCitySearch = self
        Vc.chooseCityWhenAddingListing = true
        self.present(Vc, animated: true, completion: nil)
    }
    
    
    func convertLatLongToAddress(latitude:Double,longitude:Double, completion:@escaping((CLPlacemark)->())){
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in

            // Place details
            if let placeMarks = placemarks {
                completion(placeMarks[0])
            }
        })
        
        
    }
    
    
    @IBAction func doneTapped(_ sender: UIButton) {
        
        if BoolToShowOnlyReadableMap {
            
            navigationController?.popViewController(animated: true)
            
        } else if boolForEditListing == true {
            
            print("Edited Latitude: \(finalCoordinates.latitude) , Edited Longitude: \(finalCoordinates.longitude)")
            SVProgressHUD.show(withStatus: "Adding Location...")
            let db = Firestore.firestore()
            db.document(pathOfListing!).setData(["Address": addressTextView.text!, "City": cityTextField.text!, "Latitude": finalCoordinates.latitude, "Longitude": finalCoordinates.longitude], merge: true){(error) in
                if error != nil {
                    print("Error is \(error!.localizedDescription)")
                    SVProgressHUD.showError(withStatus: "Error adding Location")
                    SVProgressHUD.dismiss(withDelay: 1.5)
                    
                } else {
                    self.delegateToSendData.enteredLocation(Value: true)
                    SVProgressHUD.showSuccess(withStatus: "Location Added")
                    SVProgressHUD.dismiss(withDelay: 1)
                    print("Location is Posted")
                }
            }
            
            navigationController?.popViewController(animated: true)

        }
        else {
            print("Final Latitude: \(finalCoordinates.latitude) , Final Longitude: \(finalCoordinates.longitude)")
            
            SVProgressHUD.show(withStatus: "Adding Location...")
            
            let db = Firestore.firestore()
            db.collection(StaticVariable.WhichType).document(UserID).collection(UserID + StaticVariable.WhichType).document(StaticVariable.WhichType + "\(varForWhichNumber!)").setData(["Address": addressTextView.text!, "City": cityTextField.text!, "Latitude": finalCoordinates.latitude, "Longitude": finalCoordinates.longitude], merge: true){(error) in
                if error != nil {
                    print("Error is \(error!.localizedDescription)")
                    SVProgressHUD.showError(withStatus: "Error adding Location")
                    SVProgressHUD.dismiss(withDelay: 1.5)
                    
                } else {
                    self.delegateToSendData.enteredLocation(Value: true)
                    SVProgressHUD.showSuccess(withStatus: "Location Added")
                    SVProgressHUD.dismiss(withDelay: 1)
                    print("Location is Posted")
                }
            }
            
            navigationController?.popViewController(animated: true)
            
            
        }
    }
    
    
}



extension testViewController:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //If the map is opened up by tourist, it should open directly the listing map
        if BoolToShowOnlyReadableMap {
            let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
            
        } else {
            
        finalCoordinates = manager.location?.coordinate
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
}
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error is \(error)")
    }


}



extension testViewController:HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        
        finalCoordinates = placemark.coordinate
        // cache the pin
        selectedPin = placemark
        
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
        let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    

}

extension testViewController:MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
            if annotation.isMember(of: MKUserLocation.self) {
                return nil
            }
            
            let reuseId = "ProfilePinView"
            
            pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if pinView == nil {
                pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            
            
            pinView.canShowCallout = true
        
            //If map is Opened by tourist, then the annotation pin should not be dragged
            if BoolToShowOnlyReadableMap {
            
                pinView.isDraggable = false
                
            } else {
                
            pinView.isDraggable = true
                
            }
        
            pinView.image = UIImage(named: "pin")
            
            
            return pinView

        }
    
        
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        switch newState {
            
        case .starting:
            view.dragState = .dragging
            
        case .ending, .canceling:
            if BoolToShowOnlyReadableMap {
                
                //Do Nothing when the map is opened by tourist
                
            } else {
                
                guard let draggedCoordinates = view.annotation?.coordinate else {return}
                finalCoordinates = draggedCoordinates
                guard let draggedAnnotation = view.annotation as? MKPointAnnotation else {return}
                convertLatLongToAddress(latitude: draggedCoordinates.latitude, longitude: draggedCoordinates.longitude) { (placeMark) in
                
                    if let name = placeMark.name {
                    draggedAnnotation.title = name
                 }
                
                    guard let streetAddress = placeMark.thoroughfare else {return}
                    guard let cityName = placeMark.locality else {return}
                    draggedAnnotation.subtitle = ("\(streetAddress)") +  "," + ("\(cityName)")
                }
                
            }
            
            view.dragState = .none
            
        default: break
        
        }
    }
    

}

extension testViewController:UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter Address"
            textView.textColor = .lightGray
        }
    }

}

extension testViewController: citySearchProtocol {
    func selectedCityName(name: String) {
        cityTextField.text = name
    }
    
    
}

