//
//  recipe.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 11/9/16.
//  Copyright © 2016 Ahmed Moussa. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class recipe {
    var creatorPP = UIImage(named: "plus.jpg")
    var picures = [UIImage]()
    var recie = DBRecipe()
    
    init(id: String, name: String, insts: String, desc: String, temp: NSNumber, dur: NSNumber, creatorFBID: String, creatorName: String, numOfPics: Int){
        recie?._id = id
        recie?._name = name
        recie?._instructions = insts
        recie?._description = desc
        recie?._temperature = temp
        recie?._duration = dur
        recie?._creatorFBID = creatorFBID
        recie?._creatorName = creatorName
        recie?._numberOfPictures = numOfPics as NSNumber
    }
    init(recip: DBRecipe){
        recie = recip
    }
    
    
}
