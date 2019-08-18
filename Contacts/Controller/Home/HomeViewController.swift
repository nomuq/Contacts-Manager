//
//  HomeViewController.swift
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

class HomeViewController: UIViewController {
    
    // MARK: - Attributes
    
    fileprivate var arrContacts: [CNContact] = []
    fileprivate var disposeBag: DisposeBag! = DisposeBag()
    fileprivate var tableView: UITableView!
    // fileprivate var diffCalculator: SingleSectionTableViewDiffCalculator<CNContact>?
    fileprivate var diffCalculator: TableViewDiffCalculator<String, CNContact>?
    fileprivate var store: CNContactStore = CNContactStore()
    fileprivate var refresher: PullToRefresh!
    fileprivate var popTip: PopTip!
    fileprivate var bulletinManager: BulletinManager!
    
    // SearchBar
    fileprivate var searchBar: UISearchBar!
    fileprivate var searchBarButtonItem: UIBarButtonItem?
    fileprivate var searchActive: Bool!
    fileprivate var titleLabel : UILabel!
    
    fileprivate var sectionedContacts: SectionedValues<String, String> = SectionedValues<String, String>()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Contacts"
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
        
        self.refresher = PullToRefresh()
        self.refresher.shouldBeVisibleWhileScrolling = true
        self.refresher.position = .top
        
        self.tableView = UITableView()
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(ContactCell.self, forCellReuseIdentifier: CellIdentifire.contactCell)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .singleLine
        self.tableView.theme_separatorColor = ThemeColors.separatorColor
        self.tableView.theme_backgroundColor = ThemeColors.backgroundColor
        self.tableView.theme_sectionIndexColor = ThemeColors.textColor
        self.tableView.sectionIndexBackgroundColor = UIColor.clear
        self.tableView.separatorInset = .zero
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 80
        self.tableView.isMultipleTouchEnabled = false
        self.tableView.separatorStyle = .none
        self.view.addSubview(self.tableView)
        
        self.tableView.addPullToRefresh(self.refresher) {
            self.loadData()
        }
        
        self.diffCalculator = TableViewDiffCalculator(tableView: self.tableView)
        self.diffCalculator?.insertionAnimation = .automatic
        self.diffCalculator?.deletionAnimation = .automatic
        
