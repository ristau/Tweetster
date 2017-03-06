//
//  TweetCell.swift
//  MyTwitter
//
//  Created by Barbara Ristau on 1/23/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit
import AFNetworking

class TweetCell: UITableViewCell {


  
  @IBOutlet weak var favoriteCountLabel: UILabel!
  @IBOutlet weak var saveButton: UIButton!
  
  @IBOutlet weak var retweetCountLabel: UILabel!
  @IBOutlet weak var retweetButton: UIButton!

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var screenNameLabel: UILabel!
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var dateTextLabel: UILabel!
  
  @IBOutlet weak var tweetTextLabel: UILabel!
  
  @IBOutlet weak var replyButton: UIButton!
  @IBOutlet weak var profileButton: UIButton!
  
  var tweetActionDelegate: TweetAction!
  var tweetID: String!

  // Date Related Variables
  var dateFormatter = DateFormatter()
  let calendar = NSCalendar.current
  let currentDate = Date()
  
  
  var tweet: Tweet! {
    
    didSet {
      
      tweetTextLabel.text = tweet.text
      
      nameLabel.text = tweet.user?.name!
      screenNameLabel.text = ("@" + (tweet.user?.screenname!)!)
      
      if let profileUrl = tweet.user?.profileUrl {
        profileImage.setImageWith(profileUrl)
      }
      
      setTweetID()
      setTweetCounts()
      setFavoriteLabels()
      setRetweetLabels()
      setReplyButtonStyling()
      
      
      // SET DATE AND TIME BASED ON INTERVALS
      if let date = tweet?.timestamp {
        
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short

        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = DateComponentsFormatter.UnitsStyle.short
        dateComponentsFormatter.allowedUnits = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.hour, NSCalendar.Unit.minute]
        // above is full example, will shorten below based on selected time interval
  
        let oneDayAgo = Date(timeIntervalSinceNow: -60 * 60 * 24)
        let oneHourAgo = Date(timeIntervalSinceNow: -60*60)
        
        if date.timeIntervalSinceReferenceDate > oneHourAgo.timeIntervalSinceReferenceDate {
      
          dateComponentsFormatter.allowedUnits = [NSCalendar.Unit.minute]
          let minutesDifference = dateComponentsFormatter.string(from: date, to: currentDate)
          dateTextLabel.text = minutesDifference! + " ago"
  
        } else if date.timeIntervalSinceReferenceDate > oneDayAgo.timeIntervalSinceReferenceDate {
          dateComponentsFormatter.allowedUnits = [NSCalendar.Unit.hour]
          let hourDifference = dateComponentsFormatter.string(from: date, to: currentDate)
          dateTextLabel.text = hourDifference! + " ago"
          
        } else {
          dateTextLabel.text = dateFormatter.string(from: date)
        }
      }  // end set up time and date
    } // end set up tweet
  }


    override func awakeFromNib() {
        super.awakeFromNib()
      
      profileImage.layer.cornerRadius = 3
      profileImage.clipsToBounds = true
      
    }

     override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
    }

  // MARK: - SET ID AND COUNT

  func setTweetID(){
    
    tweetID = Tweet.getTweetID(tweet: tweet)
  }
  
  func setTweetCounts() {
    
    favoriteCountLabel.text = String(describing: (Tweet.getFavCount(tweet: tweet)))
    retweetCountLabel.text = String(describing: tweet.retweetCount!)
    
  }
  
  // MARK: - SAVE/UNSAVE AS FAVORITE & RETWEET/UNRETWEET
  
  @IBAction func onSave(_ sender: UIButton) {
    
    self.tweetActionDelegate.onFavButtonClicked(tweetCell: self)
    
  }
 
  @IBAction func onRetweet(_ sender: Any) {
  
    self.tweetActionDelegate.onRetweetButtonClicked(tweetCell: self)
  }
  
  // MARK: - REPLY TO TWEET 
  
 
  @IBAction func onReply(_ sender: UIButton) {
    print("Clicked on Reply")
    
  }
  
  
  // MARK: - LAYOUT FOR FAVORITES AND RETWEETS
  
  func setFavoriteLabels() {
    
      if tweet.favorited! {
        self.favoriteCountLabel.textColor = UIColor.red
        self.saveButton.setImage(#imageLiteral(resourceName: "unsave_redFill16"), for: .normal)
      } else if tweet.favorited == false {
        self.favoriteCountLabel.textColor = UIColor.darkGray
        self.saveButton.setImage(#imageLiteral(resourceName: "save_greyFill16"), for: .normal)
      }
  }

  func setRetweetLabels() {
    
    if tweet.retweeted! {
        self.retweetCountLabel.textColor = UIColor(red:0.05, green:0.87, blue:0.11, alpha:1.0)
        self.retweetButton.setImage(#imageLiteral(resourceName: "retweetGreenFill16"), for: .normal)
      }  else if tweet.retweeted == false {
        self.retweetCountLabel.textColor = UIColor.darkGray
        self.retweetButton.setImage(#imageLiteral(resourceName: "retweet_greyFill16"), for: .normal)
      }
    }
    

  func setReplyButtonStyling() {
    self.replyButton.setImage(#imageLiteral(resourceName: "reply_grey16"), for: .normal)
    self.replyButton.setImage(#imageLiteral(resourceName: "reply_tweetBlue16"), for: .highlighted)
  }

}




  

