//
//  OtherProfileViewController.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 11/21/21.
//

import UIKit
import Parse

class OtherProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

	var posts = [PFObject]()
	var user:PFUser = PFUser()

	@IBOutlet weak var bannerImageView: UIImageView!
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

		let username = user.username
		if username != nil {
			usernameLabel.textColor = UIColor.label
			usernameLabel.text = username
		} else {
			usernameLabel.text = "UsernameNotFound"
		}

		let bio = user.object(forKey: "bio") as? String
		if bio != nil {
			bioTextView.textColor = UIColor.label
			bioTextView.text = bio
		} else {
			bioTextView.textColor = UIColor.systemGray
			bioTextView.text = "No Bio Set"
		}
		print("viewDidAppear")
		print(posts)
		posts = posts.filter { post in
			return post["author"] as! PFUser == user
		}

		if posts.count != 0 {
			self.postsCollectionView.reloadData()
		}
	}

	override func viewDidAppear(_ animated: Bool) {

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
