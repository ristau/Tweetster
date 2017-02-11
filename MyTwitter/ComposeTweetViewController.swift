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
  
  
  var user: User!
  var charCount: Int = 140

  
  
    override func viewDidLoad() {
        super.viewDidLoad()

      print("Now in Compose Tweet")
      user = User.currentUser
      print("User Name: \(user.name!)")
      
      tweetTextView.delegate = self

     
    }

  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    
    tweetTextView.text = "What's Happening?"
    tweetTextView.textColor = UIColor.lightGray
    self.tweetTextView.becomeFirstResponder()
    tweetTextView.selectedTextRange = tweetTextView.textRange(from: tweetTextView.beginningOfDocument, to: tweetTextView.beginningOfDocument)
    
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if tweetTextView.textColor == UIColor.lightGray {
      tweetTextView.textColor = nil
      tweetTextView.textColor = UIColor.black
    }
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    // Combine the textView text and the replacement text to
    // create the updated text string
    
    let currentText: NSString = (tweetTextView.text ?? "") as NSString
    let updatedText = currentText.replacingCharacters(in: range, with: text)
    //let currentText = tweetTextView.text
    //let updatedText = (currentText! as String).replacingCharacters(in: range, with: text)
    
    // If updated text view will be empty, add the placeholder
    // and set the cursor to the beginning of the text view
    if updatedText.isEmpty {
      
      tweetTextView.text = "What's Happening?"
      tweetTextView.textColor = UIColor.lightGray
      
      tweetTextView.selectedTextRange = tweetTextView.textRange(from: tweetTextView.beginningOfDocument, to: tweetTextView.beginningOfDocument)
      
      return false
    }
      
      // Else if the text view's placeholder is showing and the
      // length of the replacement string is greater than 0, clear
      // the text view and set its color to black to prepare for
      // the user's entry
    else if tweetTextView.textColor == UIColor.lightGray && !text.isEmpty {
      tweetTextView.text = nil
      tweetTextView.textColor = UIColor.black
    }
    
    return true
  }
  
  func textViewDidChangeSelection(_ textView: UITextView) {
    if self.view.window != nil {
      if tweetTextView.textColor == UIColor.lightGray {
        tweetTextView.selectedTextRange = tweetTextView.textRange(from: tweetTextView.beginningOfDocument, to: tweetTextView.beginningOfDocument)
      }
    }
  }
  
  
  
  
 /* func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
    let characterLimit = 10
    let newText = NSString(string: tweetTextView.text!).replacingCharacters(in: range, with: text)
    let numberOfChars = newText.characters.count
    
    return numberOfChars < characterLimit
  }
 */ 

  
  @IBAction func onCancel(_ sender: UIBarButtonItem) {
    print("Pressed Cancel") 
  }
  
  
  @IBAction func submitTweet(_ sender: UIButton) {
 print("Pressed Submit Tweet")
  
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