        self.popTip = PopTip()
        self.popTip.font = UIFont(name: "Avenir-Medium", size: UIScreen.main.bounds.width / 10)!
        self.popTip.shouldDismissOnTap = true
        self.popTip.edgeMargin = 5
        self.popTip.offset = 2
        self.popTip.bubbleOffset = 0
        self.popTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10)
        self.popTip.shouldDismissOnTapOutside = true
        self.popTip.shouldDismissOnSwipeOutside = true
        
        self.searchBar = UISearchBar()
        self.searchBar.delegate = self
        self.searchBar.searchBarStyle = UISearchBarStyle.minimal
        self.searchBar.placeholder = "Search"
        self.searchBar.setTextColor(color: ThemeColors.barTextColor)
        let searchBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonPressed))
        let newContactBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewContactAction))
        
        if #available(iOS 11.0, *) {
            let search: UISearchController = UISearchController(searchResultsController: nil)
            search.searchResultsUpdater = self
            search.delegate = self
            search.searchBar.theme_tintColor = ThemeColors.textColor
            self.navigationItem.searchController = search
            navigationItem.rightBarButtonItems = [newContactBarButton]
        } else {
            titleLabel = UILabel()
            titleLabel.sizeToFit()
            titleLabel.text = "Contacts"
            titleLabel.theme_textColor = ThemeColors.textColor
            navigationItem.titleView = titleLabel
            navigationItem.rightBarButtonItems = [newContactBarButton, searchBarButton]
        }
        
        // SwiftyAd.shared.showBanner(from: self)
        
        NotificationCenter.default.rx.notification(.CNContactStoreDidChange).subscribe(onNext: { [weak self] _ in
            if self == nil {
                return
            }
            self!.loadData()
        }).disposed(by: self.disposeBag)
        
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
    
    fileprivate func searchContact(name: String) {
        var orderedContacts: [String: [CNContact]] = [String: [CNContact]]()
        var mutable = [(String, [CNContact])]()
        let predicate: NSPredicate = CNContact.predicateForContacts(matchingName: name)
        do {
            
            let arrContacts = try self.store.unifiedContacts(matching: predicate, keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
            for contact in arrContacts {
                var key: String = "#"
                // If ordering has to be happening via family name change it here.
                if let firstLetter = contact.givenName[0..<1], firstLetter.containsAlphabets() {
                    key = firstLetter.uppercased()
                }
                var contacts = [CNContact]()
                if let segregatedContact = orderedContacts[key] {
                    contacts = segregatedContact
                }
                contacts.append(contact)
                mutable.append((key, contacts))
            }
            mutable.sort(by: { $0.0 < $1.0 })
            self.diffCalculator?.sectionedValues = SectionedValues(mutable)
        } catch {
            self.displayBottomToast(message: "Internal Error", type: .error)
        }
        
    }
    
    fileprivate func deleteContactAction(contact: CNContact) {
        let alertController: UIAlertController = UIAlertController(title: "Delete", message: "\(contact.givenName.trimmed) \(contact.familyName.trimmed)".trimmed, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(title: "Delete", style: UIAlertActionStyle.destructive, isEnabled: true) { [weak self] _ in
            if self == nil {
                return
            }
            let request: CNSaveRequest = CNSaveRequest()
            guard let mutableContact: CNMutableContact = contact.mutableCopy() as? CNMutableContact else { return }
            request.delete(mutableContact)
            do {
                try self!.store.execute(request)
                if let index = Defaults[.favouritesList].index(of: contact.identifier) {
                    Defaults[.favouritesList].remove(at: index)
                }
            } catch {
                self!.displayBottomToast(message: "Can't able to delete contact.", type: .error)
            }
        }
        alertController.addAction(title: "Cancel", style: UIAlertActionStyle.cancel, isEnabled: true, handler: nil)
        alertController.show()
    }
    
    fileprivate func addToGroupContactAction(contact: CNContact) {
        do {
            let groups: [CNGroup] = try self.store.groups(matching: nil)
            let actionSheetController: UIAlertController = UIAlertController(title: "Add contact to group.", message: nil, preferredStyle: .actionSheet)
            for item in groups {
                actionSheetController.addAction(title: item.name, style: UIAlertActionStyle.default, isEnabled: true) { [weak self] _ in
                    if self == nil {
                        return
                    }
                    let request: CNSaveRequest = CNSaveRequest()
                    request.addMember(contact, to: item)
                    do {
                        try self!.store.execute(request)
                    } catch {
                        self!.displayBottomToast(message: "Can't able to add contact to group.", type: .error)
                    }
                }
            }
            actionSheetController.addAction(title: "Cancel", style: UIAlertActionStyle.cancel, isEnabled: true, handler: nil)
            actionSheetController.show()
        } catch {
            self.displayBottomToast(message: "Something went wrong.", type: .error)
        }
    }
    
    fileprivate func shareContact(contact: CNContact) {
        do {
            let data: Data = try CNContactVCardSerialization.data(with: [contact])
            if let directoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL: URL = directoryURL.appendingPathComponent("\(contact.givenName.trimmed) \(contact.familyName.trimmed)".trimmed.isEmpty ? "contact" : "\(contact.givenName.trimmed) \(contact.familyName.trimmed)".trimmed).appendingPathExtension("vcf")
                do {
                    try data.write(to: fileURL, options: .atomicWrite)
                    let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                        activityViewController.modalPresentationStyle = .popover
                        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                        activityViewController.popoverPresentationController?.sourceView = self.view
                        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.layer.bounds.midX, y: self.view.layer.bounds.midY, width: 0, height: 0)
                        self.present(activityViewController, animated: true, completion: nil)
                    } else {
                        self.present(activityViewController, animated: true, completion: nil)
                    }
                }
            }
            
        } catch {
            self.displayBottomToast(message: "Something went wrong!", type: .error)
        }
    }
    
    // MARK: - Internal Helpers
    
    fileprivate func loadData() {
        CNContactStore().requestAccess(for: .contacts) { [weak self] grandted, _ in
            if self == nil {
                return
            }
            if grandted {
                let contactsarr = Observable.of(self!.fetchContacts2())
                contactsarr.subscribe { [weak self] event in
                    if self == nil {
                        return
                    }
                    switch event {
                    case let .next(response):
                        var mutable = [(String, [CNContact])]()
                        for (key, values) in response {
                            mutable.append((key, values))
                        }
                        mutable.sort(by: { $0.0 < $1.0 })
                        self!.diffCalculator?.sectionedValues = SectionedValues(mutable)
                        self!.endPulltoRefresh()
                    default:
                        break
                    }
                }.disposed(by: self!.disposeBag)
            } else {
                self!.endPulltoRefresh()
                self!.displayBottomToast(message: "No Contact Acess Permission", type: .warning)
            }
        }
    }
    
    fileprivate func fetchContacts2() -> [String: [CNContact]] {
        let fetchRequest: CNContactFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
        var orderedContacts: [String: [CNContact]] = [String: [CNContact]]()
        CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone)
        fetchRequest.mutableObjects = false
        fetchRequest.unifyResults = true
        fetchRequest.sortOrder = .givenName
        do {
            try CNContactStore().enumerateContacts(with: fetchRequest, usingBlock: { (contact, _) -> Void in
                // Ordering contacts based on alphabets in firstname
                
                var key: String = "#"
                // If ordering has to be happening via family name change it here.
                if let firstLetter = contact.givenName[0..<1], firstLetter.containsAlphabets() {
                    key = firstLetter.uppercased()
                }
                var contacts = [CNContact]()
                if let segregatedContact = orderedContacts[key] {
                    contacts = segregatedContact
                }
                contacts.append(contact)
                orderedContacts[key] = contacts
            })
        } catch {
            self.displayBottomToast(message: "Error, Please try again.", type: .error)
        }
        return orderedContacts
    }
    
    fileprivate func endPulltoRefresh() {
        if self.refresher != nil {
            DispatchQueue.main.async { [weak self] in
                if self == nil {
                    return
                }
                self?.tableView.endRefreshing(at: .top)
            }
        }
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

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.diffCalculator?.numberOfSections() ?? 0
    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return self.diffCalculator?.value(forSection: section)
    //    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.diffCalculator?.sectionedValues.sectionsAndValues.flatMap { $0.0 }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        // popTip.bubbleColor = ThemeColors.textColor.
        popTip.show(text: title, direction: .none, maxWidth: 150, in: self.view, from: CGRect(x: self.view.layer.bounds.midX - 50, y: self.view.layer.bounds.midY - 50, width: 100, height: 100))
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            if self == nil {
                return
            }
            if self!.popTip != nil {
                self!.popTip.hide()
            }
        }
        return index
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30.0))
        let label: UILabel = UILabel(frame: CGRect(x: 15, y: 4, width: UIScreen.main.bounds.width - 30, height: 22.0))
        // label.font = UIFont(name: FontStyle.medium, size: 20)
        label.theme_textColor = ThemeColors.textColor
        label.text = self.diffCalculator?.value(forSection: section)
        view.addSubview(label)
        let border = CALayer()
        border.theme_backgroundColor = ThemeColors.tableHeaderColor
        border.frame = CGRect(x: 0, y: view.frame.height - 2.0, width: view.frame.width, height: 2.0)
        view.layer.addSublayer(border)
        view.theme_backgroundColor = ThemeColors.backgroundColor
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return arrContacts.count
        // return self.diffCalculator?.rows.count ?? 0
        return self.diffCalculator?.numberOfObjects(inSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifire.contactCell, for: indexPath) as! ContactCell
        cell.delegate = self
        cell.setData(contact: self.diffCalculator!.value(atIndexPath: indexPath)) // self.diffCalculator!.rows[indexPath.row])
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        contactDetailsAction(contact: self.diffCalculator!.value(atIndexPath: indexPath))
    }
}

