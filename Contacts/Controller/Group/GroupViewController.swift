//
//  GroupViewController.swift
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

class GroupViewController: UIViewController {
    
    // MARK: - Attributes
    
    fileprivate var arrGroups: [CNGroup] = []
    fileprivate var disposeBag: DisposeBag! = DisposeBag()
    fileprivate var tableView: UITableView!
    fileprivate var diffCalculator: SingleSectionTableViewDiffCalculator<CNGroup>?
    fileprivate let store: CNContactStore = CNContactStore()
    fileprivate var bulletinManager: BulletinManager!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Groups"
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
        self.tableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: CellIdentifire.grouplistCell)
        self.tableView.rowHeight = UITableViewAutomaticDimension
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
        
        // SwiftyAd.shared.showBanner(from: self)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.showNewGroupTextFieldBulletin))
        SwiftEventBus.onMainThread(self, name: SwiftyNotification.reloadGroupList) { [weak self] (notification) in
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
                let contactsarr = Observable.of(self!.fetchGroups())
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
    
    fileprivate func fetchGroups() -> [CNGroup] {
        var groups: [CNGroup] = [CNGroup]()
        do {
            groups = try self.store.groups(matching: nil)
            return groups
        } catch {
            self.displayBottomToast(message: "Internal Error", type: .error)
            return groups
        }
    }
    
    fileprivate func deleteGroupAction(group: CNGroup) {
        let alertController: UIAlertController = UIAlertController(title: "Delete " + group.name, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(title: "Yes", style: UIAlertActionStyle.destructive, isEnabled: true) { [weak self] _ in
            if self == nil {
                return
            }
            let request: CNSaveRequest = CNSaveRequest()
            
            if let mutableGroup: CNMutableGroup = group.mutableCopy() as? CNMutableGroup {
                request.delete(mutableGroup)
            }
            do {
                try self!.store.execute(request)
                self?.loadData()
            } catch {
                self?.displayBottomToast(message: "Can't able to delete group.", type: .error)
            }
        }
        alertController.addAction(title: "Cancel", style: UIAlertActionStyle.cancel, isEnabled: true, handler: nil)
        alertController.show()
    }
    
    fileprivate func editGroupAction(group: CNGroup) {
        let alertController: UIAlertController = UIAlertController(title: "New Name", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(title: "Change", style: UIAlertActionStyle.destructive, isEnabled: true) { [weak self] _ in
            if self == nil {
                return
            }
            if let name: String = alertController.textFields?[0].text?.trimmingCharacters(in: .whitespaces), name != "" {
                let request: CNSaveRequest = CNSaveRequest()
                if let mutableGroup: CNMutableGroup = group.mutableCopy() as? CNMutableGroup {
                    mutableGroup.name = name
                    request.update(mutableGroup)
                }
                do {
                    try self!.store.execute(request)
                    self!.loadData()
                } catch {
                    self!.displayBottomToast(message: "Can't able to change name of the group.", type: .error)
                }
            }
        }
        alertController.addAction(title: "Cancel", style: UIAlertActionStyle.cancel, isEnabled: true, handler: nil)
        alertController.show()
    }
    
    @objc fileprivate func createGroupAction() {
        let alertController: UIAlertController = UIAlertController(title: "New Group Name", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(title: "Create", style: UIAlertActionStyle.destructive, isEnabled: true) { [weak self] _ in
            if self == nil {
                return
            }
            if let name: String = alertController.textFields?[0].text?.trimmingCharacters(in: .whitespaces), name != "" {
                let request: CNSaveRequest = CNSaveRequest()
                let group: CNMutableGroup = CNMutableGroup()
                group.name = name
                request.add(group, toContainerWithIdentifier: nil)
                do {
                    try self!.store.execute(request)
                    self!.loadData()
                } catch {
                    self!.displayBottomToast(message: "Can't able to change name of the group.", type: .error)
                }
            }
        }
        alertController.addAction(title: "Cancel", style: UIAlertActionStyle.cancel, isEnabled: true, handler: nil)
        alertController.show()
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
extension GroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return arrContacts.count
        return self.diffCalculator?.rows.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: SwipeTableViewCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifire.grouplistCell, for: indexPath) as? SwipeTableViewCell else { return UITableViewCell() }
        let bgColorView: UIView = UIView()
        bgColorView.theme_backgroundColor = ThemeColors.tableSelectionBG
        cell.selectedBackgroundView = bgColorView
        cell.delegate = self
        cell.theme_backgroundColor = ThemeColors.backgroundColor
        cell.textLabel?.theme_textColor = ThemeColors.textColor
        cell.textLabel?.text = self.diffCalculator?.rows[indexPath.row].name
        return cell
    }
    
}

// MARK: - UITableView Delegate
extension GroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let groupContactsViewController: GroupContactsViewController = GroupContactsViewController()
        groupContactsViewController.group = self.diffCalculator!.rows[indexPath.row]
        self.navigationController?.pushViewController(groupContactsViewController, animated: true)
    }
}

// MARK: - SwipeTableView CellDelegate
extension GroupViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .left {
            guard orientation == .left else { return nil }
            
            let editAction: SwipeAction = SwipeAction(style: .default, title: nil) { [weak self] _, indexPath in
                if self == nil {
                    return
                }
                self!.showChangeGroupNameTextFieldBulletin(group: self!.diffCalculator!.rows[indexPath.row])
            }
            editAction.hidesWhenSelected = true
            editAction.image = ThemeColors.editIcon(size: 30)
            
            let deleteAction = SwipeAction(style: .destructive, title: nil) { [weak self] _, indexPath in
                if self == nil {
                    return
                }
                self!.deleteGroupAction(group: self!.diffCalculator!.rows[indexPath.row])
                //self!.showDeleteGroupBulletin(group: self!.diffCalculator!.rows[indexPath.row])
            }
            deleteAction.image = ThemeColors.trashIcon(size: 30)
            deleteAction.hidesWhenSelected = true
            return [deleteAction, editAction]
            
        } else {
            guard orientation == .right else { return nil }
            return []
        }
        
    }
}

// MARK: - Display Bulletin Methods
extension GroupViewController {
    /**
     * Displays the bulletin.
     */
    
    @objc fileprivate func showNewGroupTextFieldBulletin() {
        let textFieldPage = BulletinDataSource.makeNewGroupTextFieldPage()
        bulletinManager = BulletinManager(rootItem: textFieldPage)
        bulletinManager.backgroundViewStyle = .dimmed
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
        
    }
    fileprivate func reloadNewGroupTextFieldBulletin() {
        let textFieldPage = BulletinDataSource.makeNewGroupTextFieldPage()
        bulletinManager = BulletinManager(rootItem: textFieldPage)
    }
    
    fileprivate func showChangeGroupNameTextFieldBulletin(group : CNGroup) {
        let textFieldPage = BulletinDataSource.editGroupNameTextFieldPage(group: group)
        bulletinManager = BulletinManager(rootItem: textFieldPage)
        bulletinManager.backgroundViewStyle = .dimmed
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
        
    }
    
    fileprivate func showDeleteGroupBulletin(group: CNGroup){
        let deleteGroupPage = BulletinDataSource.makeDeleteGroupPage(group: group)
        bulletinManager = BulletinManager(rootItem: deleteGroupPage)
        bulletinManager.backgroundViewStyle = .dimmed
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
    }
}
