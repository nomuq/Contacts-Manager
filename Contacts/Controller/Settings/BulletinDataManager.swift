//
//  InAppPurchase.swift
//  Contacts
//
//  Created by Satish Babariya on 11/27/17.
//  Copyright © 2017 Satish Babariya. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import FontAwesome_swift
import Reachability
import Contacts

enum BulletinDataSource {
    
    // MARK: - Pages
    
    /**
     * Create the introduction page.
     *
     * This creates a `FeedbackPageBulletinItem` with: a title, an image, a description text and
     * and action button.
     *
     * The action button presents the next item (the textfield page).
     */
    
    static func makeInAppPurchasePage() -> InAppPurchaseBulletinItem {
        let page: InAppPurchaseBulletinItem = InAppPurchaseBulletinItem(title: "Remove Ads")
        page.descriptionText = "Remove advertisement form application by becoming Premium Member."
        page.actionButtonTitle = "Purchase"
        page.alternativeButtonTitle = "Restore"
        page.image = #imageLiteral(resourceName: "noads")
        page.isDismissable = true
        
        page.actionHandler = { (_: PageBulletinItem) in
            page.manager?.displayActivityIndicator()
            let reachability: Reachability = Reachability()!
            if reachability.connection != .none {
                //                SwiftyStoreKit.retrieveProductsInfo([ThiredPartyKey.inAppProductID], completion: { (results) in
                //                    if results.error == nil{
                //                        if results.retrievedProducts.count == 1{
                //                            print("products: \(results.retrievedProducts)")
                //                        }
                //                    }else {
                //                        //ERROR IN RETRIVING PRODUCT
                //                    }
                //                })
                
                SwiftyStoreKit.purchaseProduct(ThiredPartyKey.inAppProductID, quantity: 1, atomically: true) { result in
                    
                    switch result {
                    case .success(let purchase):
                        Defaults[.isPremiumUser] = true
                        SwiftyAd.shared.isRemoved = Defaults[.isPremiumUser]
                        SwiftEventBus.post(SwiftyNotification.SucessPayment, userInfo: nil)
                        page.manager?.dismissBulletin(animated: true)
                        AppUtility.getAppDelegate().messageMaker(message: "Purchase Sucess", position: .bottom, type: .success)
                        print("Purchase Success: \(purchase.productId)")
                    case .error(let error):
                        var message: String = ""
                        switch error.code {
                        case .unknown: message = ("Unknown error. Please contact support")
                        case .clientInvalid: message = ("Not allowed to make the payment")
                        case .paymentCancelled: break
                        case .paymentInvalid: message = ("The purchase identifier was invalid")
                        case .paymentNotAllowed: message = ("The device is not allowed to make the payment")
                        case .storeProductNotAvailable: message = ("The product is not available in the current storefront")
                        case .cloudServicePermissionDenied: message = ("Access to cloud service information is not allowed")
                        case .cloudServiceNetworkConnectionFailed: message = ("Could not connect to the network")
                        case .cloudServiceRevoked: message = ("User has revoked permission to use this cloud service")
                        }
                        page.manager?.dismissBulletin(animated: true)
                        AppUtility.getAppDelegate().messageMaker(message: message, position: .bottom, type: .error)
                        
                    }
                }
                
            } else {
                page.manager?.dismissBulletin(animated: true)
                AppUtility.getAppDelegate().messageMaker(message: "No Internet Connection", position: .bottom, type: .warning)
            }
        }
        page.alternativeHandler = { (_: PageBulletinItem) in
            page.manager?.displayActivityIndicator()
            let reachability: Reachability = Reachability()!
            if reachability.connection != .none {
                
                SwiftyStoreKit.restorePurchases(atomically: true) { results in
                    if results.restoreFailedPurchases.count > 0 {
                        print("Restore Failed: \(results.restoreFailedPurchases)")
                        page.manager?.dismissBulletin(animated: true)
                        AppUtility.getAppDelegate().messageMaker(message: "Restore Failed", position: .bottom, type: .error)
                    } else if results.restoredPurchases.count > 0 {
                        Defaults[.isPremiumUser] = true
                        SwiftyAd.shared.isRemoved = Defaults[.isPremiumUser]
                        SwiftEventBus.post(SwiftyNotification.SucessPayment, userInfo: nil)
                        print("Restore Success: \(results.restoredPurchases)")
                        page.manager?.dismissBulletin(animated: true)
                        AppUtility.getAppDelegate().messageMaker(message: "Purchase Sucess", position: .bottom, type: .success)
                    } else {
                        print("Nothing to Restore")
                        page.manager?.dismissBulletin(animated: true)
                        AppUtility.getAppDelegate().messageMaker(message: "Nothing to Restore", position: .bottom, type: .info)
                    }
                }
                
            } else {
                page.manager?.dismissBulletin(animated: true)
                AppUtility.getAppDelegate().messageMaker(message: "No Internet Connection", position: .bottom, type: .warning)
            }
        }
        return page
    }
    
    static func makeBackupPage() -> BackupBulletinItem {
        let page: BackupBulletinItem = BackupBulletinItem(title: "Backup Contacts")
        page.actionButtonTitle = "Dropbox"
        page.alternativeButtonTitle = "Google Drive"
        page.descriptionText = "Backup all of your contacts to one of this services"
        page.image = #imageLiteral(resourceName: "sync")
        page.isDismissable = true
        
        page.actionHandler = { (_: PageBulletinItem) in
            page.manager?.displayActivityIndicator()
            let reachability: Reachability = Reachability()!
            if reachability.connection != .none {} else {
                AppUtility.getAppDelegate().messageMaker(message: "No Internet Connection", position: .bottom, type: .warning)
            }
            
        }
        page.alternativeHandler = { (_: PageBulletinItem) in
            page.manager?.displayActivityIndicator()
            
        }
        return page
    }
    
