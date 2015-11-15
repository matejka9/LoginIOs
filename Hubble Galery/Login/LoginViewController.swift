//
//  LoginViewController.swift
//  Login
//
//  Created by Dusan Matejka on 10/16/15.
//  Copyright © 2015 Dusan Matejka. All rights reserved.
//

import UIKit
import CoreData
import FBSDKLoginKit
import TwitterKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    let userName = "login"
    
    var poslanyLogin = String()
    var poslaneHeslo = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        login.text = poslanyLogin
        heslo.text = poslaneHeslo
        
        
        //FB Button
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginView)
        let bounds = self.view.bounds
        loginView.frame = CGRectMake(bounds.maxX, bounds.maxY - loginView.bounds.height, bounds.maxX/2 - 20.0, loginView.frame.height)
        loginView.center = CGPointMake(bounds.midX - bounds.maxX/4, bounds.maxY - loginView.bounds.height)
        loginView.readPermissions = ["public_profile", "email"]
        loginView.delegate = self
        
    
        
        
        //Twitter login button
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(session!.userName, forKey: "tweetName")
        
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier("pouziTweetLogin", sender: self)
                })
            } else {
                print("error: \(error!.localizedDescription)");
            }
        })
        
        let view = logInButton.subviews.last
        let label = view!.subviews.first as! UILabel
        label.text = "Log in"
        logInButton.frame = CGRectMake(bounds.maxX, bounds.maxY + loginView.bounds.height, bounds.maxX/2 - 20.0, loginView.frame.height)
        logInButton.center = CGPointMake(bounds.midX + bounds.maxX/4, bounds.maxY - loginView.bounds.height)
        self.view.addSubview(logInButton)
    }

    
    //FB
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name, email, picture"])
                
                graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    
                    if ((error) != nil)
                    {
                        // Process error
                        print("Error: \(error)")
                    }
                    else
                    {
                        let facebookMail = result.valueForKey("email") as! String
                        let facebookName = result.valueForKey("name") as! String
                        let urlObrazok = result.valueForKey("picture")?.valueForKey("data")?.valueForKey("url") as! String
                        
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setObject(facebookMail, forKey: "facebookMail")
                        defaults.setObject(facebookName, forKey: "facebookName")
                        defaults.setObject(urlObrazok, forKey: "facebookPictureUrl")
                        
                        
                        self.performSegueWithIdentifier("pouziFbLogin", sender: self)
                    }
                })
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var heslo: UITextField!
    
    //-----------------------------------------############ POSLI DATA ############----------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "pouziLogin"){
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(self.login.text!, forKey: "login")
        }
    }
    
    //-----------------------------------------############ Prihlasovanie ############----------------------------------------
    @IBAction func logIn(sender: UIButton) {
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Users")
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "login = %@ AND password = %@", login.text!, heslo.text!)
        
        do{
            let results: NSArray = try context.executeFetchRequest(request)
            
            if (results.count > 0){
                //Ulozim si uzivatela
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(login.text, forKey: userName)
                
                self.performSegueWithIdentifier("pouziLogin", sender: self)
            }else{
                let alert = UIAlertController(title: "Error", message: "Meno a heslo nesedia.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Späť", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)           }
        }catch{
            print(error)
        }
    }
    
    //-----------------------------------------############ END EDITING ############----------------------------------------
    @IBAction func skriKlavesnicu(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //-----------------------------------------############ VRAT SA SPAT ############----------------------------------------
    
    @IBAction func unwindNaLogIn(segue: UIStoryboardSegue) {
        
    }
}
