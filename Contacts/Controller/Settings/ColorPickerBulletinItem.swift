//
//  ColorBulletinPicker.swift
//  Contacts
//
//  Created by Satish Babariya on 11/28/17.
//  Copyright © 2017 Satish Babariya. All rights reserved.
//

import Foundation
import UIKit

class ColorPickerBulletinItem: NSObject, BulletinItem , ColorPickerViewDelegate, ColorPickerViewDelegateFlowLayout {
    var nextItem: BulletinItem?
    
    var manager: BulletinManager?
    var isDismissable: Bool = false
    var dismissalHandler: ((BulletinItem) -> Void)?
    
    let appearance = BulletinAppearance()
    var actionHandler: ((BulletinItem) -> Void)? = nil
    
    fileprivate var descriptionLabel: UILabel?
    fileprivate var doneButton: HighlightButtonWrapper?
    
    fileprivate var colorPickerView: ColorPickerView!
    
    func makeArrangedSubviews() -> [UIView] {
        
        var arrangedSubviews = [UIView]()
        let interfaceBuilder = BulletinInterfaceBuilder(appearance: appearance)
        
        let titleLabel = interfaceBuilder.makeTitleLabel(text: "Select Theme Color")
        arrangedSubviews.append(titleLabel)
        
        colorPickerView = ColorPickerView()
        colorPickerView.delegate = self
        colorPickerView.layoutDelegate = self
        colorPickerView.style = .circle
        colorPickerView.selectionStyle = .none
        colorPickerView.isSelectedColorTappable = false
        //colorPickerView.preselectedIndex = AppThemes.current.rawValue
        colorPickerView.heightAnchor.constraint(greaterThanOrEqualToConstant: UIDevice.current.userInterfaceIdiom == .pad  ? 200 : 200).isActive = true
        arrangedSubviews.append(colorPickerView)
        
        
//        doneButton = interfaceBuilder.makeActionButton(title: "Done")
//        doneButton!.button.addTarget(self, action: #selector(doneButtonTapped(sender:)), for: .touchUpInside)
//        arrangedSubviews.append(doneButton!)
        
        return arrangedSubviews
        
    }
    
    func tearDown() {
        doneButton?.button.removeTarget(self, action: nil, for: .touchUpInside)
    }
    
    // MARK: - ColorPickerViewDelegate
    
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        AppThemes.switchTo(theme: indexPath.row)
        AppThemes.saveLastTheme()
        manager?.dismissBulletin(animated: true)
    }
    
    // MARK: - ColorPickerViewDelegateFlowLayout
    
    func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 48, height: 48)
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 11
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

