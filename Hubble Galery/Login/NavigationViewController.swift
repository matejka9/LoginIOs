//
//  NavigationViewController.swift
//  Login
//
//  Created by Dusan Matejka on 11/15/15.
//  Copyright © 2015 Dusan Matejka. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindNaNavigation(segue: UIStoryboardSegue) {
        performSegueWithIdentifier("unwind", sender: self)
    }

}
