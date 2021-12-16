//
//  SignupViewController.swift
//  Memerly
//
//  Created by Archan Bhattarai on 11/12/21.
//

import UIKit
import Parse

class SignupViewController: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var profileImangeView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
	    self.addDoneButtonOnKeyboard()

        //forcing darkmode
        overrideUserInterfaceStyle = .dark
        
        profileImangeView.layer.cornerRadius = profileImangeView.frame.size.width / 2
		    // call the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
	    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

		    // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
	    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
	@objc func keyboardWillShow(notification: NSNotification) {

		guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
				// if keyboard size is not available for some reason, dont do anything
			return
		}

			// move the root view up by the distance of keyboard height
		self.view.frame.origin.y = 250 - keyboardSize.height
	}

	@objc func keyboardWillHide(notification: NSNotification) {
			// move back the root view origin to zero
		self.view.frame.origin.y = 0
	}
    
    //Action when signup button is tapped
    @IBAction func onSignup(_ sender: Any) {
        let user = PFUser()
        user["fName"] = firstNameField.text
        user["lName"] = lastNameField.text
        user.username = usernameField.text
        user.password = passwordField.text
        
        user.signUpInBackground { (success, error) in
            if success {
                self.performSegue(withIdentifier: "loginOnSignup", sender: nil)
            } else {
			  print("Error: \(String(describing: error?.localizedDescription))")
            }
            
        }
        
    }

	@IBAction func onSignInButton(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}

	func addDoneButtonOnKeyboard() {
		let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
		doneToolbar.barStyle = .default

		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

		let items = [flexSpace, done]
		doneToolbar.items = items
		doneToolbar.sizeToFit()

		firstNameField.inputAccessoryView = doneToolbar
		lastNameField.inputAccessoryView = doneToolbar
		usernameField.inputAccessoryView = doneToolbar
		passwordField.inputAccessoryView = doneToolbar

	}

	@objc func doneButtonAction(){
		firstNameField.resignFirstResponder()
		lastNameField.resignFirstResponder()
		usernameField.resignFirstResponder()
		passwordField.resignFirstResponder()
	}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