// MARK: - SwipeTableViewCellDelegate
extension HomeViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .left {
            guard orientation == .left else { return nil }
            guard orientation == .left else { return nil }
            let callAction: SwipeAction = SwipeAction(style: .default, title: nil) { [weak self] _, _ in
                if self == nil {
                    return
                }
                self?.makeCall(contact: self!.diffCalculator!.value(atIndexPath: indexPath))
            }
            callAction.image = ThemeColors.FAIcon(icon: .phone, size: 45)
            callAction.hidesWhenSelected = true
            callAction.backgroundColor = #colorLiteral(red: 0.08888360113, green: 0.7968495488, blue: 0.4819347858, alpha: 1)
            return AppUtility.getAppDelegate().isCapableToCall == true ? (self.diffCalculator!.value(atIndexPath: indexPath).phoneNumbers.count > 0 ? [callAction] : []) : []
            
        } else {
            guard orientation == .right else { return nil }
            let deleteAction: SwipeAction = SwipeAction(style: .destructive, title: nil) { [weak self] _, _ in
                if self == nil {
                    return
                }
                self!.deleteContactAction(contact: self!.diffCalculator!.value(atIndexPath: indexPath))
            }
            deleteAction.image = ThemeColors.trashIcon(size: 45)
            deleteAction.hidesWhenSelected = true
            
            let favouriteAction: SwipeAction = SwipeAction(style: .default, title: nil) { [weak self] _, indexPath in
                if self == nil {
                    return
                }
                if let index = Defaults[.favouritesList].index(of: self!.diffCalculator!.value(atIndexPath: indexPath).identifier) {
                    Defaults[.favouritesList].remove(at: index)
                    SwiftEventBus.postToMainThread(SwiftyNotification.reloadFavouritesList)
                } else {
                    Defaults[.favouritesList].append(self!.diffCalculator!.value(atIndexPath: indexPath).identifier)
                    SwiftEventBus.postToMainThread(SwiftyNotification.reloadFavouritesList)
                }
            }
            if Defaults[.favouritesList].contains(self.diffCalculator!.value(atIndexPath: indexPath).identifier) {
                favouriteAction.image = ThemeColors.FAIcon(icon: .star, size: 45)
            } else {
                favouriteAction.image = ThemeColors.FAIcon(icon: .starO, size: 45)
            }
            favouriteAction.hidesWhenSelected = true
            
            let addToGroupAction: SwipeAction = SwipeAction(style: .default, title: nil) { [weak self] _, _ in
                if self == nil {
                    return
                }
                self!.addToGroupContactAction(contact: self!.diffCalculator!.value(atIndexPath: indexPath))
            }
            addToGroupAction.image = ThemeColors.FAIcon(icon: .group, size: 45)
            addToGroupAction.hidesWhenSelected = true
            
            let shareContactAction: SwipeAction = SwipeAction(style: .default, title: nil) { [weak self] _, _ in
                if self == nil {
                    return
                }
                self!.shareContact(contact: self!.diffCalculator!.value(atIndexPath: indexPath))
            }
            shareContactAction.image = ThemeColors.FAIcon(icon: .shareAlt, size: 45)
            shareContactAction.hidesWhenSelected = true
            
            return Defaults[DefaultsKeys.isShareContactEnable] == true ? [deleteAction, shareContactAction, addToGroupAction, favouriteAction] : [deleteAction, addToGroupAction, favouriteAction]
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options: SwipeTableOptions = SwipeTableOptions()
        options.expansionStyle = orientation == .right ? .selection : .destructive(automaticallyDelete: false)
        // options.transitionStyle = .reveal
        return options
    }
}

