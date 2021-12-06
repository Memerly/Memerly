//
//  PostViewController.swift
//  Memerly
//
//  Created by Archan Bhattarai on 11/12/21.
//

import UIKit
import AlamofireImage
import Parse

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var captionField: UITextField!
	@IBOutlet weak var clearButton: UIButton!
	@IBOutlet weak var postButton: UIButton!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
	   //forcing darkmode
	    overrideUserInterfaceStyle = .dark

    }

    @IBAction func onPostButton(_ sender: Any) {
	    if memeImageView.image != UIImage(systemName: "photo.artframe") {
		   let post = PFObject(className: "Posts")

		   post["caption"] = captionField.text!
		   post["author"] = PFUser.current()!

		   let imageData = memeImageView.image!.pngData()
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
        
        let size = CGSize(width: 300, height: 300)
	    let scaledImage = image.af.imageAspectScaled(toFill: size)
        
        memeImageView.image = scaledImage
	    clearButton.isHidden = false
	    postButton.isHidden = false
        dismiss(animated: true, completion: nil)
    }

	@IBAction func onClearButton(_ sender: Any) {
		if memeImageView.image != UIImage(systemName: "photo.artframe") {
			memeImageView.image = UIImage(systemName: "photo.artframe")
			memeImageView.tintColor = UIColor.tertiarySystemGroupedBackground
			memeImageView.contentMode = .scaleAspectFit
			clearButton.isHidden = true
			postButton.isHidden = true
		} else {
			clearButton.isHidden = false
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
