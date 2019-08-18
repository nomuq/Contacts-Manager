

import UIKit
import Foundation
import SwiftMessages
import GoogleMobileAds
import SwiftTheme

// MARK: UIViewController Extension
extension UIViewController {
    func displayCenterToast(message: String, type: Theme) {
        messageMaker(message: message, position: SwiftMessages.PresentationStyle.center, type: type)
    }
    
    func displayTopToast(message: String, type: Theme) {
        messageMaker(message: message, position: SwiftMessages.PresentationStyle.top, type: type)
    }
    
    func displayBottomToast(message: String, type: Theme) {
        messageMaker(message: message, position: SwiftMessages.PresentationStyle.bottom, type: type)
    }
    
    fileprivate func messageMaker(message: String, position: SwiftMessages.PresentationStyle, type: Theme) {
        let messageView: MessageView = MessageView.viewFromNib(layout: .cardView)
        messageView.configureTheme(type)
        messageView.bodyLabel?.text = message
        // messageView.bodyLabel?.isHidden = true
        messageView.button?.isHidden = true
        messageView.titleLabel?.isHidden = true
        // messageView.iconImageView?.isHidden = true
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = position
        config.duration = .seconds(seconds: 2.0)
        SwiftMessages.show(config: config, view: messageView)
    }
    
}

// MARK: - UISearchBar
public extension UISearchBar {
    
    public func setTextColor(color: ThemeColorPicker) {
        let subViews: [UIView] = subviews.flatMap { $0.subviews }
        guard let textField: UITextField = (subViews.filter { $0 is UITextField }).first as? UITextField else { return }
        textField.theme_textColor = color
    }
    public func setTextColor(color: UIColor) {
        let subViews: [UIView] = subviews.flatMap { $0.subviews }
        guard let textField: UITextField = (subViews.filter { $0 is UITextField }).first as? UITextField else { return }
        textField.textColor = color
    }
    
}

// MARK: - String
extension String {
    subscript(r: Range<Int>) -> String? {
        get {
            let stringCount = self.count as Int
            if (stringCount < r.upperBound) || (stringCount < r.lowerBound) {
                return nil
            }
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound - r.lowerBound)
            return String(self[(startIndex ..< endIndex)])
        }
    }
    
    func containsAlphabets() -> Bool {
        //Checks if all the characters inside the string are alphabets
        let set = CharacterSet.letters
        return self.utf16.contains( where: {
            guard let unicode = UnicodeScalar($0) else { return false }
            return set.contains(unicode)
        })
    }
}

