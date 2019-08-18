//
//  ContactsTableViewCell.swift
//  Contacts
//
//  Created by Satish Babariya on 28/07/17.
//  Copyright © 2017 Satish Babariya. All rights reserved.
//

import UIKit
import Contacts
import SwiftTheme
import FontAwesome_swift

class ContactCell: SwipeTableViewCell {
    
    var view: UIView!
    var imgUser: UIImageView!
    var lblName: UILabel!
    var lblNumber: UILabel!
    var CellHeight: CGFloat = CGFloat()
    var stackView: UIStackView!
    var bgColorView: UIView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadViewControls()
        setViewlayout()
    }
    
    func loadViewControls() {
        theme_backgroundColor = ThemeColors.backgroundColor
        
        bgColorView = UIView()
        bgColorView.theme_backgroundColor = ThemeColors.tableSelectionBG
        selectedBackgroundView = bgColorView
        
        CellHeight = contentView.bounds.height
        
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        imgUser = UIImageView()
        imgUser.translatesAutoresizingMaskIntoConstraints = false
        imgUser.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.theme_borderColor = ThemeColors.tableHeaderColor
        imgUser.layer.theme_backgroundColor = ThemeColors.contactIconBGColor
        imgUser.layer.cornerRadius = imgUser.frame.height / 2
        imgUser.clipsToBounds = true
        view.addSubview(imgUser)
        
        lblName = UILabel()
        lblName.translatesAutoresizingMaskIntoConstraints = false
        lblName.theme_textColor = ThemeColors.textColor
        
        lblNumber = UILabel()
        lblNumber.translatesAutoresizingMaskIntoConstraints = false
        lblNumber.theme_textColor = ThemeColors.textColor
        
        stackView = UIStackView(arrangedSubviews: [lblName, lblNumber])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 3
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.addSubview(lblName)
        stackView.addSubview(lblNumber)
        view.addSubview(stackView)
        
    }
    
    func setViewlayout() {
        
        // Layout
        let space: CGFloat = 8.0
        let imgHeight: CGFloat = imgUser.bounds.height
        let imgwidth: CGFloat = imgUser.bounds.width
        let matrix: Dictionary = ["space": space, "imgHeight": imgHeight, "imgwidth": imgwidth]
        
        let views: [String: Any] = ["view": view, "imgUser": imgUser, "stackView": stackView]
        
        let horizontalConstraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-space-[view]-space-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: matrix, views: views)
        contentView.addConstraints(horizontalConstraint)
        
        let verticalConstraint: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-space-[view]-space-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: matrix, views: views)
        contentView.addConstraints(verticalConstraint)
        
        let horizontalConstraintForView: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imgUser(==imgwidth)]-[stackView]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: matrix, views: views)
        view.addConstraints(horizontalConstraintForView)
        
        let verticalConstraintForView: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-8@251-[imgUser]-8@251-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: matrix, views: views)
        view.addConstraints(verticalConstraintForView)
        
        let verticalConstraintForStackView: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-8@751-[stackView]-8@751-|", options: [.alignAllTop, .alignAllBottom], metrics: matrix, views: views)
        view.addConstraints(verticalConstraintForStackView)
        
        imgUser.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
        imgUser.heightAnchor.constraint(equalToConstant: imgHeight).isActive = true
        layoutIfNeeded()
        
    }
    
    func setData(contact: CNContact) {
        lblName.text = "\(contact.givenName.trimmed) \(contact.familyName.trimmed)".trimmed.isEmpty ? "No Name" : "\(contact.givenName.trimmed) \(contact.familyName.trimmed)".trimmed
        lblNumber.text = contact.phoneNumbers.count > 0 ? contact.phoneNumbers[0].value.stringValue : (contact.emailAddresses.count > 0 ? contact.emailAddresses[0].value as String : nil)
        lblNumber.isHidden = lblNumber.text == nil ? true : false
        if let imgData: Data = contact.imageData {
            imgUser.image = UIImage(data: imgData)
        } else {
            imgUser.theme_image = ThemeColors.contactIconImage
        }
    }
}
