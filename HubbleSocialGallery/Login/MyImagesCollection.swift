//
//  MyImagesCollection.swift
//  Login
//
//  Created by Dusan Matejka on 12/6/15.
//  Copyright © 2015 Dusan Matejka. All rights reserved.
//

import UIKit
import Parse


class MyImagesCollection: UICollectionViewController {
    private let reuseIdentifier = "myImagesCell"
    private var imageGallery = HubbleGallery()
    
    @IBOutlet weak var gridView: UICollectionView!
    
    @IBOutlet weak var indikator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFQuery(className: "Post")
        query.whereKey("userId", equalTo: (PFUser.currentUser()?.objectId)!)
        indikator.startAnimating()
        query.findObjectsInBackgroundWithBlock() { (objects, error) in
            if (error == nil){
                var pocet = 0
                let koniec = objects?.count
                for object in objects!{
                    let imageFile = object["imageFile"] as! PFFile
                    imageFile.getDataInBackgroundWithBlock() { (data, error) in
                        if let image = UIImage(data: data!) {
                            self.imageGallery.images.append(Obrazok(imageTitle: "My Image", imageUIImage: image))
                        } else {
                            print("Error retrieving image")
                        }
                        if (++pocet == koniec){
                            self.indikator.stopAnimating()
                            self.indikator.hidden = true
                            self.gridView.reloadData()
                            print("Data bolo nacitane pocet: \(koniec)")
                        }
                    }
                }
            }else {
                print("Error fetching objects: \(error)")
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MyImagesCell
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.imageView.image = imageGallery.images[indexPath.row].imageUIImage!
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

extension MyImagesCollection: UICollectionViewDelegateFlowLayout{
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

