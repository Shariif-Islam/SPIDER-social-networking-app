//
//  KeyChain.swift
//  Spider
//
//  Created by myth on 10/11/17.
//  Copyright © 2017 myth. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

protocol KeyChainDelegate {
    
    func KCSaveUserSignIn(with userUID: String)
    func KCIsSignIn() -> Bool
    func KCSignOut() -> Bool
    
}

extension KeyChainDelegate {
    
    func KCSaveUserSignIn(with userUID: String) {
        // Store userUID to key chain for remember sign in
        KeychainWrapper.standard.set(userUID, forKey: UID)
    }
    
    func KCIsSignIn() -> Bool {
        // Return true if UID found otherwise return false
        if let _ = KeychainWrapper.standard.string(forKey: UID) {
            return true
        }
        return false
    }

    func KCSignOut() -> Bool {

        do {
             try Auth.auth().signOut()
        } catch {
            return false
        }
        
        KeychainWrapper.standard.removeObject(forKey: UID)
        return true
    }
}
