//
//  AppUtility.swift
//  Contacts
//
//  Created by Satish Babariya on 11/27/17.
//  Copyright © 2017 Satish Babariya. All rights reserved.
//

import Foundation
import UIKit

public enum Device: String {
    #if os(iOS)
    case iPhone
    case iPad
    case iPod
    case simulator
    #elseif os(OSX)
    case iMac
    case macMini
    case macPro
    case macBook
    case macBookAir
    case macBookPro
    case xserve
    #endif
    case unknown
}

class AppUtility: NSObject {
    


    
    //  MARK: - Misc Methods
    
    class func getAppDelegate()->AppDelegate{
        let appDelegate: UIApplicationDelegate = UIApplication.shared.delegate!
        return appDelegate as! AppDelegate
    }
    
    
    // View Controller Method
    
    class func getTopViewController() -> UIViewController {
        var viewController : UIViewController = UIViewController()
        if let controller =  UIApplication.shared.delegate?.window??.rootViewController {
            viewController = controller
            var presented : UIViewController = controller
            while let top = presented.presentedViewController {
                presented = top
                viewController = top
            }
        }
        return viewController
    }
    
}
