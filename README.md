The Best Group's App Project - README
===

# Memerly

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)
3. [Current App](#Current-App)

## Overview
### Description
- An app that allows users to make posts about memes. They are able to like and comment on other posts and their own posts they can make captions for. 

### App Evaluation
- **Category:** Social Media
- **Mobile:** This app will be used for mobile devices and will allow them to access their camera roll when posting memes.
- **Story:** This app will allow users to post meme pictures, like, and comment on each other user's posts. Similar to iFunny and Instagram.
- **Market:** Younger crowd, above 12 years old for safety. Teens, 20s, 30s will be age targets.
- **Habit:** This app will be used quite often throughout the day. It will be for people's entertainment.
- **Scope:** It is used for entertainment and enjoyment. 

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can Login
* User can register account
* User can Post a Meme
* User can go to its profile page
* User can see feed of all the memes
* User can see another user's profile

**Optional Nice-to-have Stories**

* User can search for accounts or memes

### 2. Screen Archetypes

* Login
   * User can Login
* Register
   * User can register account
* Creation
   * User can Post a Meme
* Profile
   * User can go to their own profile page
* Stream
   * Home Feed - User can see a feed of all the memes
* View
   * One user can see another user's profile (View Only)
 

### 3. Navigation

**Tab Navigation** (Tab to Screen)
(Once logged in, these 3 tabs will appear at bottom of each screen)
* Home (feed)
* Make New Post 
* Profile

**Flow Navigation** (Screen to Screen)

* Home Screen -> Login/SignUp Screen (top-left tab) 
   * by clicking the log out button on the Home Screen

* Login/SignUp Screen -> Home Screen 
    * by clicking the log in button on the Login/SignUp Screen -> goes to Home Screen to see feed, if the account creditials are correct and exist in database already.
    * by clicking the sign up button on the Login/SignUp Screen-> goes to Home Screen to see feed, if the username is not already taken. 

* Home Screen -> Comment Screen
    * by clicking the comment button for a meme on the Home Screen-> goes to Comment Screen to see all the comments for that meme, and can post a comment

* New Post Tab (bottom middle tab) -> Make New Post screen 
   * From any screen, clicking on the New Post Tab will take you to the Make New Post Screen

* Make New Post -> Home screen
   * This is by clicking the PostButton in top-right corner of Make New Post Screen.
   * post will appear in the top of feed on Home Screen.

* Profile Tab (bottom right Button) -> Profile Screen
   * From any screen, clicking on the ProfileTab will take you to the Profile Screen

* Home Screen Tab (bottom left Button) -> Home Screen
   * From any screen, clicking on the HomeScreenTab will take you to the HomeScreen

* Home Screen -> Other User's Profile Screen
   * From clicking on the post author's username, you will go to that user's profile (Other User's Profile Screen), but they can view only



## Wireframes
![](https://i.imgur.com/mN9MsBk.png)

### [BONUS] Interactive Prototype
![](https://i.imgur.com/WrHWQjW.gif) 
![](https://i.imgur.com/ThP8WtQ.gif)
![](https://i.imgur.com/JM164rm.gif)


## Schema 
### Models
#### Post

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for the user post (default field) |
   | author        | Pointer to User| image author |
   | image         | File     | image that user posts |
   | caption       | String   | image caption by author |
   | comments | Array of Comments  | comments that have been posted to an image |
   | likesCount    | Number   | number of likes for the post |
   | createdAt     | DateTime | date when post is created (default field) |
   | updatedAt     | DateTime | date when post is last updated (default field) |
   
#### User

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for the user (default field) |
   | email        | String | user's email |
   | username        | String | user's username |
   | bio        | String | user's profile bio |
   | profilePic         | File     | image for user's profile picture |
   | password       | String   | user's password |
   | createdAt     | DateTime | date when user is created (default field) |
   | updatedAt     | DateTime | date when user is last updated (default field) |
   
#### Comments

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for the comment (default field) |
   | author        | Pointer to User| comment author |
   | post        | Pointer to Post| the post that the comment is on |
   | text       | String   | comment text |
   | createdAt     | DateTime | date when comment is created (default field) |
   | updatedAt     | DateTime | date when comment is last updated (default field) |
   
   
   
### Networking
#### List of network requests by screen
   - Home Feed Screen
      - (Read/GET) Query all existing posts
         ```swift
         let query = PFQuery(className:"Post")
         query.order(byDescending: "createdAt")
         query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let error = error { 
               print(error.localizedDescription)
            } else if let posts = posts {
               print("Successfully retrieved \(posts.count) posts.")
           // TODO: Do something with posts...
            }
         }
         ```
      - (Create/POST) Create a new like on a post
         ```swift
         func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) 
        {
            let post = posts[indexPath.section]
            post["likesCount"] = post["likesCount"] + 1
            likeButton.setImage(UIImage(named:"like-icon-red"), for: UIControl.State.normal)
        }
         ```
      - (Delete) Delete existing like
         ```swift
         func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) 
        {
            let post = posts[indexPath.section]
            post["likesCount"] = post["likesCount"] - 1
            likeButton.setImage(UIImage(named:"like-icon"), for: UIControl.State.normal)
        }
         ```
      - (Create/POST) Create a new comment on a post
        ```swift
        func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) 
        {
            //Create a comment
            let comment = PFObject(className: "Comments")
            comment["text"] = text
            comment["post"] = selectedPost
            comment["author"] = PFUser.current()

            selectedPost.add(comment, forKey: "comments")

            selectedPost.saveInBackground { (success, error) in
                if success
                {
                    print("Comment saved")
                }
                else
                {
                    print("Error saving comment")
                }
            }

            tableView.reloadData()
            //Clear and dismiss input bar
            commentBar.inputTextView.text = nil

            showsCommentBar = false
            becomeFirstResponder()
            commentBar.inputTextView.resignFirstResponder()
        }
        ```
       
   - Create Post Screen
      - (Create/POST) Create a new post object
      - (Create/POST) Create new caption for post
        ```swift
        @IBAction func photolibButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
        }
    
        @IBAction func cameraButton(_ sender: Any) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
        
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
            }
            else {
                let alert = UIAlertController(title: "Oop!", message: "Camera is not available!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default))

                self.present(alert, animated: true, completion: nil)
            }
        
            present(picker, animated: true, completion: nil)
        }
    
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.editedImage] as! UIImage
        
            let size =  CGSize(width: 500, height: 500)
            let scaledImage = image.af_imageScaled(to: size)
        
            postImageView.image = scaledImage
            dismiss(animated: true, completion: nil)
        }

        @IBAction func onSubmitButton(_ sender: Any) 
        {
            let post = PFObject(className: "Posts")

            post["caption"] = commentField.text!
            post["author"] = PFUser.current()!

            let imageData = imageView.image!.pngData()
            let file = PFFileObject(name: "image.png", data: imageData!)

            post["image"] = file

            post.saveInBackground { (success,error) in
                if(success)
                {
                    self.dismiss(animated: true, completion: nil)
                    print("saved!")
                }
                else
                {
                    print("error!")
                }
            }
        
        
        }
        ```

   - Profile Screen
      - (Read/GET) Query logged in user object
      //get the username, profile pic, and bio
      - (Read/GET) Query logged in user's post
     
      ```swift
         let query = PFQuery(className:"Post")
         query.whereKey("author", equalTo: currentUser)
         query.order(byDescending: "createdAt")
         query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let error = error { 
               print(error.localizedDescription)
            } else if let posts = posts {
               print("Successfully retrieved \(posts.count) posts.")
           // TODO: Do something with posts...
            }
         }
        ```
         
      - (Update/PUT) Update user profile image

## Current App

![](https://i.imgur.com/HWc3Hir.gif)
