//
//  TableViewController.swift
//  Login
//
//  Created by Dusan Matejka on 12/6/15.
//  Copyright © 2015 Dusan Matejka. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController {


    var checked = [Bool]()
    var pole = FollowersData()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let users = PFQuery(className: "_User")
        
        users.whereKey("objectId", notContainedIn: [PFUser.currentUser()!.objectId!])
        users.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error == nil){
                for object in objects!{
                    self.pole.uzivatelia.append(object as! PFUser)
                    self.pole.uzivateliaId.append(object.objectId!)
                    self.checked.append(false)
                }
                
                let query = PFQuery(className: "Following")
                query.whereKey("follower", equalTo: PFUser.currentUser()!)
                query.findObjectsInBackgroundWithBlock() { (objects, error) in
                    for object in objects!{
                        let user = object["following"] as! PFUser
                        self.checked[self.pole.uzivateliaId.indexOf(user.objectId!)!] = true
                    }
                    self.tableView.reloadData()
                }
                
            }else{
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pole.uzivatelia.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellTabView", forIndexPath: indexPath)
        if (checked[indexPath.row] == true){
            cell.accessoryType = .Checkmark
        }else{
            cell.accessoryType = .None
        }
        cell.textLabel?.text = self.pole.uzivatelia[indexPath.row].username
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark{
                cell.accessoryType = .None
                checked[indexPath.row] = false
                let following = PFQuery(className: "Following")
                following.whereKey("following", equalTo: self.pole.uzivatelia[indexPath.row])
                following.whereKey("follower", equalTo: PFUser.currentUser()!)
                following.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    for object in objects!{
                        object.deleteInBackground()
                    }
                })
            }else{
                cell.accessoryType = .Checkmark
                checked[indexPath.row] = true
                let following = PFObject(className: "Following")
                following["following"] = self.pole.uzivatelia[indexPath.row]
                following["follower"] = PFUser.currentUser()
                following.saveInBackgroundWithBlock() { (success, error) in
                    // ...
                    
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! FeedCollectionViewController
        destinationVC.pole = self.pole
        destinationVC.checked = self.checked
    }

}
