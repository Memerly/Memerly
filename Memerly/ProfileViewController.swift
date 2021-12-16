//
//  ProfileViewController.swift
//  Memerly
//
//  Created by Archan Bhattarai on 11/12/21.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

	var currentUser = PFUser.current()!
	var posts = [PFObject]()
	let defaultProfilePic = UIImage(systemName: "person.fill")?.withTintColor(UIColor.systemGray3)
	let defaultBannerPic = UIImage(named: "Default Banner Image")
	let myRefreshControl = UIRefreshControl() // pull to refresh

	@IBOutlet weak var bannerPicImageView: UIImageView!
	@IBOutlet weak var profilePicImageView: UIImageView!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var bioTextView: UITextView!
	@IBOutlet weak var postsCollectionView: UICollectionView!

	override func viewDidLoad() {
		super.viewDidLoad()

			// Do any additional setup after loading the view.
			//forcing darkmode
		overrideUserInterfaceStyle = .dark

		postsCollectionView.delegate = self
		postsCollectionView.dataSource = self
		

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)

		let username = currentUser["username"]
		if username != nil {
			usernameLabel.text = username as? String
		} else {
			usernameLabel.text = "UsernameNotFound"
		}

		let bio = currentUser["bio"]
		if bio != nil {
			bioTextView.textColor = UIColor.label
			bioTextView.text = bio as? String
		} else {
			bioTextView.textColor = UIColor.systemGray
			bioTextView.text = "No Bio Set"
		}

		let profilePicFile = currentUser["profilePic"]
		if profilePicFile != nil {
			let img = profilePicFile as! PFFileObject
			if img.name == "defaultProfilePic.png" {
				profilePicImageView.image = defaultProfilePic
			} else {
				let urlString = img.url!
				let url = URL(string: urlString)!
				profilePicImageView.af.setImage(withURL: url)
			}
		}

		let bannerPic = currentUser["bannerPic"]
		if bannerPic != nil {
			let img = bannerPic as! PFFileObject
			if img.name == "defaultProfilePic.png" {
				bannerPicImageView.image = defaultBannerPic
			} else {
				let urlString = img.url!
				let url = URL(string: urlString)!
				//bannerPicImageView.af.setImage(withURL: url)
			}
		}

		profilePicImageView.layer.masksToBounds = false
		profilePicImageView.layer.cornerRadius = profilePicImageView.frame.height/2
		profilePicImageView.layer.borderWidth = 1
		profilePicImageView.layer.borderColor = UIColor.clear.cgColor
		profilePicImageView.clipsToBounds = true
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)

		let query = PFQuery(className:"Posts")
		query.whereKey("author", equalTo: currentUser)
		query.order(byDescending: "createdAt")
		query.findObjectsInBackground { (posts, error) in
			if posts != nil {
				self.posts = posts!
				self.postsCollectionView.reloadData()
			}
		}
	}


	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		posts.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = postsCollectionView.dequeueReusableCell(withReuseIdentifier: "postCollectionViewCell", for: indexPath) as! PostCollectionViewCell
        

		let post = posts[indexPath.row]

		let imageFile = post["image"] as! PFFileObject
		let urlString = imageFile.url!
		let url = URL(string: urlString)!

		cell.memeImageView.af.setImage(withURL: url)

		return cell
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
