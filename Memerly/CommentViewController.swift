//
//  CommentViewController.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/6/21.
//

import UIKit
import Parse
import AlamofireImage

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	let currentUser = PFUser.current()!
	var comments = [PFObject]()
	var postID:String = String()
	var poster:PFUser = PFUser()
	var postURLString = String()
	var post: PFObject?
	var sentBy = String()
	let myRefreshControl = UIRefreshControl() // pull to refresh

	let defaultProfilePic = UIImage(systemName: "person.fill")?.withTintColor(UIColor.systemGray3)

	@IBOutlet weak var memeImageView: UIImageView!
	@IBOutlet weak var posterProfilePicImageView: UIImageView!
	@IBOutlet weak var posterUsernameButton: UIButton!
	@IBOutlet weak var captionLabel: UILabel!
	@IBOutlet weak var commenterProfilePicImageView: UIImageView!
	@IBOutlet weak var commentTextView: UITextView!
	@IBOutlet weak var commentsTableView: UITableView!
	@IBOutlet weak var postCommentButton: UIButton!
	@IBOutlet weak var noCommentsLabel: UILabel!

	override func viewDidLoad() {
        super.viewDidLoad()

			//forcing darkmode
		overrideUserInterfaceStyle = .dark
		
        // Do any additional setup after loading the view.
		commentsTableView.delegate = self
		commentsTableView.dataSource = self

		myRefreshControl.addTarget(self, action: #selector(viewDidAppear), for: .valueChanged)
		commentsTableView.refreshControl = myRefreshControl
		self.commentsTableView.rowHeight = UITableView.automaticDimension

		if self.sentBy == "Button" {
			self.commentTextView.becomeFirstResponder()
		}
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)

		noCommentsLabel.isHidden = false
		commentsTableView.isHidden = true

		let username = poster["username"]
		if username != nil {
			posterUsernameButton.setTitle(username as? String, for: .normal)
		} else {
			posterUsernameButton.setTitle("UsernameNotFound", for: .normal)
		}

		let currentUserProfilePicFile = currentUser["profilePic"]
		if currentUserProfilePicFile != nil {
			let img = currentUserProfilePicFile as! PFFileObject
			if img.name == "defaultProfilePic.png" {
				commenterProfilePicImageView.image = defaultProfilePic
			} else {
				let urlString = img.url!
				let url = URL(string: urlString)!
				commenterProfilePicImageView.af.setImage(withURL: url)
			}
		}
		commenterProfilePicImageView.layer.masksToBounds = false
		commenterProfilePicImageView.layer.cornerRadius = commenterProfilePicImageView.frame.height/2
		commenterProfilePicImageView.layer.borderWidth = 1
		commenterProfilePicImageView.layer.borderColor = UIColor.clear.cgColor
		commenterProfilePicImageView.clipsToBounds = true

		let posterProfilePicFile = poster["profilePic"]
		if posterProfilePicFile != nil {
			let img = posterProfilePicFile as! PFFileObject
			if img.name == "defaultProfilePic.png" {
				posterProfilePicImageView.image = defaultProfilePic
			} else {
				let urlString = img.url!
				let url = URL(string: urlString)!
				posterProfilePicImageView.af.setImage(withURL: url)
			}
		}
		posterProfilePicImageView.layer.masksToBounds = false
		posterProfilePicImageView.layer.cornerRadius = posterProfilePicImageView.frame.height/2
		posterProfilePicImageView.layer.borderWidth = 1
		posterProfilePicImageView.layer.borderColor = UIColor.clear.cgColor
		posterProfilePicImageView.clipsToBounds = true


		let postURL = URL(string: postURLString)!
		memeImageView.af.setImage(withURL: postURL)
		let query  = PFQuery(className: "Posts")
		query.getObjectInBackground(withId: postID) { (post, error) in
			if post != nil {
				self.post = post
			} else {
				print("error! \(String(describing: error))")
			}
		}

	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		let query = PFQuery(className: "Comments")
		query.includeKey("author")
		query.whereKey("post", equalTo: post!)
		query.order(byDescending: "createdAt")
		query.limit = 20

		query.findObjectsInBackground { (comments, error) in
			if comments != nil {
				self.comments = comments!
				if self.comments.count > 0 {
					self.noCommentsLabel.isHidden = true
					self.commentsTableView.isHidden = false
				}
				self.commentsTableView.reloadData()
				self.myRefreshControl.endRefreshing() //pull to refresh
			}
		}
	}

	func refreshComments() {
		let query = PFQuery(className: "Comments")
		query.includeKey("author")
		query.whereKey("post", equalTo: self.post!)
		query.order(byDescending: "createdAt")
		query.limit = 20

		query.findObjectsInBackground { (comments, error) in
			if comments != nil {
				self.comments = comments!
				if self.comments.count > 0 {
					self.noCommentsLabel.isHidden = true
					self.commentsTableView.isHidden = false
				}
				self.commentsTableView.reloadData()
				self.myRefreshControl.endRefreshing() //pull to refresh
			}
		}
	}
	
	@IBAction func onDeleteButton(_ sender: UIButton) {
		let query = PFQuery(className:"Posts")

		let commentId:String = comments[sender.tag].objectId!

		query.getObjectInBackground(withId: postID) {
			(post, error) -> Void in
			if post != nil {
				let commentCount = post?["commentCount"] ?? 0
				post?["commentCount"] = commentCount as! Int - 1

				var commentedByArray = post?["commentedBy"] as! [PFUser]
				var IdArray = [String]()
				for Ids in commentedByArray {
					IdArray.append(Ids.objectId!)
				}
				print(commentedByArray)
				print(self.currentUser)
				if let index = IdArray.firstIndex(of: self.currentUser.objectId!) {
					print(index)
					commentedByArray.remove(at: index)
				}
				print(commentedByArray)
				post?["commentedBy"] = commentedByArray
				do {
					let results: ()? = try post?.save()
					let query = PFQuery(className:"Comments")
					query.getObjectInBackground(withId: commentId) {
						(comment, error) -> Void in
						if error != nil {
							print(error!)
						} else if comment != nil {
							do {
								let results: ()? = try comment?.delete()
								self.refreshComments()
								print(results!)
							} catch {
								print(error)
							}
						}
					}
					print(results!)
				} catch {
					print(error)
				}
			}
		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		comments.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "commentsTableViewCell") as! CommentsTableViewCell

		let comment = comments[indexPath.row]
		cell.deleteButton.isHidden = true

		let user = comment["author"] as! PFUser
		cell.usernameButton.setTitle(user.username, for: .normal)
		cell.usernameButton.tag = indexPath.row
		cell.deleteButton.tag = indexPath.row

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

		print(user, PFUser.current()!)

		if user.objectId == PFUser.current()!.objectId {
			cell.deleteButton.isHidden = false
		}

		cell.profilePicImageView.layer.masksToBounds = false
		cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.frame.height/2
		cell.profilePicImageView.layer.borderWidth = 1
		cell.profilePicImageView.layer.borderColor = UIColor.clear.cgColor
		cell.profilePicImageView.clipsToBounds = true

		cell.commentLabel.text = comment["comment"] as? String

		return cell
	}

	@IBAction func onPostButton(_ sender: Any) {
		if commentTextView.text != nil {
			let comment = PFObject(className: "Comments")
			let query  = PFQuery(className: "Posts")

			query.getObjectInBackground(withId: postID) {
				(post, error) -> Void in
				if post != nil {
					comment["post"] = post!
					comment["comment"] = self.commentTextView.text!
					comment["author"] = PFUser.current()!
					post?.incrementKey("commentCount")
					post?.add(self.currentUser, forKey: "commentedBy")
					do {
						let results: () = try comment.save()
						let query = PFQuery(className: "Comments")
						query.includeKey("author")
						query.whereKey("post", equalTo: post!)
						query.order(byDescending: "createdAt")
						query.limit = 20

						query.findObjectsInBackground { (comments, error) in
							if comments != nil {
								self.comments = comments!
								if self.comments.count > 0 {
									self.noCommentsLabel.isHidden = true
									self.commentsTableView.isHidden = false
								}
								self.commentsTableView.reloadData()
								self.myRefreshControl.endRefreshing() //pull to refresh
							}
						}
						print(results)
					} catch {
						print(error)
					}
				} else if error != nil {
					print("error! \(String(describing: error))")
				}
			}
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
