//
//  LoginViewController.swift
//  Memerly
//
//  Created by Archan Bhattarai on 11/12/21.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
	let defaults = UserDefaults.standard

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
	@IBOutlet weak var rememberMeButton: CheckBoxButton!
	@IBOutlet weak var rememberMeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        //forcing darkmode
        overrideUserInterfaceStyle = .dark
	    self.navigationController?.setNavigationBarHidden(true, animated: false)
	    self.navigationController?.setToolbarHidden(true, animated: true)
	    self.addDoneButtonOnKeyboard()

	    if defaults.bool(forKey: "rememberMe") == true {
		    self.performSegue(withIdentifier: "loginSegue", sender: nil)

	    }
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
		self.view.frame.origin.y = 200 - keyboardSize.height
	}

	@objc func keyboardWillHide(notification: NSNotification) {
			// move back the root view origin to zero
		self.view.frame.origin.y = 0
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)

	}
	
    
    //Action when Login button is tapped
    @IBAction func onLogin(_ sender: Any) {
        let username = userNameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil {
			  self.defaults.set(user?.objectId, forKey: "currentUser")
			  self.defaults.set(true, forKey: "rememberMe")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
			  print("Error: \(String(describing: error?.localizedDescription))")
            }
            
        }
    }
    
    //Action when signup button is tapped
    @IBAction func onSignup(_ sender: Any) {
        
    }
    
	@IBAction func onRememberMeButton(_ sender: CheckBoxButton) {
		if rememberMeButton.isChecked {
			rememberMeLabel.alpha = 0.5
			print("dont remember")
			defaults.set(false, forKey: "rememberMe")
		} else if !rememberMeButton.isChecked {
			rememberMeLabel.alpha = 1
			print("remember")
		}
	}

	func addDoneButtonOnKeyboard() {
		let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
		doneToolbar.barStyle = .default

		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

		let items = [flexSpace, done]
		doneToolbar.items = items
		doneToolbar.sizeToFit()


		userNameField.inputAccessoryView = doneToolbar
		passwordField.inputAccessoryView = doneToolbar

	}

	@objc func doneButtonAction(){
		userNameField.resignFirstResponder()
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