// MARK: - Telephony Methods
extension HomeViewController {
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
            if self == nil {
                return
            }
            self?.tableView.hideSwipeCell()
        })
    }
}

// MARK: - ContactViewControllerDelegate
extension HomeViewController: CNContactViewControllerDelegate {
    
    fileprivate func contactDetailsAction(contact: CNContact) {
        var contacts: CNContact = contact
        if !contacts.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
            do {
                contacts = try self.store.unifiedContact(withIdentifier: contacts.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            } catch {
                self.displayBottomToast(message: "Can't able to open contact", type: .error)
                return
            }
        }
        let contactViewController: CNContactViewController = CNContactViewController(for: contacts)
        UINavigationBar.appearance().isTranslucent = false
        UIApplication.shared.delegate?.window??.theme_backgroundColor = ThemeColors.backgroundColor
        UIApplication.shared.delegate?.window??.theme_tintColor = ThemeColors.barTintColor
        contactViewController.contactStore = self.store
        contactViewController.delegate = self
        self.navigationController?.pushViewController(contactViewController, animated: true)
    }
    
    @objc fileprivate func createNewContactAction() {
        let contactViewController: CNContactViewController = CNContactViewController(forNewContact: nil)
        UINavigationBar.appearance().isTranslucent = false
        UIApplication.shared.delegate?.window??.theme_backgroundColor = ThemeColors.backgroundColor
        UIApplication.shared.delegate?.window??.theme_tintColor = ThemeColors.barTintColor
        contactViewController.contactStore = CNContactStore()
        contactViewController.delegate = self
        let navigationController: UINavigationController = UINavigationController(rootViewController: contactViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UISearchResultsUpdating
extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchBar.setTextColor(color: ThemeColors.textColor)
        if searchController.isActive && searchController.searchBar.trimmedText! != "" {
            self.searchContact(name: searchController.searchBar.trimmedText!)
        }
    }
}

// MARK: - UISearchControllerDelegate
extension HomeViewController: UISearchControllerDelegate {
    func willDismissSearchController(_ searchController: UISearchController) {
        self.loadData()
    }
}

// MARK: - UISearchBarDelegate
extension HomeViewController: UISearchBarDelegate {
    
