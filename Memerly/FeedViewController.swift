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
	let defaultProfilePic = UIImage(systemName: "person.fill")?.withTintColor(UIColor.systemGray3)
    
    var posts = [PFObject]()
    let myRefreshControl = UIRefreshControl() // pull to refresh
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //forcing darkmode
        overrideUserInterfaceStyle = .dark

        tableView.delegate = self
        tableView.dataSource = self
	    NotificationCenter.default.addObserver(self, selector: #selector(viewDidAppear), name: .kRefresh, object: nil)

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
	    cell.heartButton.tag = indexPath.row
	    cell.commentButton.tag = indexPath.row
        
	    cell.captionLabel.text = post["caption"] as? String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
	    cell.memeView.af.setImage(withURL: url)
	    let profilePicFile = user["profilePic"]
	    if profilePicFile != nil {
		    let img = profilePicFile as! PFFileObject
		    if img.name.contains("defaultProfilePic.png") {
			    cell.profilePicImageView.image = defaultProfilePic
		    } else {
			    let urlString = img.url!
			    let url = URL(string: urlString)!
			    cell.profilePicImageView.af.setImage(withURL: url)
		    }
	    }

	    let commentCount = post["commentCount"] as? Int ?? 0
	    if commentCount == 0 {
		    cell.commentCountLabel.isHidden = true
	    } else {
		    cell.commentCountLabel.isHidden = false
		    cell.commentCountLabel.text = String(describing: commentCount)
	    }

	    let likeCount = post["likedCount"] as? Int ?? 0
	    if likeCount == 0 {
		    cell.likeCountLabel.isHidden = true
	    } else {
		    cell.likeCountLabel.isHidden = false
		    cell.likeCountLabel.text = String(describing: likeCount)
	    }

	    let commentedBy = post["commentedBy"] as? [PFUser]
	    var isCommented = false
	    if commentedBy != nil {
		    for commentedBy in commentedBy! {
			    if commentedBy.objectId! == PFUser.current()!.objectId! {
				    isCommented = true
				    break
			    }
		    }
		    if isCommented {
			    cell.commentButton.setImage(UIImage(systemName: "message.fill"), for: .normal)
		    } else {
			    cell.commentButton.setImage(UIImage(systemName: "message"), for: .normal)
		    }

	    }
	    let likedBy = post["likedBy"] as? [PFUser]
	    var isLiked = false
	    if likedBy != nil {
		    for likedBy in likedBy! {
			    if likedBy.objectId! == PFUser.current()!.objectId! {
				    isLiked = true
				    break
			    }
		    }
		    if isLiked {
			    cell.heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
		    } else {
			    cell.heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
		    }
	    }

	    cell.profilePicImageView.layer.masksToBounds = false
	    cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.frame.height/2
	    cell.profilePicImageView.layer.borderWidth = 1
	    cell.profilePicImageView.layer.borderColor = UIColor.clear.cgColor
	    cell.profilePicImageView.clipsToBounds = true
        
        return cell
    }

	@IBAction func onLikeButton(_ sender: UIButton) {
		let tag = sender.tag
		let postID = posts[tag].objectId!
		let query  = PFQuery(className: "Posts")
		var isLiked = false
		query.getObjectInBackground(withId: postID) { (post, error) in
			if post != nil {
				let likedBy = post!["likedBy"] as? [PFUser]
				if likedBy != nil {
					for liked in likedBy! {
						if liked.objectId! == PFUser.current()!.objectId! {
							isLiked = true
							break
						}
						print(liked)
					}
					if isLiked {
						sender.setImage(UIImage(systemName: "heart"), for: .normal)
						let likeCount = post?["likedCount"] ?? 0
						post?["likedCount"] = likeCount as! Int - 1
						post?.remove(PFUser.current()!, forKey: "likedBy")
					} else {
						sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
						let likeCount = post?["likedCount"] ?? 0
						post?["likedCount"] = likeCount as! Int + 1
						post?.add(PFUser.current()!, forKey: "likedBy")
					}
					do {
						let results: () = try post!.save()
						print(results)
					} catch {
						print(error)
					}
				}
			}
		}
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
	    } else if let vc = segue.destination as? CommentViewController {
		    var selectedPost: PFObject
		    if let button = sender as? UIButton {
			    selectedPost = posts[button.tag]
			    vc.sentBy = "Button"
		    } else {
			    selectedPost = posts[tableView.indexPathForSelectedRow!.row]
			    vc.sentBy = "Table"
		    }
		    let selectedPoster = selectedPost["author"] as! PFUser
		    let imageFile = selectedPost["image"] as! PFFileObject
		    let urlString = imageFile.url!

		    vc.postURLString = urlString
		    vc.postID = selectedPost.objectId!
		    vc.poster = selectedPoster
		    vc.post = selectedPost

	    }
    }
}
extension Notification.Name {
	public static let kRefresh = Notification.Name("refresh")
}
