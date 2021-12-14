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

	    if defaults.bool(forKey: "rememberMe") == true {
		    self.performSegue(withIdentifier: "loginSegue", sender: nil)

	    }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
