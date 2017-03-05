//
//  TweetAction.swift
//  MyTwitter
//
//  Created by Barbara Ristau on 3/4/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import Foundation

protocol TweetAction {
  
  func onFavButtonClicked(tweetCell: TweetCell)
  func onDetailFavButtonClicked(tweetCell: ActionsCell)
  
  func onDetailRetweetButtonClicked(tweetCell: ActionsCell)
  func onRetweetButtonClicked(tweetCell: TweetCell)
  
  func onComposeTweetButtonClicked(tweetText: String)
  func onReplyTweetButtonClicked(tweetText: String, replyID: NSNumber)

}
