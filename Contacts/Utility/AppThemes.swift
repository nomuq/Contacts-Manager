//
//  AppTheme.swift
//  Contacts
//
//  Created by Satish Babariya on 11/25/17.
//  Copyright © 2017 Satish Babariya. All rights reserved.
//

import Foundation
import SwiftTheme
import FontAwesome_swift

//private let lastThemeIndexKey = "lastedThemeIndex"
//private let defaults = UserDefaults.standard

enum AppThemes: Int {
    
    case light = 0
    case blue = 1
    case night = 2
    case conifer = 3
    case blue_Ribbon = 4
    case fuchsia_Blue = 5
    case bright_Sun = 6
    case monzaapprox = 7
    case cinnabarapprox = 8
    case picton_Blue = 9
    
    // MARK: -
    
    static var current: AppThemes { return AppThemes(rawValue: ThemeManager.currentThemeIndex)! }
    static var before = AppThemes.night
    
    // MARK: - Switch Theme
    
    static func switchTo(theme: AppThemes) {
        before = current
        ThemeManager.setTheme(index: theme.rawValue)
    }
    
    static func switchTo(theme: Int) {
        before = current
        ThemeManager.setTheme(index: theme)
    }
    
    static func switchToNext() {
        var next = ThemeManager.currentThemeIndex + 1
        if next > 9 { next = 0 } // cycle and without Night
        switchTo(theme: AppThemes(rawValue: next)!)
    }
    
    // MARK: - Switch Night
    
    static func switchNight(isToNight: Bool) {
        switchTo(theme: isToNight ? .night : before)
    }
    
    static func isNight() -> Bool {
        return current == .night
    }
    
    // MARK: - Save & Restore
    static func restoreLastTheme() {
        switchTo(theme: Defaults[.lastThemeIndexKey])
        //switchTo(theme: AppThemes(rawValue: defaults.integer(forKey: lastThemeIndexKey))!)
    }
    
    static func saveLastTheme() {
        Defaults[.lastThemeIndexKey] = ThemeManager.currentThemeIndex
        //defaults.set(ThemeManager.currentThemeIndex, forKey: lastThemeIndexKey)
    }
    
}

enum ThemeColors {
    
    static let backgroundColor: ThemeColorPicker = ["#FFF", "#00B3ED", "#292b38", "#91DC5A", "#006DF0", "#933EC5", "#FFDA44", "#D80027", "#EB4F38", "#56ABE4"]
    
    static let textColor: ThemeColorPicker = ["#000", "#ECF0F1", "#ECF0F1", "#000", "#ECF0F1", "#ECF0F1", "#000", "#ECF0F1", "#ECF0F1", "#ECF0F1"]
    
    internal static let barTextColors = ["#000", "#FFF", "#FFF", "#000", "#FFF", "#FFF", "#000", "#FFF", "#FFF", "#FFF"]
    static let barTextColor = ThemeColorPicker.pickerWithColors(barTextColors)
    static let barTintColor: ThemeColorPicker = ["#FFF", "#00B3ED", "#01040D", "#91DC5A", "#006DF0", "#933EC5", "#FFDA44", "#D80027", "#EB4F38", "#56ABE4"]
    
    static let separatorColor: ThemeColorPicker = ["#000", "#FFF", "#FFF", "#FFF", "#FFF", "#FFF", "#FFF", "#FFF", "#FFF", "#FFF"]
    static let tableHeaderColor: ThemeCGColorPicker = ["#000", "#ECF0F1", "#ECF0F1", "#000", "#ECF0F1", "#ECF0F1", "#000", "#ECF0F1", "#ECF0F1", "#ECF0F1"]
    static let barStyleColor: ThemeBarStylePicker = [UIBarStyle.default, UIBarStyle.black, UIBarStyle.black, UIBarStyle.default, UIBarStyle.black, UIBarStyle.black, UIBarStyle.default, UIBarStyle.black, UIBarStyle.black, UIBarStyle.black]
    
    static let bulletinBordButtonColor: ThemeColorPicker = ["#000", "#00B3ED", "#01040D", "#91DC5A", "#006DF0", "#933EC5", "#FFDA44", "#D80027", "#EB4F38", "#56ABE4"]
    static let bulletinBordTextColor: ThemeColorPicker = ["#ECF0F1", "#ECF0F1", "#ECF0F1", "#000", "#ECF0F1", "#ECF0F1", "#000", "#ECF0F1", "#ECF0F1", "#ECF0F1"]
    
    static let pullToRefreshColor: ThemeCGColorPicker = ["#FFF", "#00B3ED", "#292b38", "#91DC5A", "#006DF0", "#933EC5", "#FFDA44", "#D80027", "#EB4F38", "#56ABE4"]
    
    static let contactIconImage: ThemeImagePicker = ["light", "blue", "night", "conifer", "blue_Ribbon", "fuchsia_Blue", "bright_Sun", "monzaapprox", "cinnabarapprox", "picton_Blue"]
    static let contactIconBGColor: ThemeCGColorPicker = ["#FFF", "#FFF", "#FFF", "#000", "#FFF", "#FFF", "#000", "#FFF", "#FFF", "#FFF"]
    
    static func editIcon(size: Int) -> UIImage {
        switch AppThemes.current {
        case .light, .conifer, .bright_Sun:
            return UIImage.fontAwesomeIcon(name: .edit, textColor: UIColor.black, size: CGSize(width: size, height: size))
        default:
            return UIImage.fontAwesomeIcon(name: .edit, textColor: UIColor.white, size: CGSize(width: size, height: size))
        }
    }
    
    static func trashIcon(size: Int) -> UIImage {
        switch AppThemes.current {
        case .light, .conifer, .bright_Sun:
            return UIImage.fontAwesomeIcon(name: .trash, textColor: UIColor.black, size: CGSize(width: size, height: size))
        default:
            return UIImage.fontAwesomeIcon(name: .trash, textColor: UIColor.white, size: CGSize(width: size, height: size))
        }
    }
    
    static func FAIcon(icon: FontAwesome, size: Int) -> UIImage {
        switch AppThemes.current {
        case .light, .conifer, .bright_Sun:
            return UIImage.fontAwesomeIcon(name: icon, textColor: UIColor.black, size: CGSize(width: size, height: size))
        default:
            return UIImage.fontAwesomeIcon(name: icon, textColor: UIColor.white, size: CGSize(width: size, height: size))
        }
    }
    
    static let destructiveSwipeCellBG: ThemeColorPicker = ["FF3C30"]
    static let defaultSwipeCellBG: ThemeColorPicker = ["#FFF", "#00B3ED", "#292b38", "#91DC5A", "#006DF0", "#933EC5", "#FFDA44", "#D80027", "#EB4F38", "#56ABE4"]
    static let tableSelectionBG: ThemeColorPicker = ["#b2b2b2", "#99e0f7", "#94959b", "#bdea9c", "#7fb6f7", "#c99ee2", "#ffeca1", "#eb7f93", "#f5a79b", "#aad5f1"]
    
    static let activityIndicatorStyle :ThemeActivityIndicatorViewStylePicker = [.gray,.white,.white,.gray,.white,.white,.gray,.white,.white,.white]
}

