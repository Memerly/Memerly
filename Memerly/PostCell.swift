//
//  PostCell.swift
//  Memerly
//
//  Created by Archan Bhattarai on 11/20/21.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var memeView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
	@IBOutlet weak var profilePicImageView: UIImageView!
	@IBOutlet weak var usernameButton: UIButton!
	@IBOutlet weak var likeCountLabel: UILabel!
	@IBOutlet weak var commentCountLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state

    }
	@IBAction func onLikeButton(_ sender: UIButton) {
		let count = Int(self.likeCountLabel.text!) ?? 0
		if sender.currentImage == UIImage(systemName: "heart.fill") {
			if count - 1 != 0 {
				self.likeCountLabel.text = "\(count - 1)"
			} else if count - 1 <= 0 {
				self.likeCountLabel.text = ""
			}

		} else if sender.currentImage == UIImage(systemName: "heart") {
			self.likeCountLabel.text = "\(count + 1)"
		}
	}
}
