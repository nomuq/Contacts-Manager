//
//  RestoreBulletinItem.swift
//  Contacts
//
//  Created by Satish Babariya on 11/29/17.
//  Copyright © 2017 Satish Babariya. All rights reserved.
//

import Foundation
import UIKit
class RestoreBulletinItem: PageBulletinItem {
    
    private let feedbackGenerator = SelectionFeedbackGenerator()
    
    override func actionButtonTapped(sender: UIButton) {
        
        // Play an haptic feedback
        
        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()
        
        // Call super
        super.actionButtonTapped(sender: sender)
        
    }
    
    override func alternativeButtonTapped(sender: UIButton) {
        
        // Play an haptic feedback
        
        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()
        
        // Call super
        super.alternativeButtonTapped(sender: sender)
    }
    
}

