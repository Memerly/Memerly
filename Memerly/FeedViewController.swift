//
//  FeedViewController.swift
//  Memerly
//
//  Created by Archan Bhattarai on 11/12/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    let myRefreshControl = UIRefreshControl() // pull to refresh
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //forcing darkmode
        overrideUserInterfaceStyle = .dark

        tableView.delegate = self
        tableView.dataSource = self

        // pull to refresh
        myRefreshControl.addTarget(self, action: #selector(viewDidAppear), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query  = PFQuery(className: "Posts")
        query.includeKey("author")
	    query.order(byDescending: "createdAt")
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing() //pull to refresh
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
	    cell.usernameButton.setTitle(user.username, for: .normal)
	    cell.usernameButton.tag = indexPath.row
        
	    cell.captionLabel.text = post["caption"] as? String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
	    cell.memeView.af.setImage(withURL: url)
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
	    if let vc = segue.destination as? OtherProfileViewController {
		    if let button = sender as? UIButton {
			    let index = button.tag
			    let post = posts[index]
			    vc.user = post["author"] as! PFUser
			    vc.posts = posts
		    }
	    }
    }
}
