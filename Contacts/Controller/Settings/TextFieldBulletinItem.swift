//
//  TextFieldBulletinItem.swift
//  Contacts
//
//  Created by Satish Babariya on 12/8/17.
//  Copyright © 2017 Satish Babariya. All rights reserved.
//

import Foundation
import UIKit

class TextFieldBulletinPage: NSObject, BulletinItem {
    
    var manager: BulletinManager?
    var isDismissable: Bool = false
    var dismissalHandler: ((BulletinItem) -> Void)?
    var nextItem: BulletinItem?
    
    let appearance = BulletinAppearance()
    var actionHandler: ((BulletinItem) -> Void)? = nil
        
    fileprivate var descriptionLabel: UILabel?
    var textField: UITextField?
    fileprivate var doneButton: HighlightButtonWrapper?
    
    fileprivate var titleLabelText : String!
    fileprivate var descriptionLabelText : String?
    fileprivate var textFieldPlaceholder : String!
    fileprivate var doneButtonTitle : String!
    
    init(title : String , description : String? , textFieldPlaceHolder : String , buttonTitle : String) {
        self.titleLabelText = title
        self.descriptionLabelText = description
        self.textFieldPlaceholder = textFieldPlaceHolder
        self.doneButtonTitle = buttonTitle
    }
    
    func makeArrangedSubviews() -> [UIView] {
        
        var arrangedSubviews = [UIView]()
        let interfaceBuilder = BulletinInterfaceBuilder(appearance: appearance)
        
        let titleLabel = interfaceBuilder.makeTitleLabel(text: self.titleLabelText)
        arrangedSubviews.append(titleLabel)
        
        if descriptionLabelText != nil{
            descriptionLabel = interfaceBuilder.makeDescriptionLabel()
            descriptionLabel!.text = self.descriptionLabelText
            arrangedSubviews.append(descriptionLabel!)
        }
        
        textField = UITextField()
        textField!.delegate = self
        textField!.borderStyle = .roundedRect
        textField!.returnKeyType = .done
        textField!.placeholder = self.textFieldPlaceholder
        arrangedSubviews.append(textField!)
        
        doneButton = interfaceBuilder.makeActionButton(title: self.doneButtonTitle)
        doneButton!.button.addTarget(self, action: #selector(doneButtonTapped(sender:)), for: .touchUpInside)
        arrangedSubviews.append(doneButton!)
        
        return arrangedSubviews
        
    }
    
    func tearDown() {
        textField?.delegate = nil
        doneButton?.button.removeTarget(self, action: nil, for: .touchUpInside)
    }
    
}

// MARK: - UITextFieldDelegate

extension TextFieldBulletinPage: UITextFieldDelegate {
    
    @objc func doneButtonTapped(sender: UIButton) {
        _ = textFieldShouldReturn(textField!)
    }
    
    func isInputValid(text: String?) -> Bool {
        
        if text == nil || text!.isEmpty {
            return false
        }
        
        return true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if isInputValid(text: textField.text) {
            
            textField.resignFirstResponder()
            actionHandler?(self)
            return true
            
        } else {
            
            descriptionLabel?.textColor = .red
            descriptionLabel?.text = "You must enter some text to continue."
            textField.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            return false
            
        }
        
    }
    
}
