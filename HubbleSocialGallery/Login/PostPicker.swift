//
//  ViewController.swift
//  ImagePickerDemo
//
//  Created by Lubos Ilcik on 25/03/15.
//  Copyright © 2015 Touch4IT. All rights reserved.
//

import UIKit
import Parse

class PostPicker: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imagePreview: UIImageView!
    
    @IBOutlet weak var activityIndikator: UIActivityIndicatorView!
    
    let imagePicker = UIImagePickerController()
    
    
    var imageFirst : UIImage?
    
    @IBAction func choosePhotoFromLibrary(sender: UIBarButtonItem) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.modalPresentationStyle = .Popover
        imagePicker.popoverPresentationController?.barButtonItem = sender
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }

    @IBAction func parsePhoto(sender: UIBarButtonItem) {
        if (self.imageFirst == self.imagePreview.image){
           self.showAlert()
        }else{
            let post = PFObject(className: "Post")
            post["userId"] = PFUser.currentUser()?.objectId!
            post["userName"] = PFUser.currentUser()?.username
            let imageData = UIImageJPEGRepresentation(imagePreview.image!, 0.0)
            let userId = PFUser.currentUser()!.objectId!
            let imageFile = PFFile(name: "\(userId).jpg", data: imageData!)
            post["imageFile"] = imageFile
            self.activityIndikator.hidden = false
            self.activityIndikator.startAnimating()
            self.view.userInteractionEnabled = false
            self.tabBarController?.tabBar.userInteractionEnabled = false
            //let qos = Int(QOS_CLASS_USER_INTERACTIVE.rawValue)
            post.saveInBackgroundWithBlock{(success, error) -> Void in
                //dispatch_async(dispatch_get_global_queue(qos, 0)) {
                    if (error != nil){
                        print("Chyba pri odosielani fotky")
                    }else{
                        print("Fotka bola uspesne odoslana")
                    }
                    self.activityIndikator.stopAnimating()
                    self.view.userInteractionEnabled = true
                    self.activityIndikator.hidden = true
                    self.tabBarController?.tabBar.userInteractionEnabled = true
                    self.imagePreview.image = self.imageFirst
               // }
            }
        }
        
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Chyba", message: "Musíte si najskôr zvoliť obrázok.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndikator.hidden = true
        imagePicker.delegate = self
        self.imageFirst = self.imagePreview.image
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagePreview.image = chosenImage
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

