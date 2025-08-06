//
//  DropDownCell.swift
//  SendsaySDK
//
//  Created by Stas ProSky on 30.07.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import UIKit
import SendsaySDK
import DropDown

class MyCell: DropDownCell {

    @IBOutlet var myImageView: UIImageView!
    @IBOutlet var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        myImageView.contentMode = .scaleAspectFit
//        label.tintColor = .colorAccent
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
