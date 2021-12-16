//
//  CommentViewController.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/6/21.
//

import UIKit
import Parse
import AlamofireImage

protocol CommentViewControllerDelegate: AnyObject {

	func CommentViewControllerDidCancel(_ commentViewController: CommentViewController)
	func CommentViewControllerDidFinish(_ commentViewController: CommentViewController)
}

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAdaptivePresentationControllerDelegate {

	let currentUser = PFUser.current()!
	var comments = [PFObject]()
	var postID:String = String()
	var poster:PFUser = PFUser()
	var postURLString = String()
	var post: PFObject?
	var sentBy = String()
	let myRefreshControl = UIRefreshControl() // pull to refresh
	var posts = [PFObject]()
	weak var delegate: CommentViewControllerDelegate?

	let defaultProfilePic = UIImage(systemName: "person.fill")?.withTintColor(UIColor.systemGray3)

	@IBOutlet weak var memeImageView: UIImageView!
	@IBOutlet weak var posterProfilePicImageView: UIImageView!
	@IBOutlet weak var posterUsernameButton: UIButton!
	@IBOutlet weak var captionLabel: UILabel!
	@IBOutlet weak var commenterProfilePicImageView: UIImageView!
	@IBOutlet weak var commentTextView: UITextView!
	@IBOutlet weak var commentsTableView: UITableView!
	@IBOutlet weak var postCommentButton: UIButton!
	@IBOutlet weak var deletePostButton: UIButton!
	@IBOutlet weak var noCommentsLabel: UILabel!


	override func viewDidLoad() {
		super.viewDidLoad()
		commentsTableView.delegate = self
		commentsTableView.dataSource = self

		isModalInPresentation = true

			//forcing darkmode
		overrideUserInterfaceStyle = .dark
		
        // Do any additional setup after loading the view.


		myRefreshControl.addTarget(self, action: #selector(viewDidAppear), for: .valueChanged)
		commentsTableView.refreshControl = myRefreshControl
		self.commentsTableView.rowHeight = UITableView.automaticDimension


			// call the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

			// call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)


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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)

		if self.sentBy == "Button" {
//			self.commentTextView.becomeFirstResponder()
		}

		deletePostButton.isHidden = true
		noCommentsLabel.isHidden = false
		commentsTableView.isHidden = true

		if poster.objectId == PFUser.current()!.objectId {
			deletePostButton.isHidden = false
		}

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


		// MARK: - UIAdaptivePresentationControllerDelegate

	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {

		let query  = PFQuery(className: "Posts")
		query.includeKey("author")
		query.order(byDescending: "createdAt")
		query.limit = 20
		do {
			let results: [PFObject] = try query.findObjects()
			self.posts = results
			print("I hate everything")
		} catch {
			print(error)
		}
		delegate?.CommentViewControllerDidFinish(self)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.refreshComments()
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
				if let index = IdArray.firstIndex(of: self.currentUser.objectId!) {
					commentedByArray.remove(at: index)
				}
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
						self.refreshComments()
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
    
	@IBAction func onDeletePostButton(_ sender: UIButton) {
			// Declare Alert message
		let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this post?", preferredStyle: .alert)

			// Create OK button with action handler
		let ok = UIAlertAction(title: "Delete it!", style: .default, handler: { (action) -> Void in
			print("Delete button tapped")
			self.deletePost()
		})

			// Create Cancel button with action handlder
		let cancel = UIAlertAction(title: "Nevermind!", style: .cancel) { (action) -> Void in
			print("Cancel button tapped")
		}

			//Add OK and Cancel button to dialog message
		dialogMessage.addAction(ok)
		dialogMessage.addAction(cancel)

			// Present dialog message to user
		ok.setValue(UIColor.systemRed, forKey: "titleTextColor")
		self.present(dialogMessage, animated: true, completion: nil)
	}

	func deletePost() {
		for comment in comments {
			let id = comment.objectId!
			let query = PFQuery(className:"Comments")

			query.getObjectInBackground(withId: id) {
				(comment, error) -> Void in
				if error != nil {
					print("error! \(String(describing: error))")
				} else if comment != nil {
					do {
						let results: ()? = try comment?.delete()
						print(results!)
					} catch {
						print(error)
					}
				}
			}
		}

		let query  = PFQuery(className: "Posts")

		query.getObjectInBackground(withId: postID) {
			(post, error) -> Void in
			if error != nil {
				print("error! \(String(describing: error))")
			} else if post != nil {
				do {
					let results: ()? = try post?.delete()
					print(results!)
					let query  = PFQuery(className: "Posts")
					query.includeKey("author")
					query.order(byDescending: "createdAt")
					query.limit = 20
					do {
						let results: [PFObject] = try query.findObjects()
						self.posts = results
						print("I hate everything")
					} catch {
						print(error)
					}
					self.delegate?.CommentViewControllerDidFinish(self)
				} catch {
					print(error)
				}
			}
		}
	}




    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
	    print(segue)
    }


}

extension Collection where Element: Equatable {
	func indices(of element: Element) -> [Index] { indices.filter { self[$0] == element } }
}

extension Collection {
	func indices(where isIncluded: (Element) throws -> Bool) rethrows -> [Index] { try indices.filter { try isIncluded(self[$0]) } }
}
