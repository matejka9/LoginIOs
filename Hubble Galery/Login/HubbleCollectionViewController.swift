//
//  HubbleCollectionViewController.swift
//  CollectionViewDemo
//
//  Created by Lubos Ilcik on 01/11/15.
//  Copyright © 2015 Touch4IT. All rights reserved.
//

import UIKit
import Parse

class HubbleCollectionViewController: UICollectionViewController {

    private let reuseIdentifier = "ImageCell"
    private var imageGallery = HubbleGallery()

    @IBOutlet weak var gridView: UICollectionView!
    
    @IBOutlet weak var indikator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let qos = Int(QOS_CLASS_USER_INTERACTIVE.rawValue)
            
        let query = PFQuery(className: "HubbleGallery")
        indikator.startAnimating()
        query.findObjectsInBackgroundWithBlock() { (objects, error) in
            dispatch_async(dispatch_get_global_queue(qos, 0)) {
                if error == nil {
                    // success
                    let pocetZaznamov = objects!.count
                    for _ in 0...pocetZaznamov - 1{
                        self.imageGallery.images.append(Obrazok(imageTitle: "", imageUIImage: nil))
                    }
                    var poradie = 0
                    for obj in objects! {
                        print("foo column: \(obj["title"])")
                        print("foo column: \(obj["imageURL"])")
                        let imageTitle = obj["title"] as! String
                        let imageURLString = obj["imageURL"] as! String
                    
                        dispatch_async(dispatch_get_global_queue(qos, 0)) {
                            if let imageURL = NSURL(string: imageURLString) {
                                if let imageData = NSData(contentsOfURL: imageURL) {
                                    self.imageGallery.images[poradie++] = Obrazok(imageTitle: imageTitle, imageUIImage: UIImage(data: imageData))
                                    print("image loaded")
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.indikator.stopAnimating()
                                        self.indikator.hidden = true
                                        self.gridView.reloadData()
                                
                                    }
                            
                                } else {
                                    print("failed to load image - data nil")
                                }
                            } else {
                                print("failed to load image - url nil")
                            }
                        }
                    }
                } else {
                    print("Error fetching objects: \(error)")
                }
            }
        }
        
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageGallery.images.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! HubbleCollectionViewCell
    
        // Configure the cell
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.imageView.image = imageGallery.images[indexPath.row].imageUIImage
        if cell.imageView.image != nil{
            cell.cellIndicator.hidden = true
            cell.cellIndicator.stopAnimating()
        }
        return cell
    }

    // MARK: - Navigation
    
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

extension HubbleCollectionViewController: UICollectionViewDelegateFlowLayout {

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













