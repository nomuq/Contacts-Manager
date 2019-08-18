//
//  TabBarViewController.swift
//  Contacts
//
//  Created by Satish Babariya on 11/25/17.
//  Copyright © 2017 Satish Babariya. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: Attribute
    var homeNavController: UINavigationController!
    var groupNavController: UINavigationController!
    var favouritesNavController: UINavigationController!
    var settingsNavController: UINavigationController!
    
    // MARK: Life Cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTab()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UI SetUp
    internal func setUpTab() {
        let homeController: HomeViewController = HomeViewController()
        let homeTabItem: UITabBarItem = UITabBarItem(title: nil, image: UIImage(named: "phone-book-black"), selectedImage: UIImage(named: "phone-book-blue"))
        homeTabItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        homeController.tabBarItem = homeTabItem
        
        let favouriteController: FavouritesViewController = FavouritesViewController()
        let favTabItem: UITabBarItem = UITabBarItem(title: nil, image: UIImage(named: "star-black"), selectedImage: UIImage(named: "star-blue"))
        favTabItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        favouriteController.tabBarItem = favTabItem
        
        let settingController: SettingsViewController = SettingsViewController()
        let settingTabItem: UITabBarItem = UITabBarItem(title: nil, image: UIImage(named: "settings-black"), selectedImage: UIImage(named: "settings-blue"))
        settingTabItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        settingController.tabBarItem = settingTabItem
        
        let groupController: GroupViewController = GroupViewController()
        let groupTabItem: UITabBarItem = UITabBarItem(title: nil, image: UIImage(named: "group-book-black"), selectedImage: UIImage(named: "group-book-blue"))
        groupTabItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        groupController.tabBarItem = groupTabItem
        
        homeNavController = UINavigationController(rootViewController: homeController)
        favouritesNavController = UINavigationController(rootViewController: favouriteController)
        groupNavController = UINavigationController(rootViewController: groupController)
        settingsNavController = UINavigationController(rootViewController: settingController)
        
//        if #available(iOS 11.0, *) {
//            homeNavController.navigationItem.largeTitleDisplayMode = .automatic
//            favouritesNavController.navigationItem.largeTitleDisplayMode = .automatic
//            groupNavController.navigationItem.largeTitleDisplayMode = .automatic
//            settingsNavController.navigationItem.largeTitleDisplayMode = .automatic
//        }
        
        // array of the root view controllers displayed by the tab bar interface
        self.viewControllers = [homeNavController, favouritesNavController, groupNavController, settingsNavController]
        
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
