//
//  TweetsViewController.swift
//  MyTwitter
//
//  Created by Barbara Ristau on 1/22/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit


class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, TweetAction {
  
  var tweets: [Tweet]?
  var tweetID: String?
  var tweet: Tweet?

  
  @IBOutlet weak var logoutButton: UIButton!

  // infinite scrolling properties
  var isMoreDataLoading = false
  var loadingMoreView: InfiniteScrollActivityView?


  // UIRefreshControl
  let refreshControl = UIRefreshControl()
  
  @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
      
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
    
        // Implement refresh control
        // Bind action to refresh control & add to tableview
        self.refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        self.tableView.insertSubview(refreshControl, at: 0)
  
      
        // Setting up tableview
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
      
      makeNetworkCall()
 
  }
  

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.tableView.reloadData()
    
    let navBar = self.navigationController?.navigationBar
    navBar?.isTranslucent = false
    navBar?.barTintColor =  UIColor(red:0.00, green:0.67, blue:0.93, alpha:1.0) // hex 00ACED
    self.navigationItem.title = "Timeline"
  }
  

  // MARK: - TableView Methods
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
    return tweets?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell

    cell.selectionStyle = .none
    
    if let tweet = tweets?[indexPath.row] {
      cell.tweet = tweet
      cell.tweetActionDelegate = self

      cell.saveButton.tag = indexPath.row
      cell.profileButton.tag = indexPath.row
      cell.replyButton.tag = indexPath.row
    }
    
    cell.contentView.setNeedsLayout()
    cell.contentView.layoutIfNeeded()
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    print("Row \(indexPath.row) selected")
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
    cell.backgroundColor = UIColor.red
    
    tableView.reloadData()
    
  }
  
  
    // MARK: - ScrollView & Refresh Control
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {

    if (!isMoreDataLoading) {
      
      /// Calculate the position of one screen length before the bottom of the results 
      let scrollViewContentHeight = tableView.contentSize.height
      let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
      
      // When the user has scrolled past the threshold, start requesting 
      if (scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
        isMoreDataLoading = true
        
        // Update position of loadingMOreView, and start loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView?.frame = frame
        loadingMoreView!.startAnimating()
        
        // code to load more results
        loadMoreData()
      }
    }
  }
  
  func refreshControlAction(_ refreshControl: UIRefreshControl) {
    
    refreshData()
    
  }
  
  
  // MARK: - Network Call
  
  func makeNetworkCall() {
    
    // Getting the tweets via the API
    TwitterClient.sharedInstance.homeTimeline(success: { (tweets: [Tweet]) -> () in
      self.tweets = tweets
      self.tableView.reloadData()
      
    }, failure: { (error: Error) -> () in
      print("Error: \(error.localizedDescription)")
    })
  }
  
  func loadMoreData() {
    print("Now loading more data")
    
      let numTweets = tweets?.count
      let lastTweet: Tweet = (tweets?[numTweets!-1])!
      let maxID = lastTweet.id
    
    TwitterClient.sharedInstance.loadMoreHomeTimeline(oldestTweetID: maxID!, success: (success: { (newTweets: [Tweet]) -> () in
      
      self.tweets?.append(contentsOf: newTweets)
      self.isMoreDataLoading = false
      self.loadingMoreView!.stopAnimating()
      
      for tweet in newTweets {
        print("Older Tweet: \(tweet.text!)")
      }
      
      self.tableView.reloadData()
      
    }), failure: { (error: Error) -> () in
      print("Error: \(error.localizedDescription)")
    })
  }
  
  func refreshData() {
    print("Now refreshing for more recent data")
    
    let mostRecentTweet = tweets?[0]
    let sinceID = mostRecentTweet?.id
    
    TwitterClient.sharedInstance.getMostRecentHomeTimeline(mostRecentTweetID: sinceID!, success: (success: { (newTweets: [Tweet]) -> () in
      
      self.tweets?.insert(contentsOf: newTweets, at: 0)
      
      for tweet in newTweets {
        print("Recent Tweet: \(tweet.text!)")
      }
      
      self.tableView.reloadData()
      self.refreshControl.endRefreshing()
      
    }), failure: { (error: Error) -> () in
      print("Error: \(error.localizedDescription)")
    })
  }

  // MARK: - Tweet Action Protocol
  
  func onFavButtonClicked(tweetCell: TweetCell){
    
    if tweetCell.tweet.favorited == false {
     
      TwitterClient.sharedInstance.createFav(params: ["id": tweetCell.tweetID], success: { (tweet) -> () in
        
        tweetCell.tweet.favoritesCount = Tweet.getFavCount(tweet: tweet!)
        tweetCell.favoriteCountLabel.text = String(describing: tweetCell.tweet.favoritesCount!)
        tweetCell.tweet.favorited = true
        tweetCell.setFavoriteLabels()
        print("Saved Tweet. Fav count is: \(tweet!.favoritesCount!) and \(tweetCell.tweet.favoritesCount!) Status is \(tweetCell.tweet.favorited!)")
        
       }, failure: { (error: Error) -> () in
        print("Could not successfully save tweet.  Error: \(error.localizedDescription)")
      })

    } else if tweetCell.tweet.favorited == true {
      TwitterClient.sharedInstance.unSaveAsFavorite(params: ["id": tweetCell.tweetID!], success: { (tweet) -> () in
        
        tweetCell.tweet.favoritesCount = Tweet.getFavCount(tweet: tweet!)
        tweetCell.favoriteCountLabel.text = String(describing: tweetCell.tweet.favoritesCount!)
        tweetCell.tweet.favorited = false
        tweetCell.setFavoriteLabels()
        print("Removed from saved tweets.  Fav Count is \(tweet!.favoritesCount!) and \(tweetCell.tweet.favoritesCount!) . Status is \(tweetCell.tweet.favorited!)")
        
        
        
      }, failure: { (error: Error) -> () in
        print("Error: \(error.localizedDescription)")
      })
    }
  
  }
  
  func onRetweetButtonClicked(tweetCell: TweetCell){
    
    if tweetCell.tweet.retweeted == false {
    
    TwitterClient.sharedInstance.retweet(params: ["id": tweetCell.tweetID!], success: { (tweet) -> () in
      
      tweetCell.tweet.retweetCount = (tweet?.retweetCount!)
      tweetCell.retweetCountLabel.text = String(describing: tweetCell.tweet.retweetCount!)
      tweetCell.tweet.retweeted = true
      tweetCell.setRetweetLabels()
      print("Retweeted. RT count is: \(tweet!.retweetCount!). Status is \(tweet!.retweeted!)")
    
    } , failure: { (error: Error) -> () in
      print("Error: \(error.localizedDescription)")
    })
    } else if tweetCell.tweet.retweeted == true {
      
      TwitterClient.sharedInstance.unRetweet(params: ["id": tweetCell.tweetID!], success: { (unretweeted) -> () in
        
        tweetCell.tweet.retweetCount = ((unretweeted?.retweetCount!)!-1)
        tweetCell.retweetCountLabel.text = String(describing: tweetCell.tweet.retweetCount!)
        tweetCell.tweet.retweeted = false
        tweetCell.setRetweetLabels()
        print("Unretweeted. RT count is: \(unretweeted!.retweetCount!). Status is \(unretweeted!.retweeted!)")
        
      } , failure: { (error: Error) -> () in
        print("Error: \(error.localizedDescription)")
      })
    }
  }

  
