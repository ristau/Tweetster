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
        self.navigationItem.title = "My Tweets"
       // UIColor(red:0.75, green:0.92, blue:0.95, alpha:1.0) // hex# beebf3
      
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
    
    let refreshURL = URL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
    var request = URLRequest(url: refreshURL!)
    request.httpMethod = "get"
    
    //let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    //let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in

    let session = URLSession.shared
    
    session.dataTask(with: request) {data, response, Error in
      // update data
      print("Refreshing the data")
      
      // reload tableview
      self.tableView.reloadData()
      
      // tell the refresh control to stop spinning
      refreshControl.endRefreshing()
      
      
      }.resume()
  }
  
  // MARK: - Logout
  
  
  @IBAction func logout(_ sender: UIBarButtonItem) {
      TwitterClient.sharedInstance.logout()
  }
  
  // MARK: - Network Call
  
  func makeNetworkCall() {
    
    // Getting the tweets via the API
    TwitterClient.sharedInstance.homeTimeline(success: { (tweets: [Tweet]) -> () in
      self.tweets = tweets
      
      for tweet in tweets {
        print("tweet: \(tweet.text!)")
        print("1. retweeted: \(tweet.retweeted!)")
        print("2. favorited: \(tweet.favorited!)")
        print("3. idStr: \(tweet.idStr!)")
        print("4. id: \(tweet.id!)")
        
        if let retweetedStatus = tweet.retweetedStatus {
          let retweet = Tweet.tweetAsDictionary(tweet.retweetedStatus!)
          let originalID = retweet.idStr
          print("5. Retweet: \(originalID!)")
        } else {
          print("5. not a retweet")
        }
        
        if tweet.currentUserRetweet != nil {
          print("6. currentUserRetweet:\(tweet.currentUserRetweet!)")
        }
        
        print("7. Fav Count: \(tweet.favoritesCount!)")
        
        self.tableView.reloadData()
      }
      
    }, failure: { (error: Error) -> () in
      print("Error: \(error.localizedDescription)")
    })
  }
  
  func loadMoreData() {
    
    let loadMoreURL = URL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
    var request = URLRequest(url: loadMoreURL!)
    request.httpMethod = "get"
    
    let session = URLSession.shared
    
    session.dataTask(with: request) {data, response, Error in
      print("Entered the completion handler")
      
      
    }.resume()
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
  
 
  //func goToProfile(_ sender: Any, tweet: Tweet) {
  func goToProfile(sender: UIButton) {
    
    print("Tapped on Button") 
    print("Going to Profile View")
    let index = sender.tag
    let tweet = tweets?[index]
    print("TWEET TO SEND IS: \(tweet!.text!)")
    
    let userToSend = tweet!.user
    print("USER TO BE VIEWED IS: \(tweet!.user!.name!)")
    let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileView") as! ProfileViewController
    profileVC.user = userToSend

    self.performSegue(withIdentifier: "FromTableViewToProfileView", sender: self)
    
  }
  
  
  @IBAction func onProfileTap(_ sender: Any) {
    print("Tapped on profile")
  }
  
  
  
  @IBAction func composeTweet(_ sender: UIBarButtonItem) {
    print("Going to compose tweet") 
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
        
        print("Going to Profile View")
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
