//
//  User.swift
//  MyTwitter
//
//  Created by Barbara Ristau on 1/22/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit

class User: NSObject {
  
  var name: String?
  var screenname: String?
  var profileUrl: URL?
  //var tagline: String?
  var followersCount: Int?
  var followingCount: Int?
  
  var dictionary: NSDictionary?
  
  init(dictionary: NSDictionary) {
    
    self.dictionary = dictionary
    
    name = dictionary["name"] as? String
    screenname = dictionary["screen_name"] as? String
    
    if let profileUrlString = dictionary["profile_image_url_https"] as? String {
      profileUrl = URL(string: profileUrlString)
    }
    
 //   tagline = dictionary["description"] as? String
    //followersCount = dictionary["followers_count"] as? Int
    //followingCount = dictionary["friends_count"] as? Int
    
    followersCount = 10
    followingCount = 20
    
  }
  
  // Setting up Persisitence for Current User
  
  static let userDidLogoutNotification = "UserDidLogout"
  static var _currentUser: User?
  
  class var currentUser: User? {
    
    get {
      
      if _currentUser == nil {
        
        let defaults = UserDefaults.standard
        let userData = defaults.object(forKey: "currentUserData") as? Data
        
        if let userData = userData{
          
          let dictionary = try! JSONSerialization.jsonObject(with: userData, options: .allowFragments)
          _currentUser = User(dictionary: dictionary as! NSDictionary)
        }
      }
      
      return _currentUser
    }

    
    set(user) {
      _currentUser = user
      
      let defaults = UserDefaults.standard
      
      if let user = user {
        let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
        defaults.set(data, forKey: "currentUserData")
      } else {
        defaults.set(nil, forKey: "currentUserData")
      }
  
      
      defaults.synchronize()
      
    }
    
    
  }
  
  
  
  
}
