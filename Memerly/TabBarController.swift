//
//  TabBarController.swift
//  Memerly
//
//  Created by Thinh Pham on 12/4/21.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    var feedViewController: FeedNavController!
    var postViewController: PostViewController!
    var profileViewController: ProfileViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedViewController = FeedNavController()
        postViewController = PostViewController()
        profileViewController = ProfileViewController()
        
        self.delegate = self
        
        //viewControllers = [feedViewController, postViewController, profileViewController]
        
        

        // Do any additional setup after loading the view.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is MemeNavController {

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let controller = storyboard.instantiateViewController(withIdentifier: "memeNavController") as? MemeNavController {
                    controller.modalPresentationStyle = .automatic
                    self.present(controller, animated: true, completion: nil)
                }

                return false
            }

            // Tells the tab bar to select other view controller as normal
            return true
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
