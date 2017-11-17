//
//  FirebaseManager.swift
//  Spider
//
//  Created by myth on 9/11/17.
//  Copyright © 2017 myth. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseManagerDelegate {

    func FMAuthenticateSignIn(with email: String, password: String,
                                    callback: @escaping (String, Bool) ->())
    
    func FMCreateUser(with email: String, password: String,
                                    callback: @escaping (String, String, Bool) ->())
    
    func FMUploadUserInfo(userUID: String,userName: String, image: UIImage, callback: @escaping (String, Bool) ->())
    
    func FMGetPostsFromDatabase( callback: @escaping ([Post]) ->())
    
    func FMPostToDatabase(with image:UIImage)
}

extension FirebaseManagerDelegate {
    
    // Sign In
    func FMAuthenticateSignIn(with email: String, password: String,
                                    callback: @escaping (String,Bool) -> ()) {
        
        Auth.auth().signIn(withEmail: email, password: password) {
            (user, error) in
            
            if error == nil {
                if let uid = user?.uid {
                    callback(uid, true)
                }
            } else {
                callback(EMPTY_STRING, false)
            }
        }
    }
    
    // Sign Up
    func FMCreateUser(with email: String, password: String,
                            callback: @escaping (String, String, Bool) ->()) {
        
        Auth.auth().createUser(withEmail: email, password: password) {
            (user, error) in
            
            if error == nil {
                if let uid = user?.uid {
                    callback(uid, EMPTY_STRING, true)
                }
            } else {
                if let errorMessage = error?.localizedDescription {
                    callback(EMPTY_STRING, errorMessage, false)
                }
            }
        }
    }
    
    // Upload User Info
    func FMUploadUserInfo(userUID: String, userName: String, image: UIImage, callback: @escaping (String, Bool) ->()) {
        
        if let imageData = UIImageJPEGRepresentation(image, 0.2) {
            
            let imageUID = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = METADATA_CONTENT_TYPE
            
            Storage.storage().reference().child(imageUID).putData(imageData, metadata: metadata, completion: { (metadata, error) in
                
                if error == nil {
                    // Get Image as String from storage
                    if let imageString = metadata?.downloadURL()?.absoluteString {
                        
                        // Create user info
                        let userData = [
                            USER_NAME: userName,
                            USER_IMAGE: imageString,
                            PROFILE_IMAGE_UID: imageUID
                        ]
                        // Store into database
                        let setLocation = Database.database().reference().child(USERS).child(userUID)
                        setLocation.setValue(userData)
    
                        callback(EMPTY_STRING, true)
                        
                    } else {
                        print(FAILED_TO_GET_IMAGE_STRING)
                    }
                    
                } else {
                    if let message = error?.localizedDescription {
                        callback(message, false)
                    }
                }
            })
        }
    }

    // Get Post from firebase database
    func FMGetPostsFromDatabase( callback: @escaping ([Post]) ->()) {
        Database.database().reference().child(POST).observe(.value) {
            (datasnapshot) in
            
            if let snapshot = datasnapshot.children.allObjects as? [DataSnapshot] {
                
                var arry_post = [Post]()
                for data in snapshot {
                    if let posts = data.value as? Dictionary<String, AnyObject> {
                        let post = Post(postKey: data.key, postData: posts)
                        arry_post.append(post)
                    }
                }
                arry_post.reverse()
                callback(arry_post)
            }
        }
    }
    
    // Post image to database
    func FMPostToDatabase(with image:UIImage) {
        
        if let imageData = UIImageJPEGRepresentation(image, 0.2) {
            let postImageUID = NSUUID().uuidString
            let metadata = StorageMetadata()
            
            Storage.storage().reference().child(postImageUID).putData(imageData, metadata: metadata, completion: { (metadata, error) in
                
                if error != nil {
                    print("\(String(describing: error?.localizedDescription))")
                } else {
                    if let postImageURL = metadata?.downloadURL()?.absoluteString {
             
                        if let userID = Auth.auth().currentUser?.uid {
                            
                            Database.database().reference().child(USERS).child(userID).observeSingleEvent(of: .value) {
                                (dataSnapShot) in
                                
                                if let data = dataSnapShot.value as? Dictionary<String, AnyObject> {
                                    guard let userName = data[USER_NAME] else{return}
                                    guard let userImage = data[USER_IMAGE] else{return}
                                    guard let userProfileImageUID = data[PROFILE_IMAGE_UID] else{return}
                                    
                                    let post: Dictionary<String, AnyObject> = [
                                        
                                        USER_NAME: userName,
                                        USER_IMAGE: userImage,
                                        POST_IMAGE_URL: postImageURL as AnyObject,
                                        LIKES: 0 as AnyObject,
                                        POST_IMAGE_UID: postImageUID as AnyObject,
                                        PROFILE_IMAGE_UID: userProfileImageUID
                                    ]
                                    
                                    let firebasePost = Database.database().reference().child(POST).childByAutoId()
                                    firebasePost.setValue(post)
                                }
                            }
                        }
                    }
                }
            })
        }
    }
}




















