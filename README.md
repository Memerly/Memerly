The Best Group's App Project - README
===

# Memerly

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

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
   * User can go to their profile page
* Stream
   * Home Feed - User can see a feed of all the memes
 

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



## Wireframes
<img src="" width=600>![](https://i.imgur.com/LpozLg7.png)
### [BONUS] Interactive Prototype
![](https://i.imgur.com/LqvqugC.gif)


![](https://i.imgur.com/9iHzfOF.gif)

## Schema 
[This section will be completed in Unit 9]
### Models
[Add table of models]
### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
