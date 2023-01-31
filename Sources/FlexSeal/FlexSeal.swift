//
//  FlexSeal.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import SwiftUI
import UIKit

public struct FlexSeal {
  static var isVisible = false

  private static var passThroughWindow: PassThroughWindow?
  private static let nonPassThroughTag = 666

  /**
   _Do you really need documentation for this?_ -- er, I mean, starts up the FlexSeal window in the given scene. Will
   resume a previously stopped session if one exists.
   */
  public static func start(in windowScene: UIWindowScene) {
    if passThroughWindow == nil {
      let newWindow = PassThroughWindow(windowScene: windowScene)
      newWindow.nonPassThroughTag = nonPassThroughTag

      let hostingController = UIHostingController(rootView: FlexSealContentView(viewModel: .shared))
      hostingController.view?.backgroundColor = .clear
      hostingController.view?.tag = PassThroughWindow.flexSealParentTag

      newWindow.rootViewController = hostingController
      newWindow.isHidden = false

      passThroughWindow = newWindow
    } else {
      passThroughWindow?.isHidden = false
    }
  }

  /**
   Hides the FlexSeal window without deallocating the backing data source, letting you make the same session visible
   at any point.
   */
  public static func hide() {
    passThroughWindow?.isHidden = true
  }

  // TODO: support clearing properly without memory leaks of your own you ironic sack of shit
//  public static func clear() {
//    passThroughWindow = nil
//  }

  /**
   Alter the max count of an entity for which you had already started tracking at least once prior.
   - Parameters:
     - newVal: The new max count
     - name: The name of the corresponding entity.
   */
  public static func changeMaxCount(_ newVal: Int, for name: String) {
    FlexSealViewModel.shared.changeMaxCount(newVal, for: name)
  }
}
