//
//  AppDelegate.swift
//  Login
//
//  Created by Dusan Matejka on 10/16/15.
//  Copyright © 2015 Dusan Matejka. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import Fabric
import TwitterKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let userName = "login"
    let userPassword = "password"
    let loggedNormal = "logedNormal"
    let tweetName = "tweetName"
    
    var window: UIWindow?
    var notification: UILocalNotification?
    var somBackground: Bool?

    // ================================================= FACEBOOK DOPLNENE ====================================================
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Scroll bar pre input text
        IQKeyboardManager.sharedManager().enable = true
        Fabric.with([Twitter.self])
        
        Parse.setApplicationId("SyRQxmvs6dAajREWbACWY9e1y1L9uX07qwE92Zo1", clientKey: "Q9itfo4yGvA3UXisXYBkS1zf147eHTMAo1eEhiXV")
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        var initialVC: UIViewController
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let tweetName = defaults.stringForKey(self.tweetName)
        if (FBSDKAccessToken.currentAccessToken() != nil || defaults.boolForKey(loggedNormal) || tweetName != nil){
            initialVC = storyBoard.instantiateViewControllerWithIdentifier("TabBarCont")
        }else if (defaults.stringForKey(userName) != nil){
            initialVC = storyBoard.instantiateViewControllerWithIdentifier("Login")
        }else{
            initialVC = storyBoard.instantiateViewControllerWithIdentifier("Register")
        }
        
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()
        
        // registering
        somBackground = false
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        
        // handling
        if let localNotification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            print("didFinishLaunchingWithOptions: \(localNotification)")
            notification = localNotification
        }
        
        return true
    }
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
    
    // ================================================= FACEBOOK DOPLNENE ====================================================
    

    func applicationWillResignActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.valueForKey(tweetName) != nil || FBSDKAccessToken.currentAccessToken() != nil || defaults.boolForKey(loggedNormal)){
            let notification:UILocalNotification = UILocalNotification()
            notification.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(60*60*24))
            notification.repeatInterval = NSCalendarUnit.Day
            notification.alertTitle = "Hubble Gallery"
            notification.alertBody = "Pozri si nové fotografie od našich prispievateľov v Hubble Gallery."
            notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = ["payload": "test payload"]
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        somBackground = true
    }

    func applicationWillEnterForeground(application: UIApplication) {
        let app = UIApplication.sharedApplication()
        for oneEvent in app.scheduledLocalNotifications! {
            let notification = oneEvent as UILocalNotification
            app.cancelLocalNotification(notification)
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        somBackground = false
    }

    func applicationWillTerminate(application: UIApplication) {
        self.saveContext()
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        print("didRegisterUserNotificationSettings: \(notificationSettings)")
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("didReceiveLocalNotification: \(notification)")
        
        application.applicationIconBadgeNumber = 0
        
        presentNotificationAlert(notification.alertTitle, message: notification.alertBody)
        
    }
    
    private func presentNotificationAlert(title: String?, message: String?) {
        if somBackground == true{
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Login", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

