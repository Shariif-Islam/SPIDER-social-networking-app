//
//  UserVC.swift
//  Spider
//
//  Created by myth on 8/11/17.
//  Copyright © 2017 myth. All rights reserved.
//

import UIKit

class UserVC: UIViewController, FirebaseManagerDelegate, KeyChainDelegate {

    // MARK: IB Properties
    @IBOutlet weak var iv_profileImage: UIImageView!
    @IBOutlet weak var tf_userName: UITextField!
    @IBOutlet weak var btn_createProfile: UIBarButtonItem!
    @IBOutlet weak var lb_errorMessage: UILabel!
    @IBOutlet weak var lb_password: UILabel!
    @IBOutlet weak var lb_email: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var view_activityIndicator: UIView!
    @IBOutlet weak var btn_cancel: UIBarButtonItem!
    
    // MARK: Custom Properties
    var userUID : String!
    var email : String!
    var password : String!
    var userName : String!
    var imagePicker : UIImagePickerController!
    
    // MARK: Override func
    override func viewDidLoad() {
        super.viewDidLoad()
    
        initialization()
    }
    
    override func viewDidLayoutSubviews() {
        iv_profileImage.circleImageView()
        tf_userName.spiderTextField()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Custom func
    func initialization() {
        
        lb_email.text = email
        lb_password.text = password

        btn_createProfile.isEnabled = false
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        tf_userName.delegate = self
    }

    func performCreateProfileSegue() {
        // Show home VC after successful login
        performSegue(withIdentifier: CREATE_PROFILE_SEGUE_IDENTIFIER, sender: nil)
    }

    func uploadUserInfo() {

        guard let image = iv_profileImage.image else {
            return
        }
        
        FMUploadUserInfo(userUID: userUID, userName: userName, image: image) { (errorMessage, status) in
            
            if status {
                // Save sign up info to keychain
                self.KCSaveUserSignIn(with: self.userUID)
                // Show Home after successful signup
                self.performCreateProfileSegue()
            } else {
                self.lb_errorMessage.text = errorMessage
            }
            self.btn_createProfile.isEnabled = true
            self.btn_cancel.isEnabled = true
            self.view_activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    func checkUserName() -> Bool {
        
        if tf_userName.text == EMPTY_STRING {
            lb_errorMessage.text = ENTER_USER_NAME
            return false
        }
        
        if let count = tf_userName.text?.count.hashValue {
            if count < 3 {
                lb_errorMessage.text = USER_NAME_SHOULD_BE_3
                return false
            }
        }
        userName = tf_userName.text
        return true
    }

    // MARK: IBAction func
    @IBAction func createProfile(_ sender: Any) {
        
        if checkUserName() {
            
            FMCreateUser(with: email, password: password, callback: { (userUID, errorMessage, status) in
                
                if status {
                    //Processing signup
                    self.btn_createProfile.isEnabled = false
                    self.btn_cancel.isEnabled = false
                    self.view_activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()
                    
                    self.userUID = userUID
                    self.uploadUserInfo()
                    
                } else {
                    self.lb_errorMessage.text = errorMessage
                }
            })
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectProfileImage(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: extension
extension UserVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            iv_profileImage.image = image
        }
         self.dismiss(animated: true, completion: nil)
    }
}

extension UserVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Enable button
        btn_createProfile.isEnabled = true
        return true
    }
}

extension UIImageView {
    
    func circleImageView() {
        self.layer.cornerRadius = self.bounds.size.height / 2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.orange.cgColor
        self.clipsToBounds = true
    }
}
















