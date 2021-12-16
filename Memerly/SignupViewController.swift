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

        //forcing darkmode
        overrideUserInterfaceStyle = .dark
        
        profileImangeView.layer.cornerRadius = profileImangeView.frame.size.width / 2
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
