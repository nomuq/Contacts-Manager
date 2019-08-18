//
//  ConfermationBulletinItem.swift
//  Contacts
//
//  Created by Satish Babariya on 12/8/17.
//  Copyright © 2017 Satish Babariya. All rights reserved.
//

import Foundation
import UIKit
import Closures

class ConfirmationBulletinPage: NSObject, BulletinItem {
    
    var manager: BulletinManager?
    var isDismissable: Bool = false
    var dismissalHandler: ((BulletinItem) -> Void)?
    var nextItem: BulletinItem?
    
    let appearance = BulletinAppearance()
    var actionHandler: ((BulletinItem) -> Void)?
    
    fileprivate var descriptionLabel: UILabel?
    fileprivate var doneButton: HighlightButtonWrapper?
    fileprivate var cancleButton: UIButton?
    
    fileprivate var titleLabelText: String!
    fileprivate var descriptionLabelText: String?
    fileprivate var doneButtonTitle: String!
    
    init(title: String, description: String?, buttonTitle: String) {
        titleLabelText = title
        descriptionLabelText = description
        doneButtonTitle = buttonTitle
    }
    
    func makeArrangedSubviews() -> [UIView] {
        
        var arrangedSubviews = [UIView]()
        let interfaceBuilder = BulletinInterfaceBuilder(appearance: appearance)
        
        let titleLabel = interfaceBuilder.makeTitleLabel(text: titleLabelText)
        arrangedSubviews.append(titleLabel)
        
        if descriptionLabelText != nil {
            descriptionLabel = interfaceBuilder.makeDescriptionLabel()
            descriptionLabel!.text = descriptionLabelText
            arrangedSubviews.append(descriptionLabel!)
        }
        
        doneButton = interfaceBuilder.makeActionButton(title: doneButtonTitle)
        doneButton!.button.onTap { [weak self] in
            if self == nil {
                return
            }
            self!.actionHandler?(self!)
        }
        arrangedSubviews.append(doneButton!)
        
        //        cancleButton = interfaceBuilder.makeAlternativeSimpleButton(title: "Cancle")
        //        arrangedSubviews.append(cancleButton!)
        
        return arrangedSubviews
        
    }
    
    func tearDown() {
        doneButton?.button.removeTarget(self, action: nil, for: .touchUpInside)
    }
    
}
