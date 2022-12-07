//
//  DocumentTableViewCell.swift
//  oa-wallet-ios
//
//  Created by Tan Cher Shen on 7/12/22.
//

import UIKit

class DocumentTableViewCell: UITableViewCell {
    @IBOutlet weak var filenameLabel: UILabel!
    var onOptionsTapped : (()->())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func optionsTapped(_ sender: Any) {
        onOptionsTapped?()
    }
}
