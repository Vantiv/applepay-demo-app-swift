//
//  Item.swift
//  ApplePayDemo
//
//  Created by Alec Paulson on 8/23/16.
//  Copyright © 2016 Vantiv. All rights reserved.
//

import UIKit

class Item {
    //MARK: Properties
    var name: String
    var photo: UIImage?
    var price: NSDecimalNumber
    
    //MARK: Initialization
    init?(name: String, photo: UIImage?, price: NSDecimalNumber) {
        self.name = name
        self.photo = photo
        self.price = price
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty {
            return nil
        }
    }
}
