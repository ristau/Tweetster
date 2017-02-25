//
//  TweetsViewController.swift
//  MyTwitter
//
//  Created by Barbara Ristau on 1/22/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit


class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
  
  var tweets: [Tweet]?
  var tweetID: String?
  var tweet: Tweet?
  
  var saveCountLabel: UILabel?
  var saveButton: UIButton?

  @IBOutlet weak var logoutButton: UIButton!

  // infinite scrolling properties
  var isMoreDataLoading = false
  var loadingMoreView: InfiniteScrollActivityView?

  // UIRefreshControl
  let refreshControl = UIRefreshControl()
  
  // date formatter 
  let dateFormatter = DateFormatter()
  

  @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Timeline"
      
        // Customize Logout Button
      //logoutButton.setImage(#imageLiteral(resourceName: "logoutWhite24"), for: .normal)
      //logoutButton.setTitle("Logout", for: .normal)
      //logoutButton.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0)
      //logoutButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
      
      
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
    self.tableView.reloadData()
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    self.tableView.reloadData()
  }
 

  // MARK: - TableView Methods
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
    return tweets?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
  

    //cell.backgroundColor = UIColor(red:0.92, green:0.98, blue:0.99, alpha:1.0) // hex# ebfbfd // color for retweet and save

    cell.selectionStyle = .none
    
    if let tweet = tweets?[indexPath.row] {
      cell.tweet = tweet
      cell.profileButton.tag = indexPath.row
      cell.replyButton.tag = indexPath.row
    }
    
    cell.contentView.setNeedsLayout()
    cell.contentView.layoutIfNeeded()
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
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

  
  
  
// MARK: - SAVING & UNSAVING AS FAVORITE
  
 @IBAction func onSave(_ sender: UIButton!) {

      let buttonTag = (self.saveButton?.tag)!
  
      tweet = tweets?[buttonTag]
  
      TwitterClient.sharedInstance.createFav(params: ["id": tweet!.idStr!], success: { (tweet) -> () in
      
          print("Saving TweetID: \(tweet!.idStr!) to favorites. New Status is: \(tweet!.favorited!).  FavCount is: \(tweet!.favoritesCount!)")
        
        }, failure: { (error: Error) -> () in
          print("Could not successfully save tweet.  Error: \(error.localizedDescription)")
      })
  
      tableView.reloadData()
    }
  
  
  func unSaveAsFavorite() {
    
    TwitterClient.sharedInstance.unSaveAsFavorite(params: ["id": tweetID!], success: { (tweet) -> () in
      
      print("Removing from favorites")

      print("Status after unsaving: \(tweet!.favorited!)")
      self.saveCountLabel?.textColor = UIColor(red:0.12, green:0.51, blue:0.59, alpha:1.0)
      self.saveButton?.setImage(#imageLiteral(resourceName: "save24"), for: .normal)
      self.tableView.reloadData()
    }, failure: { (error: Error) -> () in
      print("Error: \(error.localizedDescription)")
    })
  }
  
  
  @IBAction func onProfileTap(_ sender: Any) {
    print("Tapped on profile")
  }
  

// MARK: - Compose Tweet 
  
  @IBAction func composeTweet(_ sender: UIBarButtonItem) {
    print("Going to compose tweet") 
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
        detailVC.replies = tweets // update this for replies 
        
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
        replyVC.replyTweet = tweet
        replyVC.isReply = true

      }
      
      

     }
  
  }
