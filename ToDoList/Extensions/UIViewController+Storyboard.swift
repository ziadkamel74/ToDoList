//
//  UIViewController+Storyboard.swift
//  Rabel
//
//  Created by Ziad Kamel on 28/10/2021.
//

import UIKit

extension UIViewController {
    class func create<T: UIViewController>(storyboardName: String, identifier: String) -> T {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
}
