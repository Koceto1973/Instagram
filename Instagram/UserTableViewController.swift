import UIKit
import Parse

class UserTableViewController: UITableViewController {
    
    var usernames = [""]
    var objectIds = [""]
    var isFollowing = ["" : false]
    var refresher: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refresher.addTarget(self, action: #selector(UserTableViewController.updateTable), for: UIControlEvents.valueChanged )
        tableView.addSubview(refresher)
    }
    
    @objc func updateTable(){
        let query = PFUser.query()
        query?.whereKey("username", notEqualTo: PFUser.current()?.username as Any)
        query?.findObjectsInBackground(block: { (things, error) in
            if error != nil {
                print(error as Any)
            } else if let objects = things {
                self.usernames.removeAll()
                self.objectIds.removeAll()
                self.isFollowing.removeAll()
                for object in objects {
                    if let user = object as? PFUser {
                        if let username = user.username {
                            if let objectId = user.objectId {
                                // just the email part before @
                                let usernameArray = username.components(separatedBy: "@")
                                self.usernames.append(usernameArray[0])
                                self.objectIds.append(objectId)
                                let query = PFQuery(className: "Following")
                                query.whereKey("follower", equalTo: PFUser.current()?.objectId as Any)
                                query.whereKey("following", equalTo: objectId)
                                query.findObjectsInBackground(block: { (objects, error) in
                                    if let objects = objects {
                                        if objects.count > 0 {
                                            self.isFollowing[objectId] = true
                                        } else {
                                            self.isFollowing[objectId] = false
                                        }
                                        if self.usernames.count == self.isFollowing.count {
                                            self.tableView.reloadData()
                                            self.refresher.endRefreshing()
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = usernames[indexPath.row]
        if let followsBoolean = isFollowing[objectIds[indexPath.row]] {
            if followsBoolean { cell.accessoryType = UITableViewCellAccessoryType.checkmark }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let followsBoolean = isFollowing[objectIds[indexPath.row]] {
            if followsBoolean { // that row user is followed
                // make it not followed
                isFollowing[objectIds[indexPath.row]] = false
                cell?.accessoryType = UITableViewCellAccessoryType.none
                let query = PFQuery(className: "Following")
                query.whereKey("follower", equalTo: PFUser.current()?.objectId as Any)
                query.whereKey("following", equalTo: objectIds[indexPath.row])
                query.findObjectsInBackground(block: { (objects, error) in
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                })
            } else { // that row user is not followed
                // make it followed
                 isFollowing[objectIds[indexPath.row]] = true
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                let following = PFObject(className: "Following")
                following["follower"] = PFUser.current()?.objectId
                following["following"] = objectIds[indexPath.row]
                following.saveInBackground()
            }
        }
    }

    @IBAction func logoutUser(_ sender: Any) {
        PFUser.logOut()
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }

}
