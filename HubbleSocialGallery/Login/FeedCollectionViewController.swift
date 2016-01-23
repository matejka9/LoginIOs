//
//  FeedCollectionViewController.swift
//  Login
//
//  Created by Dusan Matejka on 12/6/15.
//  Copyright © 2015 Dusan Matejka. All rights reserved.
//

import UIKit
import Parse

private let reuseIdentifier = "Cell"

class FeedCollectionViewController: UICollectionViewController {
    
    var imageGallery = HubbleGallery()
    var pole = FollowersData()
    var checked : [Bool] = []
    
    
    @IBOutlet var gridView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let qos = Int(QOS_CLASS_USER_INTERACTIVE.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
        
            let query = PFQuery(className: "Post")
        
            var followers = [AnyObject]()
            var index = 0
            for object in self.checked{
                if object == true{
                    followers.append(self.pole.uzivatelia[index].objectId!)
                }
                index++
            }
        
            query.whereKey("userId", containedIn: followers)
            query.findObjectsInBackgroundWithBlock() { (objects, error) in
                var pocet = 0
                let koniec = objects!.count
                if koniec == 0{
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                    self.showAlert()
                }
                for object in objects!{
                    let imageFile = object["imageFile"] as! PFFile
                    imageFile.getDataInBackgroundWithBlock() { (data, error) in
                        dispatch_async(dispatch_get_global_queue(qos, 0)) {
                            if let image = UIImage(data: data!) {
                                self.imageGallery.images.append(Obrazok(imageTitle: object["userName"] as! String, imageUIImage: image))
                            } else {
                                print("Error retrieving image")
                            }
                            if (++pocet == koniec){
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.hidden = true
                                self.gridView.reloadData()
                                print("Koniec : \(koniec))")
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Missing", message: "Vaši followery nepostli žiadne obrázky doposiaľ.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageGallery.images.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FeedCollectionViewCell
    
        cell.label.text = self.imageGallery.images[indexPath.row].imageTitle
        cell.image.image = self.imageGallery.images[indexPath.row].imageUIImage
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImage" {
            let imageVC = segue.destinationViewController as? HubbleImageViewController
            let cell = sender as! UICollectionViewCell
            if let indexPath = collectionView?.indexPathForCell(cell) {
                imageVC?.image = imageGallery.images[indexPath.row].imageUIImage
                imageVC?.imageTitle = imageGallery.images[indexPath.row].imageTitle
            }
        }
    }
}

extension FeedCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let image = imageGallery.images[indexPath.row].imageUIImage {
            let aspectRatio = image.size.height / image.size.width
            return CGSize(width: 200, height: 200 * aspectRatio)
        }
        return CGSize(width: 200, height: 200)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
}