//
//  DDCell.swift
//  manageMyMoney
//
//  Created by kustar on 12/4/20.
//  Copyright © 2020 kustar. All rights reserved.
//

import UIKit
import DropDown

class DDCell: DropDownCell {

    @IBOutlet var myImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myImageView.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
