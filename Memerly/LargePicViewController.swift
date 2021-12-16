//
//  LargePicViewController.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/16/21.
//

import UIKit

class LargePicViewController: UIViewController {
	@IBOutlet weak var memeImageView: UIImageView!
	var img = UIImage()
	
    override func viewDidLoad() {
        super.viewDidLoad()

	    overrideUserInterfaceStyle = .dark
	    memeImageView.image = img

        // Do any additional setup after loading the view.
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
