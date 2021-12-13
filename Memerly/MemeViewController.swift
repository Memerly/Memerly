//
//  MemeViewController.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/12/21.
//

import UIKit
import Alamofire

class MemeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

	let username = "Memerly"
	let password = "November21!"

	var memes = [Meme]()

	@IBOutlet weak var memeImageView: UIImageView!
	@IBOutlet weak var memePickerView: UIPickerView!

	override func viewDidLoad() {
		super.viewDidLoad()
		memePickerView.delegate = self
		memePickerView.dataSource = self

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
//		request.responseJSON() { data in
//			print(data)
//
//		}
		request.responseDecodable(of: Response.self) { response in
			switch response.result {
				case .success(let data):
					self.memes = data.data.values.first!
					print(self.memes[0].name)
					self.memePickerView.reloadAllComponents()
//					print(data)

				case .failure(let error):
					print(error)
			}
		}
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		memes.count
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		let meme = memes[row]
		return meme.name
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let meme = memes[row]
		let urlString = meme.url
		let url = URL(string: urlString)!

		memeImageView.af.setImage(withURL: url)
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
