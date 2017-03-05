//
//  ActionsCell.swift
//  MyTwitter
//
//  Created by Barbara Ristau on 2/10/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit

class ActionsCell: UITableViewCell {
  
   var ActionCellDelegate: TweetAction!
  
  @IBOutlet weak var favButton: UIButton!
  @IBOutlet weak var retweetButton: UIButton!
  @IBOutlet weak var favoriteCountLabel: UILabel!
  @IBOutlet weak var retweetCountLabel: UILabel!

  var tweetID: String?
  
  
  var tweet: Tweet! {
    
    didSet {
      setTweetId()
      setTweetCounts()
      setFavoriteLabels()
      setRetweetLabels()
      
    }
  }
  
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
  
  
  func setTweetId() -> String {
    
    tweetID = Tweet.getTweetID(tweet: tweet)
    return tweetID!
  }
  
  
  func setTweetCounts() {
    
    favoriteCountLabel.text = String(describing: (Tweet.getFavCount(tweet: tweet)))
    retweetCountLabel.text = String(describing: tweet.retweetCount!)
    
  }
  
  
  
  // MARK: - SAVE / UNSAVE AS FAVORITE & RETWEET / UNRETWEET
  
  
  @IBAction func onFavorite(_ sender: UIButton) {
    
    self.ActionCellDelegate.onDetailFavButtonClicked(tweetCell: self)
    
  }

   @IBAction func onRetweet(_ sender: UIButton) {
    
    self.ActionCellDelegate.onDetailRetweetButtonClicked(tweetCell: self)

  }

  
// MARK: - REPLY

  @IBAction func onReply(_ sender: UIButton) {
    print("pressed on reply")
  }
  
  
  // MARK: - SET LABELS
  

  func setFavoriteLabels() {
  
    if tweet.favorited == true {
        self.favButton.setImage(#imageLiteral(resourceName: "unsave_redFill24"), for: .normal)
      } else if tweet.favorited == false {
        self.favButton.setImage(#imageLiteral(resourceName: "addSaveGrey24"), for: .normal)
      }
  }
    
  func setRetweetLabels() {
  
      if tweet.retweeted == true {
        self.retweetButton.setImage(#imageLiteral(resourceName: "retweetGreenFill24"), for: .normal)
      } else if tweet.retweeted == false {
        self.retweetButton.setImage(#imageLiteral(resourceName: "retweetGreyFill24"), for: .normal)
      }
  }

}