    @objc func searchButtonPressed(sender: AnyObject) {
        self.showSearchBar()
    }
    
    func showSearchBar() {
        searchBar.alpha = 0
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.hideSearchBar))
        navigationItem.rightBarButtonItems = [rightBarButtonItem]
        navigationItem.setLeftBarButton(nil, animated: true)
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBar.alpha = 1
            self.navigationItem.titleView = self.searchBar
        }, completion: { _ in
            self.searchBar.becomeFirstResponder()
        })
    }
    
    @objc func hideSearchBar() {
        self.loadData()
        self.titleLabel.alpha = 0
        let searchBarButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.searchButtonPressed))
        let addBarButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewContactAction))
        navigationItem.rightBarButtonItems = [searchBarButton, addBarButton]
        searchBar.text = ""
        UIView.animate(withDuration: 0.3) {
            self.titleLabel.alpha = 1
            self.navigationItem.titleView = self.titleLabel
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.hideSearchBar()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.trimmedText! != "" {
            self.searchContact(name: searchBar.trimmedText!)
        }
    }
    
}

// MARK: - Display Bulletin Methods
extension HomeViewController {
    /**
     * Displays the bulletin.
     */
    
    fileprivate func showDeleteContactBulletin(contact: CNContact) {
        let deleteContactPage = BulletinDataSource.makeDeleteContactPage(contact: contact)
        bulletinManager = BulletinManager(rootItem: deleteContactPage)
        bulletinManager.backgroundViewStyle = .dimmed
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
    }
}
