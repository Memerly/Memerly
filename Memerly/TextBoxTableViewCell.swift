//
//  TextBoxTableViewCell.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/13/21.
//

import UIKit

class TextBoxTableViewCell: UITableViewCell {

	
	@IBOutlet weak var textBoxTextField: UITextField!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
