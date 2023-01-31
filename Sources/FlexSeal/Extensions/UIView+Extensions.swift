//
//  UIView+Extensions.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import UIKit

extension UIView {
  /**
   Recursively searches for the self's view controller, if one exists.
   */
  var viewController: UIViewController? {
    if let nextResponder = self.next as? UIViewController {
      return nextResponder
    } else if let nextResponder = self.next as? UIView {
      return nextResponder.viewController
    } else {
      return nil
    }
  }
}
