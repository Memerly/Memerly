//
//  MemeViewController.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/12/21.
//

import UIKit
import Alamofire
import Parse

protocol MemeViewControllerDelegate: AnyObject {

	func MemeViewControllerDidCancel(_ memeViewController: MemeViewController)
	func MemeViewControllerDidFinish(_ memeViewController: MemeViewController)
}


class MemeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UIAdaptivePresentationControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	let username = "Memerly"
	let password = "November21!"
	let defaultImage = UIImage(systemName: "photo.artframe")?.withTintColor(UIColor.darkGray)
	var photoURL = URL(string: "")

	var memes = [Meme]()
	var selectedMeme = Meme()

	weak var delegate: MemeViewControllerDelegate?
	var memePickerView = UIPickerView()

	@IBOutlet weak var choosePhotoButton: UIButton!
	@IBOutlet var cameraTapRecognizer: UITapGestureRecognizer!
	@IBOutlet weak var memeImageView: UIImageView!
	@IBOutlet weak var textBoxTableView: UITableView!
    @IBOutlet weak var memePickerButton: UIButton!
    @IBOutlet weak var addCaptionTextField: UITextField!
    
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 2
    var selectedRow = 0
    
	override func viewDidLoad() {
		super.viewDidLoad()
		memePickerView.delegate = self
		textBoxTableView.delegate = self
		memePickerView.dataSource = self
		textBoxTableView.dataSource = self
		//isModalInPresentation = true
		overrideUserInterfaceStyle = .dark
		self.addDoneButtonOnKeyboard()

		getMemes()

        // Do any additional setup after loading the view.
	   // call the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
		NotificationCenter.default.addObserver(self, selector: #selector(MemeViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

			// call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
		NotificationCenter.default.addObserver(self, selector: #selector(MemeViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
	@objc func keyboardWillShow(notification: NSNotification) {

		guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
				// if keyboard size is not available for some reason, dont do anything
			return
		}

			// move the root view up by the distance of keyboard height
		self.view.frame.origin.y = 0 - keyboardSize.height
	}

	@objc func keyboardWillHide(notification: NSNotification) {
			// move back the root view origin to zero
		self.view.frame.origin.y = 0
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//		let meme = memes[0]
		let urlString = selectedMeme.url
		let url = URL(string: urlString)!

		memeImageView.af.setImage(withURL: url)
	}

	func getMemes() {
		let request = AF.request("https://api.imgflip.com/get_memes")
		request.responseDecodable(of: Memes.self) { response in
			switch response.result {
				case .success(let data):
					self.memes = data.data.values.first!
					self.memes.insert(Meme(), at: 0)
					self.selectedMeme = self.memes[0]
					print(self.memes[0].name)
					self.memePickerView.reloadAllComponents()
					self.textBoxTableView.reloadData()

				case .failure(let error):
					print(error)
			}
		}
	}
	@IBAction func onCameraButton(_ sender: Any) {
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
		photoURL = saveImage(image, name: "temp.jpg")

			//		let imgURL = info[.imageURL] as! URL
			//		photoURL = imgURL

		let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageAspectScaled(toFit: size)

		memeImageView.image = scaledImage
			//		clearButton.isHidden = false
			//		postButton.isHidden = false
		dismiss(animated: true, completion: nil)
	}

	
    @IBAction func memePickerButton(_ sender: UIButton) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        vc.overrideUserInterfaceStyle = .dark
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height:screenHeight))
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
                
        let alert = UIAlertController(title: "Pick a meme...", message: "", preferredStyle: .actionSheet)
                
        alert.popoverPresentationController?.sourceView = memePickerButton
        alert.popoverPresentationController?.sourceRect = memePickerButton.bounds
        
        alert.overrideUserInterfaceStyle = .dark
                
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
        }))
                
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { (UIAlertAction) in
            self.selectedRow = pickerView.selectedRow(inComponent: 0)
            //self.selectedRowTextColor = pickerView.selectedRow(inComponent: 1)
            let selected = self.selectedMeme
            //let selectedTextColor = Array(self.backGroundColours)[self.selectedRowTextColor]
            let name = selected.name
            //self.memPickerButton.setTitle(name, for: .normal)
            //self.pickerViewButton.setTitleColor(selectedTextColor.value, for: .normal)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
		1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		memes.count
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		let meme = memes[row]
		return meme.name
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		selectedMeme = memes[row]
		let urlString = selectedMeme.url
		if urlString != "custom" {
			let url = URL(string: urlString)!

			photoURL = URL(string: "")
			cameraTapRecognizer.isEnabled = false
			choosePhotoButton.isHidden = true
			memeImageView.isUserInteractionEnabled = false
			memeImageView.af.setImage(withURL: url)
		} else {
			photoURL = URL(string: "")
			cameraTapRecognizer.isEnabled = true
			memeImageView.isUserInteractionEnabled = true
			choosePhotoButton.isHidden = false
			memeImageView.image = defaultImage
		}
		textBoxTableView.reloadData()
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		selectedMeme.box_count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = textBoxTableView.dequeueReusableCell(withIdentifier: "textBox") as! TextBoxTableViewCell

		cell.textBoxTextField.placeholder = "Text Box \(indexPath.row + 1)"
		cell.textBoxTextField.tag = indexPath.row + 1
		cell.addDoneButtonOnKeyboard()

		return cell
	}
    
    @IBAction func onCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
	@IBAction func onPreviewButton(_ sender: Any) {
		let template_id = selectedMeme.id

		if template_id != "custom" {
			let username = username
			let password = password
			var boxes = [[String : String]]()

			for i in 1...selectedMeme.box_count {
				if let textField = self.textBoxTableView.viewWithTag(i) as? UITextField {
	//				let textBox = Box.init(text: textField.text!)
					boxes.append(["text" : textField.text!])
				}
			}

			let params = [
				"template_id" : template_id,
				"username" : username,
				"password" : password,
				"boxes" : boxes
			] as [String : Any]

			let request = AF.request("https://api.imgflip.com/caption_image", method: .post, parameters: params)
			request.responseDecodable(of: APIMemes.self) { response in
				switch response.result {
					case .success(let data):
						let meme = data.data
						let urlString = meme.url
						let url = URL(string: urlString)!

						self.memeImageView.af.setImage(withURL: url)
					case .failure(let error):
						print(error)
				}
			}
		} else {
			let headers: HTTPHeaders = [
				"API-KEY" : "b2c6273b612f9c7cf771fcd780404a"
			]
			var topText = ""
			var bottomText = ""

			for i in 1...selectedMeme.box_count {
				if let textField = self.textBoxTableView.viewWithTag(i) as? UITextField {
					if i == 1 {
						topText = textField.text!
					}
					if i == 2 {
						bottomText = textField.text!
					}
				}
			}
			if photoURL != nil {
				let request = AF.upload(multipartFormData: { multipartFormData in
					multipartFormData.append(Data(topText.utf8), withName: "topText")
					multipartFormData.append(Data(bottomText.utf8), withName: "bottomText")
					multipartFormData.append(self.photoURL!, withName: "image")
				} , to: "https://memebuild.com/api/1.0/generateMeme", method: .post, headers: headers)
				request.responseDecodable(of: CustomAPIMeme.self) { response in
					debugPrint(response)
					switch response.result {
						case .success(let data):
							let urlString = data.url
							let url = URL(string: urlString)!

							self.memeImageView.af.setImage(withURL: url)
							print(data)
						case .failure(let error):
							print(error)
					}
				}
			}
		}
	}
	@IBAction func onPostButton(_ sender: Any) {
        let size = CGSize(width: 300, height: 300)
        let scaledImage = memeImageView.image?.af.imageAspectScaled(toFit: size)
        if memeImageView.image != UIImage(systemName: "photo.artframe") {
           let post = PFObject(className: "Posts")

           post["caption"] = addCaptionTextField.text!
           post["author"] = PFUser.current()!
            post["comments"] = []
            post["commentCount"] = 0
            post["commentedBy"] = []
            post["likedCount"] = 0
            post["likedBy"] = []

           let imageData = scaledImage!.pngData()
           let file = PFFileObject(name: "image.png", data: imageData!)

           post["image"] = file

           post.saveInBackground { (success,error) in
              if(success) {
                  self.dismiss(animated: true) {
                      print("saved!")
                  }
                 
              }
              else {
                 print("error!")
              }
           }
        }
		delegate?.MemeViewControllerDidFinish(self)

	}

	func saveImage(_ image: UIImage, name: String) -> URL? {
		guard let imageData = image.jpegData(compressionQuality: 0.1) else {
			return nil
		}
		do {
			let imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
			try imageData.write(to: imageURL)
			return imageURL
		} catch {
			return nil
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

		//addCaptionTextField.inputAccessoryView = doneToolbar
	}

	@objc func doneButtonAction(){
		addCaptionTextField.resignFirstResponder()
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
extension UIImage {
		/// Save PNG in the Documents directory
	func save(_ name: String) {
		let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
		let url = URL(fileURLWithPath: path).appendingPathComponent(name)
		try! self.pngData()?.write(to: url)
		print("saved image at \(url)")
	}
}
