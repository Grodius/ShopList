//
//  CustomCell.swift
//  ShopList
//
//  Created by Josh Hunziker on 11/18/16.
//  Copyright © 2016 Josh Hunziker. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellName: UILabel!
    @IBOutlet weak var cellQuantity: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.cellImage.layer.cornerRadius = self.cellImage.frame.size.width / 2
        self.cellImage.clipsToBounds = true;
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
