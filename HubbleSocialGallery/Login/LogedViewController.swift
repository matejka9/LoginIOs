//
//  LogedViewController.swift
//  Login
//
//  Created by Dusan Matejka on 10/19/15.
//  Copyright © 2015 Dusan Matejka. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Parse

class LogedViewController: UIViewController {
    let userName = "login"
    let tweetName = "tweetName"
    let facebookMail = "facebookMail"
    let facebookName = "facebookName"
    let facebookUrlPicture = "facebookPictureUrl"
    
    let loggedNormal = "logedNormal"
    
    var vstupnyView = String()
    
    @IBOutlet weak var labelFbName: UILabel!
    @IBOutlet weak var labelFbMail: UILabel!
    @IBOutlet weak var labelLogin: UILabel!
    @IBOutlet weak var imageProfil: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let nameFb =  defaults.valueForKey(tweetName) as? String{
            labelFbName.text = "Meno: " + nameFb
        }
        if let mailFb = defaults.valueForKey(facebookMail) as? String{
            labelFbMail.text = "Mail: " + mailFb
        }
        if let nameFb =  defaults.valueForKey(facebookName) as? String{
            labelFbName.text = "Meno: " + nameFb
        }
        if let url = defaults.valueForKey(facebookUrlPicture) as? String{
            if let url = NSURL(string: url) {
                if let data = NSData(contentsOfURL: url){
                    imageProfil.contentMode = UIViewContentMode.ScaleAspectFit
                    imageProfil.image = UIImage(data: data)
                }
            }
        }
        if defaults.boolForKey(loggedNormal){
            if let login = defaults.valueForKey(userName) as? String{
                labelLogin.text = "Login: " + login
            }
        }
    }
    
    
    @IBAction func logOut(sender: AnyObject) {
        let alert = UIAlertController(title: "Log Out", message: "Naozaj sa chcete odhlásiť?", preferredStyle: UIAlertControllerStyle.Alert)
        let callActionHandler = { (action:UIAlertAction!) -> Void in
            if (FBSDKAccessToken.currentAccessToken() != nil)
            {
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
            }
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: self.loggedNormal)
            defaults.setObject(nil, forKey: self.facebookMail)
            defaults.setObject(nil, forKey: self.facebookName)
            defaults.setObject(nil, forKey: self.tweetName)
            defaults.setObject(nil, forKey: self.facebookUrlPicture)
            
            
            if let presentingViewController = self.presentingViewController {
                presentingViewController.dismissViewControllerAnimated(true, completion: nil)
                print("Dismisujem loged")
            } else {
                let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login")
                self.presentViewController(loginVC!, animated: true, completion: nil)
            }
        }
        alert.addAction(UIAlertAction(title: "Áno", style: UIAlertActionStyle.Default, handler: callActionHandler))
        alert.addAction(UIAlertAction(title: "Nie", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //-----------------------------------------############ VRAT SA SPAT ############----------------------------------------
    
    @IBAction func unwindNaLoged(segue: UIStoryboardSegue) {
        
    }
}

