//
//  Constants.swift
//  Contacts
//
//  Created by Satish Babariya on 11/25/17.
//  Copyright © 2017 Satish Babariya. All rights reserved.
//

import Foundation
import UIKit


//  MARK: - Thired Party Constants -
struct ThiredPartyKey {
    
    static let dropboxAppKey = ""
}

//  MARK: - Cell Identifier Constants -
struct CellIdentifire {
    static let settingsCell = "SettingsCell"
    static let defaultCell  = "cell"
    static let contactCell  = "contactCell"
    static let grouplistCell = "GroupListCell"
}

// MARK: - Swifty Event Bus Notifications
struct SwiftyNotification {
    static let SucessPayment = "SucessPayment"
    static let ReAddsDisplay = "ReAddsDisplay"
    static let reloadFavouritesList = "ReloadFavouritesList"
    static let reloadGroupList = "ReloadGroupList"
}

// MARK: - Swifty User DefaultsKeys
extension DefaultsKeys{
    static let lastThemeIndexKey = DefaultsKey<Int>("lastedThemeIndex")
    static let isPremiumUser = DefaultsKey<Bool>("PremiumUserStatus")
    static let favouritesList = DefaultsKey<[String]>("ArrayOfFavouritesContacts")
    static let isShareContactEnable = DefaultsKey<Bool>("IsShareContactEnable")
}

// MARK: - Device Compatibility
struct currentDevice {
    static let isIphone = (UIDevice.current.model as NSString).isEqual(to: "iPhone") ? true : false
    static let isIpad = (UIDevice.current.model as NSString).isEqual(to: "iPad") ? true : false
    static let isIPod = (UIDevice.current.model as NSString).isEqual(to: "iPod touch") ? true : false
}

