//
//  LoginVC.swift
//  Spider
//
//  Created by myth on 8/11/17.
//  Copyright © 2017 myth. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, FirebaseManagerDelegate, KeyChainDelegate {

    //MARK: Properties
    @IBOutlet weak var lb_errorMessage: UILabel!
    @IBOutlet weak var tf_email: UITextField!
    @IBOutlet weak var tf_password: UITextField!
    @IBOutlet weak var btn_signupLogin: UIButton!

    var userUID : String!
    
    // MARK: Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tf_email.delegate = self
        tf_password.delegate = self
       
        customization()
        
        // Notification for keyboard show hide
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(sender:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(sender:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        // Remove observer
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
        if segue.identifier == SIGN_UP_SEGUE_IDENTIFIER {
            
            if let nav = segue.destination as? UINavigationController {
                
                if let destination = nav.topViewController as? UserVC {
                    
                    if let email = tf_email.text {
                        destination.email = email
                    }
                    
                    if let password = tf_password.text {
                        destination.password = password
                    }
                }
            }
        }
    }
    
    // MARK: Custom func
    func customization() {
        
        // UI customization
        tf_email.spiderTextField()
        tf_password.spiderTextField()
        
        btn_signupLogin.layer.cornerRadius = 5
    }
    
    func performSignUpSegue() {
        // Show UserVC for complete signup
        performSegue(withIdentifier: SIGN_UP_SEGUE_IDENTIFIER, sender: nil)
    }
    
    func performLoginSegue() {
        // Show home VC after successful login
        performSegue(withIdentifier: LOGIN_SEGUE_IDENTIFIER, sender: nil)
    }
    
    @objc func showKeyboard(sender: Notification) {
        // Change view position to up
       self.view.frame.origin.y = -220
    }
    
    @objc func hideKeyboard(sender: Notification) {
        // Re-set view position
        self.view.frame.origin.y = 0
    }
    
    func checkEmailAndpassword() -> Bool{
        
        if tf_email.text == EMPTY_STRING && tf_password.text == EMPTY_STRING {
            lb_errorMessage.text = ENTER_EMAIL_PASSWORD
            return false
        }
        
        if tf_email.text == EMPTY_STRING {
            lb_errorMessage.text = ENTER_EMAIL
            return false
        }
        
        if tf_password.text == EMPTY_STRING {
            lb_errorMessage.text = ENTER_PASSWORD
            return false
        }
        
        if let count = tf_password.text?.count.hashValue {
            if count < 6 {
                lb_errorMessage.text = PASSWORD_SHOULD_BE_6
                return false
            }
        }
        return true
    }

    //MARK: IB Actions
    @IBAction func signUpIn(_ sender: Any) {

        if let email = tf_email.text, let password = tf_password.text, checkEmailAndpassword() == true {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            FMAuthenticateSignIn(with: email, password: password,
                                       callback: {(userUID,status) in
                                        
             UIApplication.shared.isNetworkActivityIndicatorVisible = false
                /**
                 - Check for signin, if success then go to home page
                 otherwise go to UserVC for signup
                 */
                if status {
                    // Login success
                    self.userUID = userUID
                    // Save user login info to keychain
                    self.KCSaveUserSignIn(with: userUID)
                    self.performLoginSegue()
                } else {
                    // Show UserVC for complete signup
                    self.performSignUpSegue()
                }
                                        
            })
        }
    }
}

extension LoginVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
}

extension UITextField {
    
    func spiderTextField() {
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.cornerRadius = 5
    }
}








