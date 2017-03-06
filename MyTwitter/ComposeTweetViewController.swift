//
//  ComposeTweetViewController.swift
//  MyTwitter
//
//  Created by Barbara Ristau on 2/11/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController, UITextViewDelegate{

  
  @IBOutlet weak var tweetTextView: UITextView!
  @IBOutlet weak var charCountLabel: UILabel!
  var composeTweetDelegate: TweetAction?
  var replyTweetDelegate: TweetAction?
  
  var user: User!
  var originalCharLimit: Int = 140
  var charLimit: Int!
  var placeholderText = "What's Happening?"
  var tweetContent: String = ""
  var replyTweet: Tweet?
  var author: String?
  var isReply: Bool?
  var replyID: NSNumber?
  var screenName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

      print("Now in Compose Tweet")
      user = User.currentUser
      print("User Name: \(user.name!)")
      tweetTextView.delegate = self
      
      if replyTweet != nil {
        replyID = replyTweet?.id
        screenName = "@" + (replyTweet?.user?.screenname)! + " "
      }
      
    }

  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)

    if replyTweet != nil {
      tweetTextView.text = tweetTextView.text.appending(screenName!)
    }
    else {
      applyPlaceholderStyle(tweetText: tweetTextView, phText: placeholderText)
    }
    
    self.tweetTextView.becomeFirstResponder()
    charLimit = originalCharLimit
    charCountLabel.text = String(describing: originalCharLimit)
    
  }
  
 
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    if textView == tweetTextView && textView.text == placeholderText
    {
      moveCursorToStart(textView: textView)
    }
    return true
  }
  
  func moveCursorToStart(textView: UITextView)
  {
    DispatchQueue.main.async {
      textView.selectedRange = NSMakeRange(0,0)
    }
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
    let newLength = textView.text.utf16.count + text.utf16.count - range.length
    
    if newLength > 0 {
      
      if textView == tweetTextView && textView.text == placeholderText
      {
        if text.utf16.count == 0
        {
          return false
        }
        applyNonPlaceholderStyle(tweetText: textView)
        textView.text = ""
      }
      
      if newLength <= charLimit {
        
        charCountLabel.text = "\(charLimit - newLength)"
      
        
      }
      
      return newLength <= charLimit
      
    } else {
      applyPlaceholderStyle(tweetText: textView, phText: placeholderText)
      moveCursorToStart(textView: textView)
      return false
    }
  }
  
  
  func applyPlaceholderStyle(tweetText: UITextView, phText: String) {
    tweetText.textColor = UIColor.lightGray
    tweetText.text = phText
  }
 
  func applyNonPlaceholderStyle(tweetText: UITextView) {
    tweetText.textColor = UIColor.darkText
    tweetText.alpha = 1.0
  }
  
  
  @IBAction func onCancel(_ sender: UIBarButtonItem) {
    print("Pressed Cancel, Exiting the View Controller")
    dismiss(animated: true, completion: nil)
    
  }
  
  @IBAction func onClear(_ sender: UIButton) {
    print("Pressed Clear")
    tweetTextView.text = ""
    charLimit = originalCharLimit
    charCountLabel.text = String(describing: charLimit!)
  }
  
  
  
  
  @IBAction func submitTweet(_ sender: UIButton) {
    
    tweetContent = tweetTextView.text
    createTweet(tweetContent: tweetContent)
  
  }
  
  func createTweet(tweetContent: String){
    
    if tweetContent != "" {
        self.presentingViewController!.dismiss(animated: true, completion: nil)
        self.replyTweetDelegate?.onReplyTweetButtonClicked(tweetText: tweetContent, replyID: replyID!)
      
      if isReply == true {
        
      } else {
        self.presentingViewController!.dismiss(animated: true, completion: nil)
        self.composeTweetDelegate?.onComposeTweetButtonClicked(tweetText: tweetContent)
      }
    }
  }
  
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
