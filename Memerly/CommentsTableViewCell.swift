//
//  CommentsTableViewCell.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/6/21.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {
	@IBOutlet weak var profilePicImageView: UIImageView!
	@IBOutlet weak var usernameButton: UIButton!
	@IBOutlet weak var commentLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
