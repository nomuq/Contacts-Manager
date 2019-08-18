//
//  FavouritesViewController.swift
//  Contacts
//
//  Created by Satish Babariya on 11/25/17.
//  Copyright © 2017 Satish Babariya. All rights reserved.
//

import UIKit
import ContactsUI
import RxCocoa
import RxSwift
import Dwifft
import DZNEmptyDataSet

class FavouritesViewController: UIViewController {
    
    // MARK: - Attributes
    
    fileprivate var arrContacts: [CNContact] = []
    fileprivate var disposeBag: DisposeBag! = DisposeBag()
    fileprivate var tableView: UITableView!
    fileprivate var diffCalculator: SingleSectionTableViewDiffCalculator<CNContact>?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Favourites"
        self.loadViewControls()
        self.setViewlayout()
        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Layout
    fileprivate func loadViewControls() {
        
        self.edgesForExtendedLayout = .init(rawValue: 0)
        self.tableView = UITableView()
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(ContactCell.self, forCellReuseIdentifier: CellIdentifire.contactCell)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        self.tableView.separatorStyle = .singleLine
        self.tableView.theme_separatorColor = ThemeColors.separatorColor
        self.tableView.theme_backgroundColor = ThemeColors.backgroundColor
        self.tableView.separatorInset = .zero
        self.tableView.tableFooterView = UIView()
        self.tableView.isMultipleTouchEnabled = false
        self.tableView.separatorStyle = .none
        self.view.addSubview(self.tableView)
        self.diffCalculator = SingleSectionTableViewDiffCalculator(tableView: self.tableView)
        self.diffCalculator?.insertionAnimation = .automatic
        self.diffCalculator?.deletionAnimation = .automatic
        //self.tableView.emptyDataSetSource = self
        
        // SwiftyAd.shared.showBanner(from: self)
        
        SwiftEventBus.onMainThread(self, name: SwiftyNotification.reloadFavouritesList) { [weak self] (notification) in
            if self == nil{
                return
            }
            self!.loadData()
        }
        
    }
    
    fileprivate func setViewlayout() {
        
        let views: [String: Any] = ["tableView": tableView] // , "bannerViewAd": SwiftyAd.shared.bannerViewAd!]
        let horizontalConstraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.view.addConstraints(horizontalConstraint)
        let verticalConstraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.view.addConstraints(verticalConstraint)
        //        let verticalConstraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView][bannerViewAd]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        //        self.view.addConstraints(verticalConstraint)
        
    }
    
    // MARK: - Public Interface
    
    // MARK: - User Interaction
    
    // MARK: - Internal Helpers
    fileprivate func loadData() {
        CNContactStore().requestAccess(for: .contacts) { [weak self] grandted, _ in
            if self == nil {
                return
            }
            if grandted {
                let contactsarr = Observable.of(self!.fetchContacts())
                contactsarr.subscribe { [weak self] event in
                    if self == nil {
                        return
                    }
                    switch event {
                    case let .next(response):
                        self!.diffCalculator?.rows = response
                    default:
                        break
                    }
                }.disposed(by: self!.disposeBag)
            } else {
                self!.displayBottomToast(message: "No Contact Acess Permission", type: .warning)
            }
        }
    }
    
    fileprivate func fetchContacts() -> [CNContact] {
        var contacts: [CNContact] = [CNContact]()
        if Defaults[.favouritesList].count != 0 {
            let contactStore: CNContactStore = CNContactStore()
            let predicate: NSPredicate = CNContact.predicateForContacts(withIdentifiers: Defaults[.favouritesList])
            do {
                contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
                contacts.sort(by: { (contact1, contact2) -> Bool in
                    (contact1.givenName) < (contact2.givenName)
                })
                return contacts
            } catch {
                self.displayBottomToast(message: "Internal Error", type: .error)
            }
        }
        return contacts
    }
    
    // MARK: - Server Request
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - UITableView DataSource
extension FavouritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return arrContacts.count
        return self.diffCalculator?.rows.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifire.contactCell, for: indexPath) as! ContactCell
        cell.delegate = self
        cell.setData(contact: self.diffCalculator!.rows[indexPath.row])
        return cell
    }
    
}

