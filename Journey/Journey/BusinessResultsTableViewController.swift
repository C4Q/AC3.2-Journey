//
//  YelpResultsTableViewController.swift
//  Journey
//
//  Created by Jermaine Kelly on 11/8/16.
//  Copyright © 2016 Jermaine Kelly. All rights reserved.
//

import UIKit
import CoreLocation

class BusinessResultsTableViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate{
    
    var businessResults: [Business] = []
    let searchBar = UISearchBar()
    let locationManger = CLLocationManager()
    
    var postalCode : String = ""{
        didSet{
            print("Zip code is \(self.postalCode)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Conforms to delegate method
        self.locationManger.delegate = self
        //Gets user mot accurate location
        self.locationManger.desiredAccuracy = kCLLocationAccuracyBest
        //Only use location services when app is in the foreground
        self.locationManger.requestWhenInUseAuthorization()
        //Starts looking for location
        self.locationManger.startUpdatingLocation()
        
        
        createSearchBar()
        
        
        
    }
    
    
    // MARK: - Table view data source
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return businessResults.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BusinessResultTableViewCell.Identifier, for: indexPath) as! BusinessResultTableViewCell
        
        // Configure the cell...
        let business = businessResults[indexPath.row]
        
        cell.businessNameLabel.text = business.name
        cell.businessAddressLabel.text = "\(business.street), \(business.city),\(business.zipcode)"
        
        
        return cell
    }
    
    
     //MARK:- Location Delegate
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = manager.location else { return }
        CLGeocoder().reverseGeocodeLocation(location) { (placemark, error) in
            
            if error != nil {
                print("Location Error ===> \n \(error?.localizedDescription)")
            }
            
            if placemark!.count > 0 {
                let placemark = placemark![0]
                self.locationManger.stopUpdatingLocation()
                self.postalCode = placemark.postalCode!
            }
            
            
            DispatchQueue.main.async {
                self.getSearchResults(near: self.postalCode)
                self.tableView.reloadData()
                
            }
        }
    }
    
    
    //MARK:- Search delegates
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getSearchResults(for: searchBar.text!, near: postalCode)
    }
    
    
    
    //MARK:- Utitilies
    
    //gets the search result for a specific term
    func getSearchResults(for searchterm:String = "pizza", near zipCode:String){
        
        let yellowPageEndPoint = "http://pubapi.yp.com/search-api/search/devapi/search?searchloc=\(zipCode)&term=\(searchterm)&format=json&sort=distance&radius=5&listingcount=15&key=1fhn2vk8wv"
        print(yellowPageEndPoint)
        
        ApiRequestManager.manager.getData(apiUrl: yellowPageEndPoint) { (data) in
            guard let validData = data else { return }
            // dump(validData)
            
            if let validBusiness = BusinessFactory.manager.getBusinessData(from: validData){
                //dump(validBusiness)
                self.businessResults = validBusiness
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }
        
    }
    
    
    
    //Adds searchbar to navigation controller
    func createSearchBar(){
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Business..."
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        //self.tableView.tableHeaderView = searchBar
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let instaVC = segue.destination as? ImagesViewController{
            if segue.identifier == "showPictureResults"{
                if let index = tableView.indexPathForSelectedRow {
                    instaVC.buiness = businessResults[index.row]
                }
            }
        }
    }
    
    
}
