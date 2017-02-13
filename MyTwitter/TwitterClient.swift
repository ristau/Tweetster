//
//  TwitterClient.swift
//  MyTwitter
//
//  Created by Barbara Ristau on 1/22/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {

  static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com")!, consumerKey: "BjhrMfOq3vpYwqTj5F6Lc726A", consumerSecret: "CDZDMUMckjJwq5Za3C68oMnNpIeCVgucBDjulB6fDgOh2Ex9vF")!
  
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
  
  
  func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
    
    loginSuccess = success
    loginFailure = failure
    
    TwitterClient.sharedInstance.deauthorize()
    
    TwitterClient.sharedInstance.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "mytwitter://oauth"), scope: nil, success: ( { (requestToken:BDBOAuth1Credential?) -> Void in
      
      if let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken!.token!)") {
        
        print("token is valid")
        UIApplication.shared.open(authURL, options: [:], completionHandler: nil)
        
      } else { print("invalid token") }
      
      
    }), failure: { (error: Error?) -> Void in
      print("error: \(error?.localizedDescription)")
      self.loginFailure?(error!)
    })
  }
  
  func handleOpenUrl(url: URL) {
    
    let requestToken = BDBOAuth1Credential(queryString: url.query)
    
    fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) -> Void in
      
      self.currentAccount(success: { (user: User) -> () in
        User.currentUser = user
        self.loginSuccess?()

      }, failure: { (error: Error) -> () in
             self.loginFailure?(error)
      })
      
      
    }, failure: { (error: Error?) -> Void in
        print("error: \(error?.localizedDescription)")
        self.loginFailure?(error!)

    } )
  
    
  }
  
  
  
  func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
    
    // getting the tweets
    get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task:  URLSessionDataTask, response: Any) -> Void in
      
      let dictionaries = response as! [NSDictionary]
      let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
      success(tweets)
    
    }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
       failure(error)
    })
  }
  
  

  func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
    
    // getting user
    get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any) -> Void in
      
      let userDictionary = response as? NSDictionary
      let user = User(dictionary: userDictionary!)
      
      success(user)
      
      print("name: \(user.name!)")
      print("screenname: \(user.screenname!)")
      print("profileurl: \(user.profileUrl!)")
      //print("description: \(user.tagline!)")
      
    }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
        failure(error)

    })
  }
  
  // MARK: - SAVE AND UNSAVE AS FAVORITE
  
  // save to favorites
  func createFav(params: NSDictionary?, success: @escaping (_ tweet: Tweet?) -> (), failure: @escaping (Error) -> ()) {
    
    // getting the tweets
    post("1.1/favorites/create.json", parameters: params, progress: nil, success: { (task:  URLSessionDataTask, response: Any) -> Void in
      
      //api.twitter.com/1.1/favorites/create.json?id=243138128959913986
      //\(params!).json
      
      let tweet = Tweet.tweetAsDictionary(response as! NSDictionary)
     
      success(tweet)
      
    }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
       failure(error)
    })
  }
  

  // save to favorites
  func unSaveAsFavorite(params: NSDictionary?, success: @escaping (_ tweet: Tweet?) -> (), failure: @escaping (Error) -> ()) {
    
    // getting the tweets
    post("1.1/favorites/destroy.json", parameters: params, progress: nil, success: { (task:  URLSessionDataTask, response: Any) -> Void in
      
      let tweet = Tweet.tweetAsDictionary(response as! NSDictionary)
      
      success(tweet)
      
    }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
      failure(error)
    })
  }
  
  
  // MARK: - RETWEET AND UNRETWEET
  
  func retweet(params: NSDictionary?, success: @escaping (_ tweet: Tweet?) -> (), failure: @escaping (Error) -> ()) {
    
    // getting the tweets
    post("1.1/statuses/retweet/\(params!["id"]!).json", parameters: params, progress: nil, success: { (task:  URLSessionDataTask, response: Any) -> Void in
      
      let tweet = Tweet.tweetAsDictionary(response as! NSDictionary)
      
      success(tweet)
    
    }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
        failure(error)
    })
  }
  
  func getRetweetID(params: NSDictionary?, success: @escaping (_ tweet: Tweet?) -> (), failure: @escaping (Error) -> ()) {
    
    // getting the tweets
    post("1.1/statuses/statuses/show/\(params!["id"]!).json?include_my_retweet=1", parameters: params, progress: nil, success: { (task:  URLSessionDataTask, response: Any) -> Void in
      
      let tweet = Tweet.tweetAsDictionary(response as! NSDictionary)
      print("TWEET WITH ID: \(tweet)") 
      
      success(tweet)

      
    }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
      failure(error)
    })
  }
  
 
  
  
  func unRetweet(params: NSDictionary?, success: @escaping (_ tweet: Tweet?) -> (), failure: @escaping (Error) -> ()) {
    
    // getting the tweets
    post("1.1/statuses/unretweet/\(params!["id"]!).json", parameters: params, progress: nil, success: { (task:  URLSessionDataTask, response: Any) -> Void in
      
      let tweet = Tweet.tweetAsDictionary(response as! NSDictionary)
      
      success(tweet)
      
    }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
      failure(error)
    })
  }

  
  // MARK: COMPOSE & REPLY TWEET
  
  
  func publishTweet(text: String, success: @escaping (Tweet) -> ()) {
  
    guard text.characters.count > 0 else {
      return
    }
    let params = ["status": text] as [String : Any]
    post("1.1/statuses/update.json", parameters: params, success: { (operation: URLSessionDataTask, response: Any?) -> Void in
      let tweet = Tweet(dictionary: response as! NSDictionary)
      success(tweet)
    })
  }
  
  func replyTweet(text: String, replyToTweetID: NSNumber?, success: @escaping (Tweet) -> ()) {
 
    guard text.characters.count > 0 else {
      return
    }
    
    let params = ["status": text, "in_reply_to_status_id": Int(replyToTweetID!)] as [String : Any]
    post("1.1/statuses/update.json", parameters: params, progress: nil, success: { (task:  URLSessionDataTask, response: Any) -> Void in
      let tweet = Tweet(dictionary: response as! NSDictionary)
      success(tweet)
    })
  }
  
  
  
  
  // MARK: - LOGOUT
  
  func logout() {
    User.currentUser = nil
    deauthorize()
    
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
  }
  
  
  
}
