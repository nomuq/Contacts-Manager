//
//  SettingsViewController.swift
//  Contacts
//
//  Created by Satish Babariya on 11/25/17.
//  Copyright © 2017 Satish Babariya. All rights reserved.
//

import UIKit
import SwiftTheme
import BadgeSwift
import FontAwesome_swift
import Closures
import MessageUI
import Contacts

enum SettingsList: Int {
    
    case themes = 0
    case removeAds = 1
    case backup = 2
    case restore = 3
    case trash = 4
    case duplicates = 5
    case sharecontact = 6
    case aboutUs = 7
    case privercyPolicy = 8
    case appVersion = 9
    case emailContacts = 10
}

class SettingsViewController: UIViewController {
    
    // MARK: - Attributes
    
    fileprivate var arrList: NSArray!
    fileprivate var tableView: UITableView!
    fileprivate var trashCount: Int = 0
    fileprivate var duplicatesConunt: Int = 0
    var bulletinManager: BulletinManager!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
        self.loadViewControls()
        self.setViewlayout()
        self.readPlist()
        
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
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifire.settingsCell)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .singleLine
        self.tableView.theme_separatorColor = ThemeColors.separatorColor
        self.tableView.theme_backgroundColor = ThemeColors.backgroundColor
        self.tableView.separatorInset = .zero
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 60
        self.tableView.isMultipleTouchEnabled = false
        self.tableView.separatorStyle = .none
        self.view.addSubview(self.tableView)
        
        //SwiftyAd.shared.showBanner(from: self)
        
    }
    
    fileprivate func setViewlayout() {
        
        let views: [String: Any] = ["tableView": tableView] //, "bannerViewAd": SwiftyAd.shared.bannerViewAd!]
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
    
    fileprivate func readPlist() {
        let data = PListManager().readFromPlist("Settings")
        arrList = NSArray()
        if let arrPlist: NSArray = data as? NSArray {
            self.arrList = arrPlist
        }
        self.tableView.reloadData()
    }
    
    fileprivate func aboutUsAction() {
        if let url = URL(string: "https://example.com/") {
            UIApplication.shared.open(url, options: [:])
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

//MARK: - Display Bulletin Methods
extension SettingsViewController {
    /**
     * Displays the bulletin.
     */
    
    // In App Purchase Methods
    fileprivate func showInAppBulletin() {
        let inAppPurchasePage = BulletinDataSource.makeInAppPurchasePage()
        bulletinManager = BulletinManager(rootItem: inAppPurchasePage)
        bulletinManager.backgroundViewStyle = .dimmed
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
        
    }
    fileprivate func reloadInAppManager() {
        let inAppPurchasePage = BulletinDataSource.makeInAppPurchasePage()
        bulletinManager = BulletinManager(rootItem: inAppPurchasePage)
    }
    
    // Backup Methods
    fileprivate func showBackupBulletin() {
        let backupPage = BulletinDataSource.makeBackupPage()
        bulletinManager = BulletinManager(rootItem: backupPage)
        bulletinManager.backgroundViewStyle = .dimmed
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
        
    }
    fileprivate func reloadBackupManager() {
        let backupPage = BulletinDataSource.makeBackupPage()
        bulletinManager = BulletinManager(rootItem: backupPage)
    }
    
    // Restore Methods
    fileprivate func showRestoreBulletin() {
        let restorePage = BulletinDataSource.makeRestorePage()
        bulletinManager = BulletinManager(rootItem: restorePage)
        bulletinManager.backgroundViewStyle = .dimmed
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
        
    }
    fileprivate func reloadRestoreManager() {
        let restorePage = BulletinDataSource.makeRestorePage()
        bulletinManager = BulletinManager(rootItem: restorePage)
    }
    
    //Color Picker Methods
    fileprivate func showColorPickerBulletin() {
        let colorPickerPage = BulletinDataSource.makeColorPickerPage()
        bulletinManager = BulletinManager(rootItem: colorPickerPage)
        bulletinManager.backgroundViewStyle = .dimmed
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
        
    }
    fileprivate func reloadColorPickerManager() {
        let colorPickerPage = BulletinDataSource.makeColorPickerPage()
        bulletinManager = BulletinManager(rootItem: colorPickerPage)
    }
    
}

// MARK: - Tableview Datasource Delegate Methods
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if arrList != nil {
            return arrList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dictList: NSDictionary = arrList[section] as? NSDictionary {
            if let items: NSArray = dictList["item"] as? NSArray {
                return items.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30.0))
        let label: UILabel = UILabel(frame: CGRect(x: 15, y: 4, width: UIScreen.main.bounds.width - 30, height: 22.0))
        //label.font = UIFont(name: FontStyle.medium, size: 20)
        label.theme_textColor = ThemeColors.textColor
        if let dictList: NSDictionary = arrList[section] as? NSDictionary {
            if let title: String = dictList["title"] as? String {
                label.text = title
            }
        } else {
            label.text = ""
        }
        view.addSubview(label)
        let border = CALayer()
        border.theme_backgroundColor = ThemeColors.tableHeaderColor
        border.frame = CGRect(x: 0, y: view.frame.height - 2.0, width: view.frame.width, height: 2.0)
        view.layer.addSublayer(border)
        view.theme_backgroundColor = ThemeColors.backgroundColor
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifire.settingsCell, for: indexPath)
        cell.theme_backgroundColor = ThemeColors.backgroundColor
        let bgColorView: UIView = UIView()
        bgColorView.theme_backgroundColor = ThemeColors.tableSelectionBG
        cell.selectedBackgroundView = bgColorView
        if let dictList: NSDictionary = arrList[(indexPath as NSIndexPath).section] as? NSDictionary {
            if let items: NSArray = dictList["item"] as? NSArray {
                if let item: NSDictionary = items[indexPath.row] as? NSDictionary {
                    if let title: String = item["title"] as? String {
                        cell.textLabel?.text = title
                        cell.textLabel?.theme_textColor = ThemeColors.textColor
                    }
                    if let icon: String = item["icon"] as? String {
                        //cell.imageView?.image =  UIImage.fontAwesomeIcon(name: FontAwesome.fromCode("fa-500px")!, textColor: UIColor.black, size: CGSize(width: 35, height: 35))
                        cell.imageView?.theme_image = ThemeImagePicker(images:
                            UIImage.fontAwesomeIcon(name: FontAwesome.fromCode(icon)!, textColor: UIColor.black, size: CGSize(width: 35, height: 35)),
                                                                       UIImage.fontAwesomeIcon(name: FontAwesome.fromCode(icon)!, textColor: UIColor.white, size: CGSize(width: 35, height: 35)),
                                                                       UIImage.fontAwesomeIcon(name: FontAwesome.fromCode(icon)!, textColor: UIColor.white, size: CGSize(width: 35, height: 35)),
                                                                       UIImage.fontAwesomeIcon(name: FontAwesome.fromCode(icon)!, textColor: UIColor.black, size: CGSize(width: 35, height: 35)),
                                                                       UIImage.fontAwesomeIcon(name: FontAwesome.fromCode(icon)!, textColor: UIColor.white, size: CGSize(width: 35, height: 35)),
                                                                       UIImage.fontAwesomeIcon(name: FontAwesome.fromCode(icon)!, textColor: UIColor.white, size: CGSize(width: 35, height: 35)),
                                                                       UIImage.fontAwesomeIcon(name: FontAwesome.fromCode(icon)!, textColor: UIColor.black, size: CGSize(width: 35, height: 35)),
                                                                       UIImage.fontAwesomeIcon(name: FontAwesome.fromCode(icon)!, textColor: UIColor.white, size: CGSize(width: 35, height: 35)),
                                                                       UIImage.fontAwesomeIcon(name: FontAwesome.fromCode(icon)!, textColor: UIColor.white, size: CGSize(width: 35, height: 35)),
                                                                       UIImage.fontAwesomeIcon(name: FontAwesome.fromCode(icon)!, textColor: UIColor.white, size: CGSize(width: 35, height: 35)))
                        
                        //cell.imageView?.image = UIImage(icon: FAType(rawValue: icon)!, size: CGSize(width: 35, height: 35))
                        // cell.icon.setFAIconWithName(icon: FAType(rawValue: icon)!, textColor: Color.separatorColor.value)
                    }
                    if let type: String = item["type"] as? String {
                        
                        switch Int(type)! {
                            
                        case SettingsList.trash.rawValue:
                            if trashCount > 0 {
                                let lblNumber: BadgeSwift = BadgeSwift(frame: CGRect(x: 0, y: 0, width: (cell.imageView?.bounds.height)!, height: (cell.imageView?.bounds.height)!))
                                //lblNumber.badgeColor = Color.settingBadgeBG.value
                                lblNumber.text = String(trashCount)
                                //lblNumber.textColor = Color.navigationTitle.value
                                lblNumber.shadowOpacityBadge = 0
                                lblNumber.cornerRadius = 10
                                cell.selectionStyle = .gray
                                cell.accessoryView = lblNumber
                                
                            } else {
                                cell.selectionStyle = .gray
                                cell.accessoryView = .none
                            }
                            break
                        case SettingsList.duplicates.rawValue:
                            if duplicatesConunt > 0 {
                                let lblNumber: BadgeSwift = BadgeSwift(frame: CGRect(x: 0, y: 0, width: (cell.imageView?.bounds.height)!, height: (cell.imageView?.bounds.height)!))
                                //lblNumber.badgeColor = Color.settingBadgeBG.value
                                lblNumber.text = String(duplicatesConunt)
                                //lblNumber.textColor = Color.navigationTitle.value
                                lblNumber.shadowOpacityBadge = 0
                                lblNumber.cornerRadius = 10
                                
                                cell.selectionStyle = .gray
                                cell.accessoryView = lblNumber
                                
                            } else {
                                cell.selectionStyle = .gray
                                cell.accessoryView = .none
                            }
                            break
                        case SettingsList.sharecontact.rawValue:
                            let autoEmptySwitch: UISwitch = UISwitch()
                            autoEmptySwitch.isOn = Defaults[.isShareContactEnable]
                            autoEmptySwitch.theme_onTintColor = ThemeColors.tableSelectionBG
                            autoEmptySwitch.onChange(handler: { [weak self] bool in
                                if self == nil {
                                    return
                                }
                                Defaults[.isShareContactEnable] = bool
                            })
                            cell.accessoryView = autoEmptySwitch
                            cell.selectionStyle = .none
                            break
                        case SettingsList.appVersion.rawValue:
                            cell.textLabel?.text = "Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!) Build \(Bundle.main.infoDictionary!["CFBundleVersion"]!)"
                            cell.accessoryView = .none
                            cell.selectionStyle = .none
                            break
                        default:
                            cell.accessoryView = .none
                            break
                        }
                        
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let dictList: NSDictionary = arrList[(indexPath as NSIndexPath).section] as? NSDictionary {
            if let items: NSArray = dictList["item"] as? NSArray {
                if let item: NSDictionary = items[indexPath.row] as? NSDictionary {
                    if let type: String = item["type"] as? String {
                        
                        switch Int(type)! {
                        case SettingsList.themes.rawValue:
                            //AppThemes.switchToNext()
                            self.showColorPickerBulletin()
                            self.tableView.reloadData()
                            break
                        case SettingsList.removeAds.rawValue:
                            self.showInAppBulletin()
                            break
                        case SettingsList.backup.rawValue:
                            self.showBackupBulletin()
                            break
                        case SettingsList.restore.rawValue:
                            self.showRestoreBulletin()
                            break
                        case SettingsList.aboutUs.rawValue:
                            self.aboutUsAction()
                            break
                        case SettingsList.emailContacts.rawValue:
                            self.emailContacts()
                            break
                        default:
                            break
                        }
                        
                    }
                }
            }
        }
    }
}

// MARK: - Mail Composer Delegate Methods
extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    fileprivate func emailContacts() {
        if MFMailComposeViewController.canSendMail() {
            //Fetch All Contacts
            CNContactStore().requestAccess(for: .contacts) { [weak self] grandted, _ in
                if self == nil {
                    return
                }
                if grandted {
                    let fetchRequest: CNContactFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
                    var contacts = [CNContact]()
                    CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone)
                    fetchRequest.mutableObjects = false
                    fetchRequest.unifyResults = true
                    fetchRequest.sortOrder = .givenName
                    do {
                        try CNContactStore().enumerateContacts(with: fetchRequest) { (contact, _) -> Void in
                            contacts.append(contact)
                        }
                        let data: Data = try CNContactVCardSerialization.data(with: contacts)
                        let mailComposer: MFMailComposeViewController = MFMailComposeViewController()
                        mailComposer.mailComposeDelegate = self
                        mailComposer.setSubject("Contacts")
                        mailComposer.addAttachmentData(data, mimeType: "text/vcf", fileName: "contacts.vcf")
                        self!.navigationController?.present(mailComposer, animated: true, completion: nil)
                    } catch {
                        self!.displayBottomToast(message: "Error, Please try again.", type: .error)
                        return
                    }
                } else {
                    self!.displayBottomToast(message: "No Contact Acess Permission", type: .warning)
                    return
                }
            }
        }
    }
}
