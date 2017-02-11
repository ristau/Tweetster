//
//  DetailCell.swift
//  MyTwitter
//
//  Created by Barbara Ristau on 2/10/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit

protocol DetailCellDelegator {
  func callSegueFromCell(myData dataobject: User)
}

class DetailCell: UITableViewCell {

  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var screenNameLabel: UILabel!
  @IBOutlet weak var profileImage: UIImageView!
  
  var delegate: DetailCellDelegator!
  
  var tweet: Tweet! {
    
    didSet {
      
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToProfileView))
      
      nameLabel.text = tweet.user?.name!
      screenNameLabel.text = ("@" + (tweet.user?.screenname!)!)
      
      if let profileUrl = tweet.user?.profileUrl {
        profileImage.setImageWith(profileUrl)
        profileImage.addGestureRecognizer(tapGesture)

      }

      
    }
    
  }
  
    override func awakeFromNib() {
        super.awakeFromNib()
      

  }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  func goToProfileView() {
    print("Going to Profile View")
    let user = tweet?.user
    print("User: \(user!.name!)")
    
    if(self.delegate != nil) {
      self.delegate.callSegueFromCell(myData: user! as User)
    }
  }

}
