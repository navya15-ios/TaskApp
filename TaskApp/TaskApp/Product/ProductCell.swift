//
//  ProductCell.swift
//  TaskApp
//
//  Created by Navya Srujana on 05/01/21.
//

import UIKit

class ProductCell: UITableViewCell {

    @IBOutlet weak var titleLBLOutlet: UILabel!
    @IBOutlet weak var descriptionLBLOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
