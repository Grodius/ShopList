//
//  AddEditVC.swift
//  ShopList
//
//  Created by Josh Hunziker on 10/17/16.
//  Copyright © 2016 Josh Hunziker. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

protocol HandleMapSearch {
    func dropPin(placemark:MKPlacemark)
}

class AddEditVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, HandleMapSearch, UITextFieldDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    var newItem: NSManagedObject?
    var new: Bool = false
    
    let locationManager = CLLocationManager()
    var pin:MKPlacemark? = nil
    
    var resultSearchController:UISearchController? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TextField delegates
        nameField.delegate = self
        quantityField.delegate = self

        //Map Modifications
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        self.map.scrollEnabled = true

        
        //UI Modifications
        addPhotoButton.layer.cornerRadius = 10
        addPhotoButton.contentEdgeInsets = UIEdgeInsetsMake(5,5,5,5)
        nameField.sizeToFit()
        quantityField.sizeToFit()
        
        //Set up search controller
        let searchTable = storyboard!.instantiateViewControllerWithIdentifier("SearchTable") as! SearchTable
        resultSearchController = UISearchController(searchResultsController: searchTable)
        resultSearchController?.searchResultsUpdater = searchTable
        
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for stores"
        searchBar.showsCancelButton = false
        searchBar.tintColor = UIColor.whiteColor()
        navigationItem.titleView = resultSearchController?.searchBar

        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        searchTable.mapView = map
        searchTable.handleMapSearchDelegate = self
        
        
        //Fill in data if viewing an existing item
        if newItem != nil{
            nameField.text = newItem?.valueForKey("name") as? String
            quantityField.text = newItem?.valueForKey("quantity") as? String
            if newItem?.valueForKey("pic") != nil{
                let image = newItem?.valueForKey("pic") as! NSData
                imageView.image = UIImage(data: image)
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Cancel entry and do not add to CoreData
    @IBAction func cancelEntry(sender: AnyObject) {
        dismissVC()
    }
    
/*********************************************************************************************
*
*       Core Data
*
*********************************************************************************************/
    
    //Stores a new Item or updates an existing one
    @IBAction func saveItemToCoreData(sender: AnyObject) {
        if nameField.text != "" || quantityField.text != "" || imageView.image != nil{
            
            let itemDataContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            
            if newItem == nil{
                let ent = NSEntityDescription.entityForName("Item", inManagedObjectContext: itemDataContext)
                
                newItem = Item(entity: ent!, insertIntoManagedObjectContext: itemDataContext)
                new = true
                
            }
            
            newItem?.setValue(nameField.text, forKey: "name")
            newItem?.setValue(quantityField.text, forKey: "quantity")
            
            if imageView.image != nil {
                let imageData = UIImagePNGRepresentation(imageView.image!)
                newItem?.setValue(imageData, forKey: "pic")
            }
            
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(queue) { () -> Void in
                
                do {
                    try itemDataContext.save()
                }
                catch{
                    print("Did not Save")
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                })
            }
        }
        else{
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
/*********************************************************************************************
*
*       Keyboard
*
*********************************************************************************************/
    
    //Dismiss View Controller
    func dismissVC(){
        navigationController?.popViewControllerAnimated(true)
    }
    //Hide keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    //Return hides keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
/*********************************************************************************************
*
*       Photos
*
*********************************************************************************************/
    
    //Select image from Photos
    @IBAction func selectFromPhotos(sender: AnyObject) {
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) { () -> Void in
            
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .PhotoLibrary
            
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(picker, animated: true, completion: nil)
            })
        }
    }
    
    //Display image in view
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        
        let startImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) { () -> Void in
            
            self.imageView.image = startImage

            dispatch_async(dispatch_get_main_queue(), {
                picker.dismissViewControllerAnimated(true, completion: nil)
            })
        }

        
    }

    
/*********************************************************************************************
*
*       Location
*
*********************************************************************************************/
    
    //Authorize app for location when in use
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    //Set region with user's location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        if location != nil {
            print("location:: \(locations.first)")
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location!.coordinate, span: span)
            map.setRegion(region, animated: true)
        }
    }
    
    //print error if cannot retrieve location
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
    
    //Drops a pin on the location selected in the search bar
    func dropPin(placemark:MKPlacemark){
        pin = placemark
        map.removeAnnotations(map.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        map.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        map.setRegion(region, animated: true)
    }
    
    //Create directions button
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pinView?.pinTintColor = UIColor.redColor()
        pinView?.canShowCallout = true
        
        
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: CGSize(width: 30, height: 30)))
        button
        button.setBackgroundImage(UIImage(named: "directions"), forState: .Normal)
        button.layer.cornerRadius = button.frame.size.width / 2
        button.clipsToBounds = true;
        button.addTarget(self, action: #selector(AddEditVC.getDirections), forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    //Opens Maps with directions to desired location
    func getDirections(){
        if let pin = pin {
            let mapItem = MKMapItem(placemark: pin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
    }
}

