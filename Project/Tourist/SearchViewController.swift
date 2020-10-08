//
//  SearchViewController.swift
//  Project
//
//  Created by apple on 7/19/20.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit

protocol citySearchProtocol {
    func selectedCityName(name:String)
}

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let data = GenericFunctions.citiesNames
    var newData = [String]()
    var searching:Bool = false
    var chooseCityWhenAddingListing:Bool?
    
    //DelegateToHandle City Search
    var delegateToHandleCitySearch:citySearchProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        keyBoardToolBar()

    }
    
    
    
    func keyBoardToolBar() {
        let toolBar = UIToolbar()
        let toolBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolBar.setItems([flexSpace,toolBarButton], animated: true)
        toolBar.sizeToFit()
        searchBar.inputAccessoryView = toolBar
    }
    
    
    @objc func done() {
        
        searchBar.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
        
    }
    
}

extension SearchViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return newData.count
        }
        else {
            return data.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchTableViewCell
        if searching {
                cell.cityResult.text = newData[indexPath.row]
        }
        else {
           cell.cityResult.text = data[indexPath.row]
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // StaticVariable.searchByPlaceVariable = true
        if searching {
            StaticVariable.searchPlace = newData[indexPath.row]
        }
        else {
            
            StaticVariable.searchPlace = data[indexPath.row]
        }
        
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
        
        let VC = storyboard?.instantiateViewController(identifier: "serviceVC") as! TouristServicesViewController
        VC.searchVariable = true
        tableView.deselectRow(at: indexPath, animated: true)
        
        if chooseCityWhenAddingListing == true {
            //That is sending back to cityTextfield in testVc the value of city selected
            self.delegateToHandleCitySearch.selectedCityName(name: StaticVariable.searchPlace)
            self.dismiss(animated: true, completion: nil)
            
        }
        else {
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    
}

extension SearchViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        newData = data.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        tableView.reloadData()
    }
}