// MARK: - UITableView Delegate
extension FavouritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        contactDetailsAction(contact: self.diffCalculator!.rows[indexPath.row])
    }
}

// MARK: - SwipeTableView CellDelegate
extension FavouritesViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .left {
            guard orientation == .left else { return nil }
            guard orientation == .left else { return nil }
            let contact: CNContact = self.diffCalculator!.rows[indexPath.row]
            let callAction: SwipeAction = SwipeAction(style: .default, title: nil) { [weak self] _, _ in
                if self == nil {
                    return
                }
                self?.makeCall(contact: contact)
            }
            callAction.image = ThemeColors.FAIcon(icon: .phone, size: 45)
            callAction.hidesWhenSelected = true
            callAction.backgroundColor = #colorLiteral(red: 0.08888360113, green: 0.7968495488, blue: 0.4819347858, alpha: 1)
            return AppUtility.getAppDelegate().isCapableToCall == true ? (contact.phoneNumbers.count > 0 ? [callAction] : []) : []
            
        } else {
            guard orientation == .right else { return nil }
            let deleteAction: SwipeAction = SwipeAction(style: .destructive, title: nil) { [weak self] _, indexPath in
                if self == nil {
                    return
                }
                if let index = Defaults[.favouritesList].index(of: self!.diffCalculator!.rows[indexPath.row].identifier) {
                    Defaults[.favouritesList].remove(at: index)
                    self!.loadData()
                }
            }
            deleteAction.image = ThemeColors.trashIcon(size: 45)
            return [deleteAction]
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options: SwipeTableOptions = SwipeTableOptions()
        options.expansionStyle = orientation == .right ? .selection : .destructive(automaticallyDelete: false)
        // options.transitionStyle = .reveal
        return options
    }
    
}

extension FavouritesViewController: DZNEmptyDataSetSource{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return ThemeColors.FAIcon(icon: .starO, size: 150)
    }
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = "No favourited contacts found !"
        
        let titleAttributes = ThemeColors.barTextColors.map { hexString in
            return [
                NSAttributedStringKey.foregroundColor: UIColor(rgba: hexString),
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
            ]
        }
        return NSAttributedString(string: title, attributes: titleAttributes[AppThemes.current.rawValue])
    }
}

// MARK: - Telephony Methods
extension FavouritesViewController {
    fileprivate func makeCall(contact: CNContact) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Make Call To", message: nil, preferredStyle: .actionSheet)
        for item in contact.phoneNumbers {
            actionSheetController.addAction(UIAlertAction(title: item.value.stringValue, style: UIAlertActionStyle.default, handler: { [weak self] _ in
                if self == nil {
                    return
                }
                if let phoneNumber: String = (item.value).value(forKey: "digits") as? String {
                    guard let url: URL = URL(string: "tel://" + "\(phoneNumber)") else {
                        self?.displayBottomToast(message: "Can't able to make call", type: .error)
                        return
                    }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            
        }
        actionSheetController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(actionSheetController, animated: true, completion: { [weak self] in
            if self == nil{
                return
            }
            self?.tableView.hideSwipeCell()
        })
    }
}

// MARK: - ContactViewControllerDelegate
extension FavouritesViewController: CNContactViewControllerDelegate {
    
    fileprivate func contactDetailsAction(contact: CNContact) {
        let contactStore: CNContactStore = CNContactStore()
        var contacts: CNContact = contact
        if !contacts.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
            do {
                contacts = try contactStore.unifiedContact(withIdentifier: contacts.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            } catch {
                self.displayBottomToast(message: "Can't able to open contact", type: .error)
                return
            }
        }
        let contactViewController: CNContactViewController = CNContactViewController(for: contacts)
        UINavigationBar.appearance().isTranslucent = false
        UIApplication.shared.delegate?.window??.theme_backgroundColor = ThemeColors.backgroundColor
        UIApplication.shared.delegate?.window??.theme_tintColor = ThemeColors.barTintColor
        contactViewController.contactStore = contactStore
        contactViewController.delegate = self
        self.navigationController!.pushViewController(contactViewController, animated: true)
    }
    
}
