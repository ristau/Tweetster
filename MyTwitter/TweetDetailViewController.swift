//
//  TweetDetailViewController.swift
//  MyTwitter
//
//  Created by Barbara Ristau on 2/10/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DetailCellDelegator, TweetAction {

  
  @IBOutlet weak var tableView: UITableView!
  
  var tweet: Tweet!
  var replies: [Tweet]!

    override func viewDidLoad() {
        super.viewDidLoad()

      self.navigationItem.title = "Detail"
      
      tableView.dataSource = self
      tableView.delegate = self
      
      tableView.rowHeight = UITableViewAutomaticDimension
      
      tableView.reloadData()
      
  }
  

  
  
  // MARK: - TABLEVIEW LOADING METHODS
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    switch section {
      
    case 0, 1, 2 :
      return 1
    
      
    default:
      return 0
    }
  }
  
  
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    switch indexPath.section {
      
    case 0:
      return 65
    
    case 1:
      return 200
      
    case 2:
      return 100

    
    default:
      return 44
    }
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = UITableViewCell()
    cell.selectionStyle = .none
    
    
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
      cell.delegate = self 
      cell.tweet = tweet
    }
    
    if indexPath.section == 1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTextCell", for: indexPath) as! TweetTextCell
      cell.tweet = tweet
    }
    
    if indexPath.section == 2 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ActionsCell", for: indexPath) as! ActionsCell
      cell.tweet = tweet
      cell.ActionCellDelegate = self
    }
    
    cell.contentView.setNeedsLayout()
    cell.contentView.layoutIfNeeded()

    return cell
  }
  
  func callSegueFromCell(myData dataobject: User) {
    let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileView") as! ProfileViewController
    let userToSend = dataobject
    profileVC.user = userToSend
    self.navigationController?.pushViewController(profileVC, animated: true)
    
  }
  
  @IBAction func composeTweet(_ sender: UIBarButtonItem) {
    print("Going to compose tweet") 
  }

  
// MARK: - TweetAction Protocol Methods
  
  func onDetailFavButtonClicked(tweetCell: ActionsCell) {
    
    if tweetCell.tweet.favorited == false {
      
      TwitterClient.sharedInstance.createFav(params: ["id": tweetCell.tweetID], success: { (tweet) -> () in
      
        tweetCell.tweet.favoritesCount = Tweet.getFavCount(tweet: tweet!)
        tweetCell.favoriteCountLabel.text = String(describing: tweetCell.tweet.favoritesCount!)
        tweetCell.tweet.favorited = true
        tweetCell.setFavoriteLabels()
        print("Saved Tweet. Fav count is: \(tweet!.favoritesCount!) and \(tweetCell.tweet.favoritesCount!). Status is \(tweetCell.tweet.favorited!)")
        
      }, failure: { (error: Error) -> () in
        print("Could not successfully save tweet.  Error: \(error.localizedDescription)")
      })
      
    } else if tweetCell.tweet.favorited == true {
      TwitterClient.sharedInstance.unSaveAsFavorite(params: ["id": tweetCell.tweetID!], success: { (tweet) -> () in
        tweetCell.tweet.favoritesCount = Tweet.getFavCount(tweet: tweet!)
        tweetCell.favoriteCountLabel.text = String(describing: tweetCell.tweet.favoritesCount!)
        tweetCell.tweet.favorited = false
        tweetCell.setFavoriteLabels()
        print("Removed from saved tweets.  Fav Count is \(tweet!.favoritesCount!) and \(tweetCell.tweet.favoritesCount!). Status is \(tweetCell.tweet.favorited!)")
        
        
        
      }, failure: { (error: Error) -> () in
        print("Error: \(error.localizedDescription)")
      })
    }
  }
  
  func onDetailRetweetButtonClicked(tweetCell: ActionsCell) {
  
    if tweetCell.tweet.retweeted == false {
      
      TwitterClient.sharedInstance.retweet(params: ["id": tweetCell.tweetID!], success: { (tweet) -> () in
        
        tweetCell.tweet.retweetCount = (tweet?.retweetCount)!
        tweetCell.retweetCountLabel.text = String(describing: tweetCell.tweet.retweetCount!)
        tweetCell.tweet.retweeted = true
        tweetCell.setRetweetLabels()
        print("Retweeted. RT count is: \(tweet!.retweetCount!). Status is \(tweet!.retweeted!)")
        
      } , failure: { (error: Error) -> () in
        print("Error: \(error.localizedDescription)")
      })
    } else if tweetCell.tweet.retweeted == true {
      
      TwitterClient.sharedInstance.unRetweet(params: ["id": tweetCell.tweetID!], success: { (unretweeted) -> () in
        
        tweetCell.tweet.retweetCount = ((unretweeted?.retweetCount)!-1)
        tweetCell.retweetCountLabel.text = String(describing: tweetCell.tweet.retweetCount!)
        tweetCell.tweet.retweeted = false
        tweetCell.setRetweetLabels()
        print("Unretweeted. RT count is: \(unretweeted!.retweetCount!). Status is \(unretweeted!.retweeted!)")
        
      } , failure: { (error: Error) -> () in
        print("Error: \(error.localizedDescription)")
      })
    }
  }
  
  func onComposeTweetButtonClicked(tweetText: String) {
    
    print("This is the tweet: \(tweetText)")
    TwitterClient.sharedInstance.publishTweet(text: tweetText) { newTweet in
    }
  }
  
  func onReplyTweetButtonClicked(tweetText: String, replyID: NSNumber) {
    
  }
  
  
  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
      if segue.identifier == "ReplyTweet"{
        
        print("About to Reply to the Tweet")
        
        let replyNavVC = segue.destination as? UINavigationController
        let replyVC = replyNavVC?.viewControllers.first as! ComposeTweetViewController
        replyVC.composeTweetDelegate = self 
        replyVC.replyTweet = tweet
        replyVC.isReply = true
        
      }
      
      if segue.identifier == "ComposeTweet" {
        
        let composeTweetNavVC = segue.destination as? UINavigationController
        let composeVC = composeTweetNavVC?.viewControllers.first as! ComposeTweetViewController
        composeVC.composeTweetDelegate = self
        
      }
      
    }
}

extension TweetAction {
  
  func onFavButtonClicked(tweetCell: TweetCell){}
  func onRetweetButtonClicked(tweetCell: TweetCell){}
  func onComposeTweetButtonClicked(tweetText: String) {}
}


