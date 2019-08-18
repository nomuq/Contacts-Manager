//
//  PlistManager.swift
//  Contacts
//
//  Created by Satish Babariya on 11/25/17.
//  Copyright © 2017 Satish Babariya. All rights reserved.
//

import Foundation
import UIKit

class PListManager: NSObject {
    
    // MARK: - Attributes -
    var filePath: String!
    
    // MARK: - Lifecycle -
    convenience init(fileName: String) {
        self.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Interface -
    
    func readFromPlist(_ fileName: String) -> AnyObject {
        let paths = Bundle.main.path(forResource: fileName, ofType: "plist")
        var plistData: AnyObject!
        do {
            let fileData: Data = try Data(contentsOf: URL(fileURLWithPath: paths!))
            plistData = try PropertyListSerialization.propertyList(from: fileData, options: PropertyListSerialization.ReadOptions.mutableContainers, format: nil) as AnyObject!
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        return plistData
    }
}
