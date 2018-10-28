import UIKit
import Parse

class ViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signupOrLoginButton: UIButton!
    @IBOutlet weak var switchLoginModeButton: UIButton!
    
    // variables
    var signupModeActive = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // opening the app with a logged in user already
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            performSegue(withIdentifier: "showUserTable", sender: self)
        }
        // hiding the nav bar on segueing back
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func switchLoginMode(_ sender: Any) {
        if (signupModeActive) {
            signupModeActive = false
            signupOrLoginButton.setTitle("Log In", for: [])
            switchLoginModeButton.setTitle("Sign Up", for: [])
        } else {
            signupModeActive = true
            signupOrLoginButton.setTitle("Sign Up", for: [])
            switchLoginModeButton.setTitle("Log In", for: [])
        }
    }
    
    @IBAction func signupOrLogin(_ sender: Any) {
        
        if email.text == "" || password.text == "" {
            displayAlert(title:"Error in form", message:"Please enter an email and password")
        } else {
            // activity indicator
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            if (signupModeActive) {  // sign up
                print("Signing up....")
                let user = PFUser()
                user.username = email.text
                user.password = password.text
                user.email = email.text
                
                user.signUpInBackground(block: { (success, error) in
                    activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    if let error = error {
                        self.displayAlert(title:"Could not sign you up", message:error.localizedDescription)
                        // let errorString = error.userInfo["error"] as? NSString
                        // Show the errorString somewhere and let the user try again.
                        print(error)
                    } else {
                        print("signed up!")
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    }
                })
            } else { // log in
                PFUser.logInWithUsername(inBackground: email.text!, password: password.text!, block: { (user, error) in
                    activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    if user != nil {
                        print("Login successful")
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    } else {
                        var errorText = "Unknown error: please try again"
                        if let error = error {
                            errorText = error.localizedDescription
                        }
                        self.displayAlert(title:"Could not sign you up", message:errorText)
                    }
                })
            }
        }
    }
    
    // handy alerts function
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in self.dismiss(animated: true, completion: nil)  }))
        self.present(alert, animated: true, completion: nil)
    }
}

