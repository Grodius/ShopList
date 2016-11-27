//
//  TableVC.swift
//  ShopList
//
//  Created by Josh Hunziker on 10/17/16.
//  Copyright © 2016 Josh Hunziker. All rights reserved.
//

import UIKit
import CoreData

class TableVC: UITableViewController {
    
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var fetchResults = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = 80
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Return number of items in core data
    func fetchShopListItems() -> Int {
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Item")
        var x = 0
        // Execute the fetch request, and cast the results to an array of LogItem objects
        fetchResults = ((try? context.executeFetchRequest(fetchRequest)) as? [Item])!
        
        x = fetchResults.count
        
        return x
    }
    
/*********************************************************************************************
*
*       Table View
*
*********************************************************************************************/
    
    //Refresh table view when it appears
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }

    //Number of sections
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    //NUmber of rows in section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchShopListItems()
    }

    //Populate each row with an item from core data
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as! CustomCell
        
        let item = fetchResults[indexPath.row]
        
        cell.cellName?.text = item.valueForKey("name")?.description
        cell.cellQuantity.text = item.valueForKey("quantity")?.description
        if item.valueForKey("pic") != nil{
            let picture = UIImage(data: item.valueForKey("pic")  as! NSData)
            cell.cellImage.image = picture
        }

        return cell
    }

    //Delete the selected item from the table and remove it from core data
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            //Remove data from array
            context.deleteObject(fetchResults[indexPath.row])
            do {
                try context.save()
            } catch _ {
                print("Error in deleting the object")
            }
            fetchResults.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            
            //Update table
            tableView.reloadData()
        }
    }

/*********************************************************************************************
*
*       Segue
*
*********************************************************************************************/
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if(segue.identifier == "viewExistingItem"){
            if let indexPath = self.tableView.indexPathForSelectedRow{
                let currentItem = fetchResults[indexPath.row]
                let addEditVC: AddEditVC = (segue.destinationViewController as? AddEditVC)!
                
                addEditVC.newItem = currentItem;
            }
        }
    }

}
