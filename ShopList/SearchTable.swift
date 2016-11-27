//
//  SearchTable.swift
//  ShopList
//
//  Created by Josh Hunziker on 11/19/16.
//  Copyright © 2016 Josh Hunziker. All rights reserved.
//



import UIKit
import MapKit

class SearchTable : UITableViewController, UISearchResultsUpdating {
 
    var matchingPlaces:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
/*********************************************************************************************
*
*       API Call
*
*********************************************************************************************/
    
    //MKLocalSearch API call
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { response, _ in
            guard let response = response else {
                return
            }
            self.matchingPlaces = response.mapItems
            self.tableView.reloadData()
        }
    }
    
/*********************************************************************************************
*
*       Table View
*
*********************************************************************************************/
    
    //Returns the number of matching places
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingPlaces.count
    }
    
    //Populate each cell with information returned form the API call
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell")!
        let selectedItem = matchingPlaces[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = selectedItem.addressDictionary!["Street"] as? String
        return cell
    }
    
    //Drops pin at selected location
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = matchingPlaces[indexPath.row].placemark
        handleMapSearchDelegate?.dropPin(selectedItem)
        dismissViewControllerAnimated(true, completion: nil)
    }

}