// MARK: - On Profile Tap 
  
  
  @IBAction func onProfileTap(_ sender: Any) {
    print("Tapped on profile")
  }
  

// MARK: - Compose Tweet 

  func onComposeTweetButtonClicked(tweetText: String) {
    
    TwitterClient.sharedInstance.publishTweet(text: tweetText) { newTweet in
      self.tweets?.insert(newTweet, at: 0)
      self.tableView.reloadData()
    }
  }
  
  func onReplyTweetButtonClicked(tweetText: String, replyID: NSNumber) {

    TwitterClient.sharedInstance.replyTweet(text: tweetText, replyToTweetID: replyID) { newTweet in
      self.tweets?.insert(newTweet, at: 0)
      self.tableView.reloadData()
    }
  }
  
  
  // MARK: - Logout
  
  @IBAction func onLogout(_ sender: UIButton) {
    print("Tapped on logout")
    TwitterClient.sharedInstance.logout()
  }
  
  
  
    // MARK: - Navigation
  
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
      if segue.identifier == "Detail" {
   
        let cell = sender as! TweetCell
        let sendingTweet = cell.tweet
  
        let detailVC = segue.destination as! TweetDetailViewController
        detailVC.tweet = sendingTweet
      }
      
      if segue.identifier == "FromTableViewToProfileView"{
        
        print("Going to Profile View from the home timeline ")
        let button = sender as! UIButton
        let index = button.tag
        let tweet = tweets?[index]
        print("TWEET TO SEND IS: \(tweet!.text!)")
        
        let userToSend = tweet!.user
        print("USER TO BE VIEWED IS: \(tweet!.user!.name!)")
      
        let profileVC = segue.destination as! ProfileViewController
        profileVC.user = userToSend
        
      }
      
      //ReplyFromTableView
      
      if segue.identifier == "ReplyFromTableView" {
        
        print("Replying to the Tweet from the TableView")
        
        let button = sender as! UIButton
        let index = button.tag
        let tweet = tweets?[index]
        
        let replyNavVC = segue.destination as? UINavigationController
        let replyVC = replyNavVC?.viewControllers.first as! ComposeTweetViewController
        replyVC.replyTweetDelegate = self
        replyVC.replyTweet = tweet
        replyVC.isReply = true

      }
      
      if segue.identifier == "Compose" {
        
        let composeTweetNavVC = segue.destination as? UINavigationController
        let composeVC = composeTweetNavVC?.viewControllers.first as! ComposeTweetViewController
        composeVC.composeTweetDelegate = self
        
      }
      
     }
  }



extension TweetAction {
  func onDetailFavButtonClicked(tweetCell: ActionsCell){
    // leaving this empty
  }
  func onDetailRetweetButtonClicked(tweetCell: ActionsCell) {}
}

