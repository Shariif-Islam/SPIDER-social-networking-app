//
//  HomeVC.swift
//  Spider
//
//  Created by myth on 8/11/17.
//  Copyright © 2017 myth.myth. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, FirebaseManagerDelegate, KeyChainDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn_post: UIBarButtonItem!
    
    var array_posts = [Post]()
    var post: Post!
    var imagePicker: UIImagePickerController!
    var isImageSelected = false
    var selectedImage: UIImage!
    var userImage: String!
    var userName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        getPostFromDatabase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getPostFromDatabase() {
        
        FMGetPostsFromDatabase { (posts) in
            self.array_posts = posts
            self.tableView.reloadData()
        }
    }

    @IBAction func postImage(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func signOut(_ sender: Any) {
        
        let alert = UIAlertController(title: ALERT_WARNING, message: ARE_U_SURE_WANT_TO_SIGNOUT, preferredStyle: .alert)
        
        let yes = UIAlertAction(title: YES, style: .default) { (action) in
            
            if self.KCSignOut() {

                let main = UIStoryboard(name: MAIN_STORYBOARD, bundle: nil)
                let loginVC = main.instantiateViewController(withIdentifier: LOGIN_VC_IDENTIFIER)
     
                self.dismiss(animated: true, completion: nil)
                self.present(loginVC, animated: true, completion: nil)
                
            } else {
                let alert = UIAlertController(title: FAILED_TO_SIGN_OUT, message: CHECK_YOUR_INTERNET, preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        let no = UIAlertAction(title: NO, style: .cancel, handler: nil)
        
        alert.addAction(yes)
        alert.addAction(no)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array_posts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.width + 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let post = array_posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: FEED_TVC_IDENTIFIER, for: indexPath) as? PostTVC {
            cell.iv_profileImage.circleImageView()
            cell.configure(post: post)
            return cell
        } else {
            return PostTVC()
        }
    }
}

extension HomeVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = image
            isImageSelected = true
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        guard isImageSelected else {return}
        
        FMPostToDatabase(with: selectedImage)
    } 
}







































