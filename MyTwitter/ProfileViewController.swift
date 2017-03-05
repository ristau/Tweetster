//
//  ProfileViewController.swift
//  MyTwitter
//
//  Created by Barbara Ristau on 2/10/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit

let offset_HeaderStop: CGFloat = 20.0 // At this offset, Header stops its transformations
let offset_B_LabelHeader: CGFloat = 95.0 // At this offset, the black label reaches the header
let distance_W_LabelHeader:CGFloat = 35.0 // Distance between the bottom of the Header and the top of the White Label


class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
  
  @IBOutlet weak var scrollView: UIScrollView!
 // @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var headerLabel: UILabel!
  
  var avatarImage: UIImageView!
  var headerView: UIView!
  var headerBlurImageView: UIImageView!
  var user: User!
  let HeaderViewIdentifier = "TableViewHeaderView"

    override func viewDidLoad() {
        super.viewDidLoad()
      
      print("In the profile view")

      tableView.dataSource = self
      tableView.delegate = self
      tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: HeaderViewIdentifier)
      
      scrollView.delegate = self
      
      print("User in the Profile View is: \(user.name!)")
      
      tableView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    
    let navBar = self.navigationController?.navigationBar
    navBar?.setBackgroundImage(UIImage(), for: .default)
    navBar?.shadowImage = UIImage()
    navBar?.isTranslucent = true
    navBar?.items?[0].title = ""
    
    headerBlurImageView = UIImageView(frame: headerView.bounds)
    let blur = UIBlurEffect(style: UIBlurEffectStyle.regular)
    let blurEffectView = UIVisualEffectView(effect: blur)
    blurEffectView.frame = headerView.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    headerBlurImageView.addSubview(blurEffectView)
    headerBlurImageView.alpha = 0.0
    headerView.addSubview(headerBlurImageView)
    

}
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    
  }
  

  // MARK: - TABLEVIEW METHODS
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
 
    let header = UIView(frame: CGRect(x:0, y:0, width: 320, height: 50))
    header.backgroundColor = UIColor.blue
    
    let bgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    //bgView.backgroundColor = UIColor.yellow
    bgView.image = avatarImage.image
    header.addSubview(bgView)
    
    return header
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
    // show tableview here
    return 40
  }
  
  
  func numberOfSections(in tableView: UITableView) -> Int{
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
      switch section {
      
        case 0:
          return 1
      
        case 1:
          return 10
      
        default:
          return 0
    }
  }
  
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    switch indexPath.section {
      
    case 0:
      return 400
      
    case 1:
      return 50

    default:
      return 44
    }
  }

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
  let cell = UITableViewCell()
  
  cell.selectionStyle = .none
  
  if indexPath.section == 0 {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
    cell.user = user
    avatarImage = cell.profileImage
    headerView = cell.profileBanner
  //  headerView.bounds.height = cell.profileBanner.bounds.height
    headerLabel.text = cell.nameLabel.text
       
  }

  return cell
}
  
 // MARK: - SCROLLVIEW METHODS 
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offset = scrollView.contentOffset.y
    var avatarTransform = CATransform3DIdentity
    var headerTransform = CATransform3DIdentity
    
    // Pull Down Action 
    
    if offset < 0 {
      
      let headerScaleFactor:CGFloat = -(offset) / headerView.bounds.height
      let headerSizeVariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height)/2.0
      headerBlurImageView.alpha = 1.0
      
      
      headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizeVariation, 0)
      headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
      
      headerView.layer.transform = headerTransform
    }
    
    // Scroll Up / Down
    
    else {
      
      // Header 
      
      headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
      
      // Label 
      
      let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
      headerLabel.layer.transform = labelTransform
      
      
      // Remove Blur

      UIView.animate(withDuration: 0.2, delay: 0.05, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveEaseIn, animations: {
        self.headerBlurImageView.alpha = 0.0
      } , completion: nil)
      
      
      // Avatar
      
      let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 1.4 // Slow down the animation
      let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
      avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
      avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
      
      if offset <= offset_HeaderStop {
        
        if avatarImage.layer.zPosition < headerView.layer.zPosition {
          headerView.layer.zPosition = 0
        }
        
      } else {
        if avatarImage.layer.zPosition >= headerView.layer.zPosition {
          headerView.layer.zPosition = 2
        }
      }
    }
    
    
      // Apply transformations 

    
    headerView.layer.transform = headerTransform
    avatarImage.layer.transform = avatarTransform
    
  }
 

  func removeBlur() {
    self.headerBlurImageView.alpha = 0.0
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
