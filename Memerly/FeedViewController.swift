//
//  FeedViewController.swift
//  Memerly
//
//  Created by Archan Bhattarai on 11/12/21.
//

import UIKit
import Parse
import AlamofireImage


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CommentViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
	let defaultProfilePic = UIImage(systemName: "person.fill")?.withTintColor(UIColor.systemGray3)
	let defaults = UserDefaults.standard

    var posts = [PFObject]()
    let myRefreshControl = UIRefreshControl() // pull to refresh
    
    override func viewDidLoad() {
        super.viewDidLoad()

	    let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(self.onLogoutButton))
	    navigationItem.rightBarButtonItem = logoutButton
	    logoutButton.tintColor = UIColor.systemRed

        //forcing darkmode
        overrideUserInterfaceStyle = .dark

        tableView.delegate = self
        tableView.dataSource = self

        // pull to refresh
        myRefreshControl.addTarget(self, action: #selector(viewDidAppear), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        tableView.rowHeight = UITableView.automaticDimension
	    tableView.estimatedRowHeight = 200
    }
	@objc private func onLogoutButton() {
		defaults.set(false, forKey: "rememberMe")
		PFUser.logOut()
		performSegue(withIdentifier: "logout", sender: nil)
		print("logout")
	}

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
	    refreshPosts()
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
	    cell.likeCountLabel.tag = indexPath.row
        
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
		    cell.likeCountLabel.text = ""
	    } else {
//		    cell.likeCountLabel.isHidden = false
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
		print("something")
		let tag = sender.tag
		selectRow(tableView: tableView, position: tag)
		let postID = posts[tag].objectId!
		let query  = PFQuery(className: "Posts")
		var isLiked = false
		query.getObjectInBackground(withId: postID) { (post, error) in
			if post != nil {
				print("post != nil")
				let likedBy = post!["likedBy"] as? [PFUser]
				if likedBy != nil {
					print("likedby != nil")
					for liked in likedBy! {
						if liked.objectId! == PFUser.current()!.objectId! {
							isLiked = true
							print("isLiked = true")
							break
						}
						print(liked)
					}
					if isLiked {
						print("isLiked = true")
						sender.setImage(UIImage(systemName: "heart"), for: .normal)
						let likeCount = post?["likedCount"] ?? 0
						post?["likedCount"] = likeCount as! Int - 1
						post?.remove(PFUser.current()!, forKey: "likedBy")
						let label = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! PostCell
						if likeCount as! Int - 1 == 0 {
							label.likeCountLabel.text = ""
						} else {
							label.likeCountLabel.text = "\(likeCount as! Int - 1)"
						}
					} else if !isLiked {
						print("isliked = false")
						sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
						let likeCount = post?["likedCount"] ?? 0
						post?["likedCount"] = likeCount as! Int + 1
						post?.add(PFUser.current()!, forKey: "likedBy")
						let label = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! PostCell
						label.likeCountLabel.text = "\(likeCount as! Int + 1)"
					}
					do {
						let results: () = try post!.save()
						print(results)
					} catch {
						print(error)
					}
				} else {
					print("liked = nil")
				}
			}
			else {
				print("post = nil")
			}
		}
	}
	func selectRow(tableView: UITableView, position: Int) {
		let sizeTable = tableView.numberOfRows(inSection: 0)
		guard position >= 0 && position < sizeTable else { return }
		let indexPath = IndexPath(row: position, section: 0)
		tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
	}

	func refreshPosts() {
		let query  = PFQuery(className: "Posts")
		query.includeKey("author")
		query.order(byDescending: "createdAt")
		query.limit = 20

		query.findObjectsInBackground {
			(posts, error) in
			if posts != nil {
				self.posts = posts!
				self.tableView.reloadData()
				self.myRefreshControl.endRefreshing() //pull to refresh
			}
		}
	}

		// MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	    print(segue.destination)
	    switch segue.identifier {
		    case "commentView":
			    let navigationController = segue.destination as! UINavigationController
			    let commentViewController = navigationController.topViewController as! CommentViewController

			    navigationController.presentationController?.delegate = commentViewController

			    commentViewController.delegate = self
			    var selectedPost: PFObject
			    if let button = sender as? UIButton {
				    selectedPost = posts[button.tag]
				    commentViewController.sentBy = "Button"
			    } else {
				    selectedPost = posts[tableView.indexPathForSelectedRow!.row]
				    commentViewController.sentBy = "Table"
			    }
			    let selectedPoster = selectedPost["author"] as! PFUser
			    let imageFile = selectedPost["image"] as! PFFileObject
			    let urlString = imageFile.url!

			    commentViewController.postURLString = urlString
			    commentViewController.postID = selectedPost.objectId!
			    commentViewController.poster = selectedPoster
			    commentViewController.post = selectedPost
			    commentViewController.postCaptian = selectedPost["caption"] as! String

		    default:
			    break
	    }
	    if let vc = segue.destination as? OtherProfileViewController {
		    if let button = sender as? UIButton {
			    let index = button.tag
			    let post = posts[index]
			    vc.user = post["author"] as! PFUser
//			    vc.posts = posts
		    }
	    }
    }
	func CommentViewControllerDidCancel(_ commentViewController: CommentViewController) {
		dismiss(animated: true, completion: nil)
	}

	func CommentViewControllerDidFinish(_ commentViewController: CommentViewController) {
		posts = commentViewController.posts
		tableView.reloadData()
		dismiss(animated: true, completion: nil)
	}
}
