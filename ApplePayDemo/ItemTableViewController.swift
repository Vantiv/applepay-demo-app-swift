//
//  ItemTableViewController.swift
//  ApplePayDemo
//
//  Created by Alec Paulson on 8/23/16.
//  Copyright © 2016 Vantiv. All rights reserved.
//

import UIKit

class ItemTableViewController: UITableViewController {
    //MARK: Properties
    var items = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSampleItems()
    }
    
    func loadSampleItems() {
        let photo1 = UIImage(named: "vantivFlask")!
        let item1 = Item(name: "Vantiv Flask", photo: photo1, price: 5.19)!
        
        let photo2 = UIImage(named: "vantivCap")!
        let item2 = Item(name: "Vantiv Cap", photo: photo2, price: 6.55)!
        
        let photo3 = UIImage(named: "vantivCalculator")!
        let item3 = Item(name: "Vantiv Calculator", photo: photo3, price: 5.75)!
        
        let photo4 = UIImage(named: "vantivShirt")!
        let item4 = Item(name: "Vantiv Shirt", photo: photo4, price: 19.95)!
        
        let photo5 = UIImage(named: "vantivFlashDrive")!
        let item5 = Item(name: "Vantiv Flash Drive", photo: photo5, price: 9.69)!
        
        items += [item1, item2, item3, item4, item5]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ItemTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ItemTableViewCell
        let item = items[(indexPath as NSIndexPath).row]
        
        cell.nameLabel.text = item.name
        cell.photoImageView.image = item.photo
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        cell.priceLabel.text = formatter.string(from: item.price)
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let itemDetailViewController = segue.destination as! ItemViewController
        
        if let selectedItemCell = sender as? ItemTableViewCell {
            let indexPath = tableView.indexPath(for: selectedItemCell)!
            let selectedItem = items[(indexPath as NSIndexPath).row]
            itemDetailViewController.item = selectedItem
        }
    }

}
