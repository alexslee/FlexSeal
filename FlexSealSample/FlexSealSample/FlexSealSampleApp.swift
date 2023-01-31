//
//  FlexSealSampleApp.swift
//  FlexSealSample
//
//  Created by Alexander Lee on 2023-01-30.
//

import SwiftUI
import UIKit

// I hate NotificationCenter hacks, but can always count on Apple to not support something basic in SwiftUI like motion gesture recognition
extension UIWindow {
  static let shakeItUp = Notification.Name(rawValue: "shook")
  open override func motionEnded(_ motion: UIEvent.EventSubtype, with: UIEvent?) {
    guard motion == .motionShake else { return }
    NotificationCenter.default.post(name: Self.shakeItUp, object: nil)
  }
}

@main
struct FlexSealSampleApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView(viewModel: DummyViewModel())
      }
    }
  }
}
