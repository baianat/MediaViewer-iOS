//
//  Utils.swift
//  Nuke
//
//  Created by Omar on 2/24/21.
//

import Foundation
extension String {
    var localized: String {
        return NSLocalizedString(lowercased(), tableName: nil, bundle: thisBundle, value: self, comment: self)
    }
    
    var image: UIImage? {
        return UIImage(named: self,
                       in: thisBundle,
                       compatibleWith: nil)
    }
    private var thisBundle: Bundle {
        Bundle(for: ImageViewerViewController.self)
    }
}
