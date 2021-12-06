//
//  CheckBoxButton.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/5/21.
//

import UIKit

class CheckBoxButton: UIButton {
		// Images
	let checkedImage = UIImage(systemName: "checkmark.square.fill")! as UIImage
	let uncheckedImage = UIImage(systemName: "checkmark.square")! as UIImage

		// Bool property
	var isChecked: Bool = false {
		didSet {
			if isChecked == true {
				self.setImage(checkedImage, for: UIControl.State.normal)
				self.alpha = 1
			} else {
				self.setImage(uncheckedImage, for: UIControl.State.normal)
				self.alpha = 0.5
			}
		}
	}

	override func awakeFromNib() {
		self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
		self.isChecked = false
	}

	@objc func buttonClicked(sender: UIButton) {
		if sender == self {
			isChecked = !isChecked
		}
	}

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
