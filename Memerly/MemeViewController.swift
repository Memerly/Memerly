//
//  MemeViewController.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/12/21.
//

import UIKit
import Alamofire

protocol MemeViewControllerDelegate: AnyObject {

	func MemeViewControllerDidCancel(_ memeViewController: MemeViewController)
	func MemeViewControllerDidFinish(_ memeViewController: MemeViewController)
}


class MemeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UIAdaptivePresentationControllerDelegate {

	let username = "Memerly"
	let password = "November21!"

	var memes = [Meme]()
	var selectedMeme = Meme()

	weak var delegate: MemeViewControllerDelegate?

	@IBOutlet weak var memeImageView: UIImageView!
	@IBOutlet weak var textBoxTableView: UITableView!
	@IBOutlet weak var memePickerView: UIPickerView!

	override func viewDidLoad() {
		super.viewDidLoad()
		memePickerView.delegate = self
		textBoxTableView.delegate = self
		memePickerView.dataSource = self
		textBoxTableView.dataSource = self
		isModalInPresentation = true
		overrideUserInterfaceStyle = .dark

		getMemes()

        // Do any additional setup after loading the view.
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		let meme = memes[0]
		let urlString = meme.url
		let url = URL(string: urlString)!

		memeImageView.af.setImage(withURL: url)
	}

	func getMemes() {
		let request = AF.request("https://api.imgflip.com/get_memes")
		request.responseDecodable(of: Memes.self) { response in
			switch response.result {
				case .success(let data):
					self.memes = data.data.values.first!
					self.selectedMeme = self.memes[0]
					print(self.memes[0].name)
					self.memePickerView.reloadAllComponents()
					self.textBoxTableView.reloadData()

				case .failure(let error):
					print(error)
			}
		}
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
		let url = URL(string: urlString)!

		memeImageView.af.setImage(withURL: url)
		textBoxTableView.reloadData()
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		selectedMeme.box_count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = textBoxTableView.dequeueReusableCell(withIdentifier: "textBox") as! TextBoxTableViewCell

		cell.textBoxTextField.placeholder = "Text Box \(indexPath.row)"
		cell.textBoxTextField.tag = indexPath.row + 1

		return cell
	}
    
	@IBAction func onPreviewButton(_ sender: Any) {
		let template_id = selectedMeme.id
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
	}
	@IBAction func onPostButton(_ sender: Any) {
		delegate?.MemeViewControllerDidFinish(self)

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
