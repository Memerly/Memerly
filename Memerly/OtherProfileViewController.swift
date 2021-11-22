//
//  OtherProfileViewController.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 11/21/21.
//

import UIKit
import Parse

class OtherProfileViewController: UIViewController {

	var user:PFUser = PFUser()

	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var profilePicImageView: UIImageView!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var bioLabel: UILabel!
	@IBOutlet weak var postsCollectionView: UICollectionView!
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
	    overrideUserInterfaceStyle = .dark
		
		usernameLabel?.text = user.username
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
