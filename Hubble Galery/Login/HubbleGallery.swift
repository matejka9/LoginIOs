//
//  HubbleGallery.swift
//  CollectionViewDemo
//
//  Created by Lubos Ilcik on 01/11/15.
//  Copyright © 2015 Touch4IT. All rights reserved.
//

import UIKit

struct HubbleGallery {
    var images = Array<Obrazok>()
}

struct Obrazok {
    let imageTitle : String
    let imageUIImage : UIImage?
}