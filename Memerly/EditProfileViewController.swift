	//
	//  ProfileViewController.swift
	//  Memerly
	//
	//  Created by Archan Bhattarai on 11/12/21.
	//

import UIKit
import AlamofireImage
import Parse

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	weak var activeImageView:UIImageView? = nil
	var currentUser = PFUser.current()!
	var posts = [PFObject]()

	@IBOutlet weak var bannerPicImageView: UIImageView!
	@IBOutlet weak var profilePicImageView: UIImageView!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var bioTextView: UITextView!
	@IBOutlet weak var clearProfilePicButton: UIButton!
	@IBOutlet weak var clearBannerPicButton: UIButton!



	override func viewDidLoad() {
		super.viewDidLoad()

			// Do any additional setup after loading the view.
		self.addDoneButtonOnKeyboard()
			//forcing darkmode
		overrideUserInterfaceStyle = .dark

		let username = currentUser["username"]
		if username != nil {
			usernameLabel.textColor = UIColor.label
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
			let urlString = img.url!
			let url = URL(string: urlString)!
			profilePicImageView.af.setImage(withURL: url)
		}

		let bannerPic = currentUser["bannerPic"]
		if bannerPic != nil {
			let img = bannerPic as! PFFileObject
			let urlString = img.url!
			let url = URL(string: urlString)!
			bannerPicImageView.af.setImage(withURL: url)
		}

	}

	@IBAction func editProfilePic(_ sender: UIButton) {
		if sender.tag == 0 {
			activeImageView = profilePicImageView
		} else if sender.tag == 1 {
			activeImageView = bannerPicImageView
		}
		let picker = UIImagePickerController()
		picker.delegate = self
		picker.allowsEditing = true

		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			picker.sourceType = .camera
		}
		else {
			picker.sourceType = .photoLibrary
		}

		present(picker, animated: true, completion: nil)
	}


	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		let image = info[.editedImage] as! UIImage
		if activeImageView == profilePicImageView {
			let size = CGSize(width: 125, height: 125)
			let scaledImage = image.af.imageAspectScaled(toFill: size)
			activeImageView?.image = scaledImage
			clearProfilePicButton.isHidden = false
		} else if activeImageView == bannerPicImageView {
			let size = CGSize(width: 414, height: 211)
			let scaledImage = image.af.imageAspectScaled(toFill: size)
			activeImageView?.image = scaledImage
		}



		dismiss(animated: true, completion: nil)
	}

	@IBAction func onClearProfilePicButton(_ sender: Any) {
		if profilePicImageView.image != UIImage(systemName: "person.fill") {
			profilePicImageView.image = UIImage(systemName: "person.fill")
			profilePicImageView.tintColor = UIColor.systemGray3
			profilePicImageView.contentMode = .scaleAspectFit
			clearProfilePicButton.isHidden = true
		} else {
			clearProfilePicButton.isHidden = false
		}
	}
	
	@IBAction func onClearBannerPicButton(_ sender: Any) {
		if bannerPicImageView.image != UIImage(named: "Default Banner Image") {
			bannerPicImageView.image = UIImage(named: "Default Banner Image")
			clearBannerPicButton.isHidden = true
		} else {
			clearBannerPicButton.isHidden = false
		}
	}

	@IBAction func onDoneButton(_ sender: Any)  {
		currentUser["bio"] = bioTextView.text

		if profilePicImageView.image != UIImage(systemName: "person.fill") {
			let imageData = profilePicImageView.image!.pngData()
			let file = PFFileObject(name: "profilePic.png", data: imageData!)

			currentUser["profilePic"] = file
		}
		if bannerPicImageView.image != UIImage(named: "Default Banner Image") {
			let imageData = bannerPicImageView.image!.pngData()
			let file = PFFileObject(name: "bannerPic.png", data: imageData!)

			currentUser["bannerPic"] = file
		}
		do {
			let results: () = try currentUser.save()
			print(results)
		} catch {
			print(error)
		}
	}


	func addDoneButtonOnKeyboard(){
		let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
		doneToolbar.barStyle = .default

		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

		let items = [flexSpace, done]
		doneToolbar.items = items
		doneToolbar.sizeToFit()

		bioTextView.inputAccessoryView = doneToolbar
	}

	@objc func doneButtonAction(){
		bioTextView.resignFirstResponder()
	}

	@IBAction func editBio(_ sender: Any) {
		bioTextView.becomeFirstResponder()
	}


	 // MARK: - Navigation
//	 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		 // Get the new view controller using segue.destination.
//		 // Pass the selected object to the new view controller.
//		 if let vc = segue.destination as? ProfileViewController {
//			 vc.bioTextView.text = bioTextView.text
//			 vc.profilePicImageView.image = profilePicImageView.image
//			 vc.bannerPicImageView.image = bannerPicImageView.image
//		 }
//	 }

}

