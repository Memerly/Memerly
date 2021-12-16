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
	func addDoneButtonOnKeyboard() {
		let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
		doneToolbar.barStyle = .default

		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

		let items = [flexSpace, done]
		doneToolbar.items = items
		doneToolbar.sizeToFit()

		textBoxTextField.inputAccessoryView = doneToolbar
	}

	@objc func doneButtonAction(){
		textBoxTextField.resignFirstResponder()
	}

}
