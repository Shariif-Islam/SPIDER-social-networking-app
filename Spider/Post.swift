//
//  Post.swift
//  Spider
//
//  Created by myth on 12/11/17.
//  Copyright © 2017 myth. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _userName: String!
    private var _userProfileImage: String!
    private var _postImageURL: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _postRef: DatabaseReference!
    private var _profileImageUID: String!
    private var _postImgeUID: String!
    
    var userName: String {
        return _userName
    }
    var userProfileImage: String {
        return _userProfileImage
    }
    var postImageURL: String {
        
        get { return _postImageURL }
        set { _postImageURL = postImageURL}
    }
    var likes: Int {
        return _likes
    }
    var postKey: String {
        return _postKey
    }
    var postImgeUID: String {
        
        get { return _postImgeUID }
        set { _postImgeUID = postImgeUID }
    }
    var profileImgeUID: String {
        
        get { return _profileImageUID }
        set { _profileImageUID = profileImgeUID }
    }
    
    init(postImageURL: String, likes: Int, userName: String, userProfileImage: String) {
        _postImageURL = postImageURL
        _likes = likes
        _userName = userName
        _userProfileImage = userProfileImage
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        
        _postKey = postKey
        
        if let userName = postData[USER_NAME] as? String {
            _userName = userName
        }
        if let userProfileImage = postData[USER_IMAGE] as? String {
            _userProfileImage = userProfileImage
        }
        if let postImageURL = postData[POST_IMAGE_URL] as? String {
            _postImageURL = postImageURL
        }
        if let likes = postData[LIKES] as? Int {
            _likes = likes
        }
        if let postImgeUID = postData[POST_IMAGE_UID] as? String {
            _postImgeUID = postImgeUID
        }
        if let profileImgeUID = postData[PROFILE_IMAGE_UID] as? String {
            _profileImageUID = profileImgeUID
        }

        _postRef = Database.database().reference().child(POST).child(_postKey)
    }
    
    func adJustLikes(addLike: Bool) {

        if addLike {
            _likes = likes + 1
        } else {
            _likes = likes - 1
        }
        _postRef.child(LIKES).setValue(_likes)
    }
}





















