//
//  ProfileViewController.swift
//  MyTwitter
//
//  Created by Barbara Ristau on 2/10/17.
//  Copyright © 2017 FeiLabs. All rights reserved.
//

import UIKit

let offset_HeaderStop: CGFloat = 20.0 // At this offset, Header stops its transformations

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var tableView: UITableView!

  var backgroundImageView: UIImageView!
  var blurImage: UIImageView!
  
  @IBOutlet weak var headerView: UIView!
  
  var avatarImage: UIImageView!
  var navBar: UINavigationBar!

  var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
      
      scrollView.delegate = self
      
      backgroundImageView = UIImageView()
      backgroundImageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0) // setting to zero because image will load in nav bar in the scrollview
      let imageUrl = user!.profileBannerUrl
      backgroundImageView.setImageWith(imageUrl!)
      self.view.addSubview(backgroundImageView)
    
      print("User in the Profile View is: \(user.name!)")
      
         //  loadHeaderImage()
      tableView.dataSource = self
      tableView.delegate = self

      tableView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    
    navBar = self.navigationController?.navigationBar
    navBar?.setBackgroundImage(UIImage(), for: .default)
    navBar?.shadowImage = UIImage()
    navBar?.isTranslucent = true
    navBar?.items?[0].title = ""

}
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    
  }
  
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    navBar?.setBackgroundImage(UIImage(), for: .default)
  }
  

  // MARK: - TABLEVIEW METHODS

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
  }

  return cell
}
  
  // MARK: - Add Blur to Header
  
  func addBlurEffect(imageView: UIImageView) {
    
    blurImage = UIImageView()
    let blur = UIBlurEffect(style: .regular)
    let blurEffectView = UIVisualEffectView(effect: blur)
    blurEffectView.frame = imageView.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    blurImage.addSubview(blurEffectView)
    imageView.addSubview(blurImage)
 
  }
  

  
 // MARK: - SCROLLVIEW METHODS
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {

    let contentWidth = scrollView.bounds.width
    let contentHeight = scrollView.bounds.height/3
    let offset = scrollView.contentOffset.y
    let frame = CGRect(x: 0, y: -200, width: contentWidth, height: contentHeight)
    let bannerSubview = UIImageView(frame: frame)
    bannerSubview.image = backgroundImageView.image
    scrollView.addSubview(bannerSubview)

    
    var avatarTransform = CATransform3DIdentity
    var headerTransform = CATransform3DIdentity
    
    // Pull Down Action 
    
    if offset < 0 {
      
      let headerScaleFactor:CGFloat = -(offset) / contentHeight
      let headerSizeVariation = ((bannerSubview.bounds.height * (1.0 + headerScaleFactor)) - bannerSubview.bounds.height)/2.0
      
      headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizeVariation, 0)
      headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
      
      bannerSubview.layer.transform = headerTransform
    }
    
    // Scroll Up / Down
    
    else {
      
      
      if offset > 75 {
        navBar?.setBackgroundImage(backgroundImageView.image, for: .default)
      }
      
      if offset > 170 {
        self.navigationItem.title = user!.name
      }
      
      
      // Header
      
      headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
      
  
      // Avatar
      
      let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 1.4 // Slow down the animation
      let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
      avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
      avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
      
      if offset <= offset_HeaderStop {

        if avatarImage.layer.zPosition < headerView.layer.zPosition {
           bannerSubview.layer.zPosition = 0
        }
        
      } else {
        if avatarImage.layer.zPosition >= headerView.layer.zPosition {
          bannerSubview.layer.zPosition = 2
        }
      }
    }
    
    
      // Apply transformations 

    
    bannerSubview.layer.transform = headerTransform
    avatarImage.layer.transform = avatarTransform
    
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
