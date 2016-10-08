//
//  UIViewControllerExtensions.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/7/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        }
        else {
            return self
        }
    }
}
