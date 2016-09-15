//
//  ItemTableViewCell.swift
//  ApplePayDemo
//
//  Created by Alec Paulson on 8/23/16.
//  Copyright © 2016 Vantiv. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
