//
//  ActionsCell.swift
//  MyTwitter
//
//  Created by Barbara Ristau on 2/10/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit

class ActionsCell: UITableViewCell {

  var originalTweetID: String?
 
  var tweet: Tweet! {
    
    didSet {
      
      if let retweetedStatus = tweet.retweetedStatus {
        let retweet = Tweet.tweetAsDictionary(tweet.retweetedStatus!)
        originalTweetID = retweet.idStr
        
      } else {
        originalTweetID = tweet.idStr
      }

      
      
    }
    
  }
  
  
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  
  @IBAction func onFavorite(_ sender: UIButton) {
    print("pressed on Favorite")
  }
  
  @IBAction func onRetweet(_ sender: UIButton) {
    print("pressed on retweet")
  }
  
  
  @IBAction func onReply(_ sender: UIButton) {
    print("pressed on reply")
  }
  
  
  
  

}
