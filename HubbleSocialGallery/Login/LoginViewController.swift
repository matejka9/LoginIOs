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
import Parse

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    let userName = "login"
    let userPassword = "password"
    let loggedNormal = "logedNormal"
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var constrainWelcomeX: NSLayoutConstraint!
    
    @IBOutlet weak var constrainWelcomeY: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let name = defaults.stringForKey(self.userName)
        let pass = defaults.stringForKey(self.userPassword)
        
        if (name != nil && pass != nil){
            login.text = name
            heslo.text = pass
        }
        
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
                    if let presentingViewController = self.presentingViewController as? LogedViewController {
                        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Loged")
                        self.presentViewController(loginVC!, animated: true, completion: nil)
                    }
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        UIView.animateWithDuration(1.0, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.CurveEaseOut, .TransitionCurlUp], animations: {
            
            self.constrainWelcomeX.constant -= self.view.bounds.width
            self.welcomeLabel.transform = CGAffineTransformMakeScale(0.5, 0.5)
            self.view.layoutIfNeeded()
            
            }) { _ in
                
                UIView.transitionWithView(self.welcomeLabel, duration: 0.5, options: [.CurveEaseOut, .TransitionCurlDown], animations: {
                self.welcomeLabel.hidden = false
                self.welcomeLabel.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.constrainWelcomeX.constant += self.view.bounds.width
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        
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
                        
                        
                        if let presentingViewController = self.presentingViewController as? LogedViewController {
                            presentingViewController.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarCont")
                            self.presentViewController(loginVC!, animated: true, completion: nil)
                        }
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
        }
    }
    
    //-----------------------------------------############ Prihlasovanie ############----------------------------------------
    @IBAction func logIn(sender: UIButton) {
        
        PFUser.logInWithUsernameInBackground(self.login.text!, password:self.heslo.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                // Do stuff after successful login.
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(self.login.text, forKey: self.userName)
                defaults.setObject(self.heslo.text, forKey: self.userPassword)
                defaults.setBool(true, forKey: self.loggedNormal)
                
                if let presentingViewController = self.presentingViewController as? LogedViewController {
                    presentingViewController.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarCont")
                    self.presentViewController(loginVC!, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Meno a heslo nesedia.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Späť", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signUp(sender: AnyObject) {
        if let presentingViewController = self.presentingViewController as? ViewController {
            presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        } else {
            let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Register")
            self.presentViewController(loginVC!, animated: true, completion: nil)
        }
    }
    //-----------------------------------------############ END EDITING ############----------------------------------------
    @IBAction func skriKlavesnicu(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    /*//-----------------------------------------############ VRAT SA SPAT ############----------------------------------------
    
    @IBAction func unwindNaLogIn(segue: UIStoryboardSegue) {
        
    }*/
}
