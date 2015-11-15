//
//  HubbleImageViewController.swift
//  CollectionViewDemo
//
//  Created by Lubos Ilcik on 01/11/15.
//  Copyright © 2015 Touch4IT. All rights reserved.
//

import UIKit

class HubbleImageViewController: UIViewController {

    var image: UIImage?
    var imageTitle: String? {
        didSet{
            navigationTitle.title = imageTitle
            
        }
    }

    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = image
        }
    }

}