    static func makeRestorePage() -> RestoreBulletinItem {
        let page: RestoreBulletinItem = RestoreBulletinItem(title: "Restore Contacts")
        page.actionButtonTitle = "Dropbox"
        page.alternativeButtonTitle = "Google Drive"
        page.descriptionText = "Restore all of your contacts from one of this services"
        page.image = #imageLiteral(resourceName: "sync")
        page.isDismissable = true
        page.actionHandler = { (_: PageBulletinItem) in
            page.manager?.displayActivityIndicator()
            let reachability: Reachability = Reachability()!
            if reachability.connection != .none {} else {
                AppUtility.getAppDelegate().messageMaker(message: "No Internet Connection", position: .bottom, type: .warning)
            }
        }
        page.alternativeHandler = { (_: PageBulletinItem) in
            page.manager?.displayActivityIndicator()
            
        }
        return page
    }
    
    static func makeColorPickerPage() -> ColorPickerBulletinItem {
        let page = ColorPickerBulletinItem()
        page.isDismissable = true
        return page
    }
    
    static func makeNewGroupTextFieldPage() -> TextFieldBulletinPage {
        let page: TextFieldBulletinPage = TextFieldBulletinPage.init(title: "Create New Group", description: nil, textFieldPlaceHolder: "Enter Name", buttonTitle: "Create")
        page.isDismissable = true
        page.actionHandler = { item in
            page.manager?.displayActivityIndicator()
            let store: CNContactStore = CNContactStore()
            let request: CNSaveRequest = CNSaveRequest()
            let group: CNMutableGroup = CNMutableGroup()
            group.name = page.textField!.text!
            request.add(group, toContainerWithIdentifier: nil)
            do {
                try store.execute(request)
                SwiftEventBus.post(SwiftyNotification.reloadGroupList)
                item.manager?.dismissBulletin()
            } catch {
                item.manager?.dismissBulletin()
                AppUtility.getAppDelegate().messageMaker(message: "Can't able to create new group.", position: .bottom, type: .warning)
            }
            
        }
        return page
    }
    
    static func editGroupNameTextFieldPage(group : CNGroup) -> TextFieldBulletinPage {
        let page: TextFieldBulletinPage = TextFieldBulletinPage.init(title: "Change Group Name", description: nil, textFieldPlaceHolder: "Enter Name", buttonTitle: "Change")
        page.isDismissable = true
        page.actionHandler = { item in
            page.manager?.displayActivityIndicator()
            let store: CNContactStore = CNContactStore()
            
            let request: CNSaveRequest = CNSaveRequest()
            if let mutableGroup: CNMutableGroup = group.mutableCopy() as? CNMutableGroup {
                mutableGroup.name = page.textField!.text!
                request.update(mutableGroup)
            }
            do {
                try store.execute(request)
                SwiftEventBus.post(SwiftyNotification.reloadGroupList)
                item.manager?.dismissBulletin()
            } catch {
                item.manager?.dismissBulletin()
                AppUtility.getAppDelegate().messageMaker(message: "Can't able to change group name.", position: .bottom, type: .warning)
            }
        }
        return page
    }
    
    static func makeDeleteGroupPage(group : CNGroup)  -> ConfirmationBulletinPage {
        let page: ConfirmationBulletinPage = ConfirmationBulletinPage.init(title: "Delete \(group.name) Group", description: "Click anywhere other then Delete button for Cancel.", buttonTitle: "Delete")
        page.isDismissable = true
        page.actionHandler = { item in
            page.manager?.displayActivityIndicator()
            let store: CNContactStore = CNContactStore()
            let request: CNSaveRequest = CNSaveRequest()
            if let mutableGroup: CNMutableGroup = group.mutableCopy() as? CNMutableGroup {
                request.delete(mutableGroup)
            }
            do {
                try store.execute(request)
                SwiftEventBus.post(SwiftyNotification.reloadGroupList)
                item.manager?.dismissBulletin()
            } catch {
                item.manager?.dismissBulletin()
                AppUtility.getAppDelegate().messageMaker(message: "Can't able to change group name.", position: .bottom, type: .warning)
            }
        }
        return page
    }
    
    static func makeDeleteContactPage(contact: CNContact)  -> ConfirmationBulletinPage {
        let page: ConfirmationBulletinPage = ConfirmationBulletinPage.init(title: "Delete Contact", description: "Click anywhere other then Delete button for Cancel.", buttonTitle: "Delete")
        page.isDismissable = true
        page.actionHandler = { item in
            page.manager?.displayActivityIndicator()
            let store: CNContactStore = CNContactStore()
            let request: CNSaveRequest = CNSaveRequest()
            guard let mutableContact: CNMutableContact = contact.mutableCopy() as? CNMutableContact else { return }
            request.delete(mutableContact)
            do {
                try store.execute(request)
                if let index = Defaults[.favouritesList].index(of: contact.identifier) {
                    Defaults[.favouritesList].remove(at: index)
                }
                item.manager?.dismissBulletin()
            } catch {
                item.manager?.dismissBulletin()
                AppUtility.getAppDelegate().messageMaker(message: "Can't able to delete contact.", position: .bottom, type: .warning)
            }
        }
        return page
    }
}
