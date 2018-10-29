//
//  FeedTableViewController.swift
//  Instagram
//
//  Created by K.K. on 29.10.18.
//  Copyright © 2018 Robert Percival. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UITableViewController {

    var users = [String: String]()
    var comments = [String]()
    var usernames = [String]()
    var imageFiles = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFUser.query()
        query?.whereKey("username", notEqualTo: PFUser.current()?.username as Any)
        query?.findObjectsInBackground(block: { (objects, error) in
            if let users = objects {
                for object in users {
                    if let user = object as? PFUser {
                        self.users[user.objectId!] = user.username!
                    }
                }
            }
            let followed = PFQuery(className: "Following")
            followed.whereKey("follower", equalTo: PFUser.current()?.objectId as Any)
            followed.findObjectsInBackground(block: { (objects, error) in
                if let followers = objects {
                    for follower in followers {
                        if let followedUser = follower["following"] {
                            let query = PFQuery(className: "Post")
                            query.whereKey("userid", equalTo: followedUser)
                            query.findObjectsInBackground(block: { (objects, error) in
                                if let posts = objects {
                                    for post in posts {
                                        self.comments.append(post["message"] as! String)
                                        self.usernames.append(self.users[post["userid"] as! String]!)
                                        self.imageFiles.append(post["imageFile"] as! PFFile)
                                        self.tableView.reloadData()
                                    }
                                }
                            })
                        }
                    }
                }
            })
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedTableViewCell

        imageFiles[indexPath.row].getDataInBackground { (data, error) in
            if let imageData = data {
                if let imageToDisplay = UIImage(data: imageData) {
                    cell.postedImage.image = imageToDisplay
                }
            }
        }
        cell.comment.text = comments[indexPath.row]
        cell.userInfo.text = usernames[indexPath.row]
        return cell
    }
}
