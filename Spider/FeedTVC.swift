//
//  FeedTVC.swift
//  Spider
//
//  Created by myth on 10/11/17.
//  Copyright © 2017 myth. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import FirebaseStorageUI

class FeedTVC: UITableViewCell {

    @IBOutlet weak var iv_profileImage: UIImageView!
    @IBOutlet weak var lb_userName: UILabel!
    @IBOutlet weak var iv_postImage: UIImageView!
    @IBOutlet weak var btn_like: UIButton!
    @IBOutlet weak var lb_like: UILabel!
    
    let currentUser = KeychainWrapper.standard.string(forKey: UID)
    var post: Post!

    func configure(post: Post, postImage: UIImage? = nil, userProfileImage: UIImage? = nil) {

        self.post = post
        self.lb_like.text = "\(post.likes)"
        self.lb_userName.text = "\(post.userName) \(UPLOADED_AN_IMAGE)"
        
        guard let currentUserUID = currentUser else {return}
        let like = Database.database().reference().child(USERS).child(currentUserUID).child(LIKES).child(post.postKey)
        
        like.observe(.value) { (datasnapshot) in
           
            if let _ = datasnapshot.value as? NSNull {
                
                let icon = UIImage(named: ICON_LIKE)?.withRenderingMode(.alwaysTemplate)
                self.btn_like.setImage(icon, for: .normal)
                
            } else {
                
                self.btn_like.setImage(UIImage(named: ICON_LIKE), for: .normal)
            }
        }
   
        if postImage != nil {
            self.iv_postImage.image = userProfileImage
        } else {
            let reference = Storage.storage().reference().child(post.postImgeUID)
            iv_postImage.sd_setImage(with: reference)
        }
    
        if userProfileImage != nil {
            self.iv_profileImage.image = userProfileImage
        } else {
            let reference = Storage.storage().reference().child(post.profileImgeUID)
            iv_profileImage.sd_setImage(with: reference)
        }
        
        Database.database().reference().child(USERS).child(currentUserUID).child(LIKES).child(post.postKey)
    }
    
    @IBAction func likeAction(_ sender: Any) {
        
        guard let currentUserUID = currentUser else {return}
        let likeRef = Database.database().reference().child(USERS).child(currentUserUID).child(LIKES).child(post.postKey)
        
        likeRef.observeSingleEvent(of: .value) { (dataSnapshot) in

            if let _ = dataSnapshot.value as? NSNull {
                self.post.adJustLikes(addLike: true)
                likeRef.setValue(true)
            } else {
                self.post.adJustLikes(addLike: false)
                likeRef.removeValue()
            }
        }
    }
}



























