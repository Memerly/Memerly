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
	let defaults = UserDefaults.standard
	let defaultProfilePic = UIImage(systemName: "person.fill")?.withTintColor(UIColor.systemGray3)
	let defaultBannerPic = UIImage(named: "Default Banner Image")

	@IBOutlet weak var bannerPicImageView: UIImageView!
	@IBOutlet weak var profilePicImageView: UIImageView!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var bioTextView: UITextView!
	@IBOutlet weak var clearProfilePicButton: UIButton!
	@IBOutlet weak var clearBannerPicButton: UIButton!
	@IBOutlet weak var rememberMeButton: CheckBoxButton!
	@IBOutlet weak var rememberMeLabel: UILabel!


	override func viewDidLoad() {
		super.viewDidLoad()

			// Do any additional setup after loading the view.
		self.addDoneButtonOnKeyboard()
			//forcing darkmode
		overrideUserInterfaceStyle = .dark

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
			if img.name.contains("defaultProfilePic.png") {
				profilePicImageView.image = defaultProfilePic
				clearProfilePicButton.isHidden = true
			} else {
				let urlString = img.url!
				let url = URL(string: urlString)!
				profilePicImageView.af.setImage(withURL: url)
				clearProfilePicButton.isHidden = false
			}
		}
		if profilePicFile == nil {
			clearProfilePicButton.isHidden = true
		}

		let bannerPic = currentUser["bannerPic"]
		if bannerPic != nil {
			let img = bannerPic as! PFFileObject
			if img.name.contains("defaultBannerPic.png") {
				bannerPicImageView.image = defaultBannerPic
				clearBannerPicButton.isHidden = true
			} else {
				let urlString = img.url!
				let url = URL(string: urlString)!
				bannerPicImageView.af.setImage(withURL: url)
				clearBannerPicButton.isHidden = false
			}
		}
		if bannerPic == nil || bannerPicImageView.image == defaultBannerPic {
			clearBannerPicButton.isHidden = true
		}

		let rememberMe = defaults.bool(forKey: "rememberMe")
		rememberMeButton.isChecked = rememberMe
		if rememberMe {
			rememberMeLabel.alpha = 1
			rememberMeButton.alpha = 1
		} else {
			rememberMeLabel.alpha = 0.5
			rememberMeButton.alpha = 0.5
		}

		profilePicImageView.layer.masksToBounds = false
		profilePicImageView.layer.cornerRadius = profilePicImageView.frame.height/2
		profilePicImageView.layer.borderWidth = 1
		profilePicImageView.layer.borderColor = UIColor.clear.cgColor
		profilePicImageView.clipsToBounds = true
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
		if profilePicImageView.image != defaultProfilePic {
			profilePicImageView.image = defaultProfilePic
			profilePicImageView.tintColor = UIColor.systemGray3
			profilePicImageView.contentMode = .scaleAspectFit
			clearProfilePicButton.isHidden = true
		} else {
			clearProfilePicButton.isHidden = false
		}
	}
	
	@IBAction func onClearBannerPicButton(_ sender: Any) {
		if bannerPicImageView.image != defaultBannerPic {
			bannerPicImageView.image = defaultBannerPic
			clearBannerPicButton.isHidden = true
		} else {
			clearBannerPicButton.isHidden = false
		}
	}

	@IBAction func onDoneButton(_ sender: Any)  {
		currentUser["bio"] = bioTextView.text

		if profilePicImageView.image != defaultProfilePic {
			let imageData = profilePicImageView.image!.pngData()
			let file = PFFileObject(name: "profilePic.png", data: imageData!)
			currentUser["profilePic"] = file
		} else if profilePicImageView.image == defaultProfilePic {
			let imageData = defaultProfilePic!.pngData()
			let file = PFFileObject(name: "defaultProfilePic.png", data: imageData!)
			currentUser["profilePic"] = file
		}
		if bannerPicImageView.image != defaultBannerPic {
			let imageData = bannerPicImageView.image!.pngData()
			let file = PFFileObject(name: "bannerPic.png", data: imageData!)
			currentUser["bannerPic"] = file
		} else if bannerPicImageView.image == defaultBannerPic {
			let imageData = defaultBannerPic!.pngData()
			let file = PFFileObject(name: "defaultBannerPic.png", data: imageData!)
			currentUser["bannerPic"] = file
		}
		do {
			let results: () = try currentUser.save()
			print(results)
		} catch {
			print(error)
		}
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

		bioTextView.inputAccessoryView = doneToolbar
	}

	@objc func doneButtonAction(){
		bioTextView.resignFirstResponder()
	}

	@IBAction func editBio(_ sender: Any) {
		bioTextView.becomeFirstResponder()
	}

	@IBAction func onRememberMeButton(_ sender: CheckBoxButton) {
		if rememberMeButton.isChecked {
			rememberMeLabel.alpha = 0.5
			print("dont remember")
			defaults.set(false, forKey: "rememberMe")
		} else if !rememberMeButton.isChecked {
			rememberMeLabel.alpha = 1
			print("remember")
			defaults.set(true, forKey: "rememberMe")
		}
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

