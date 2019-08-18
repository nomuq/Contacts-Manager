//
//  AppDelegate.swift
//  Contacts
//
//  Created by Satish Babariya on 11/22/17.
//  Copyright © 2017 Satish Babariya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftTheme
import SwiftMessages
import Siren
import CoreTelephony

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var disposeBag: DisposeBag!
    public var isCapableToCall: Bool = false
    public var isCapableToSMS: Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Dispose Bag for disposing Resources
        self.disposeBag = DisposeBag()
                
        // Setting Up Network Reachablity
        setupReachability()
        
        // Setup App Version Check
        checkTelephonyCapbility()
        
        // Loding UI
        loadTheme()
        loadUI()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Siren.shared.checkVersion(checkType: .daily)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

// MARK: - UI
extension AppDelegate {
    
    // For Loading Themes
    fileprivate func loadTheme() {
        AppThemes.restoreLastTheme()
        
        // status bar
        
        //UIApplication.shared.theme_setStatusBarStyle(ThemeColors.barStyleColor, animated: true)
        
        // navigation bar
        
        let navigationBar = UINavigationBar.appearance()
        
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        
        let titleAttributes = ThemeColors.barTextColors.map { hexString in
            return [
                NSAttributedStringKey.foregroundColor: UIColor(rgba: hexString),
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16),
                NSAttributedStringKey.shadow: shadow
            ]
        }
        
        // NSAttributedStringKey.foregroundColor: UIColor.white
        let largeTitleAttributes = ThemeColors.barTextColors.map { hexString in
            return [
                NSAttributedStringKey.foregroundColor: UIColor(rgba: hexString),
                NSAttributedStringKey.shadow: shadow
            ]
        }
        
        navigationBar.theme_tintColor = ThemeColors.barTextColor
        navigationBar.theme_barTintColor = ThemeColors.barTintColor
        navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(titleAttributes)
        navigationBar.theme_barStyle = ThemeColors.barStyleColor
        
        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
            navigationBar.theme_largeTitleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(largeTitleAttributes)
        }
        
        // tab bar
        
        let tabBar = UITabBar.appearance()
        tabBar.theme_tintColor = ThemeColors.barTextColor
        tabBar.theme_barTintColor = ThemeColors.barTintColor
    }
    
    // For Loding UI
    fileprivate func loadUI() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.theme_backgroundColor = ThemeColors.backgroundColor
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
    }
}

// MARK: - Network
extension AppDelegate {
    
    // For Setting Up Reachblity
    fileprivate func setupReachability() {
        do {
            let reachable = try DefaultReachabilityService()
            reachable.reachability.subscribe { [weak self] event in
                if self == nil {
                    return
                }
                switch event {
                case let .next(status):
                    if reachable._reachability.connection == .none {
                        print(status)
                    } else {
                        print(status)
                    }
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - CoreTelephony
extension AppDelegate {
    fileprivate func checkTelephonyCapbility() {
        isCapableToCall = CTTelephonyNetworkInfo().subscriberCellularProvider?.mobileNetworkCode != nil ? true : false
        isCapableToSMS = UIApplication.shared.canOpenURL(NSURL(string: "sms:")! as URL)
    }
}

// MARK: Swift Messages
extension AppDelegate {
    public func messageMaker(message: String, position: SwiftMessages.PresentationStyle, type: Theme) {
        let messageView: MessageView = MessageView.viewFromNib(layout: .cardView)
        messageView.configureTheme(type)
        messageView.bodyLabel?.text = message
        // messageView.bodyLabel?.isHidden = true
        messageView.button?.isHidden = true
        messageView.titleLabel?.isHidden = true
        // messageView.iconImageView?.isHidden = true
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = position
        config.duration = .seconds(seconds: 2.0)
        SwiftMessages.show(config: config, view: messageView)
    }
}
