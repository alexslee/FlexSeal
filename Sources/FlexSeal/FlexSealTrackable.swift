//
//  FlexSealTrackable.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation

/**
 Provides lifecycle tracking functionality to any class that conforms to it, viewable via our internal
 debug tool.

 Usage:
 1. Have the class in question conform to the protocol.
 2. Call the provided ``track(initialConfig:)`` method from your class' initializer.
 3. Profit
 */
public protocol FlexSealTrackable { }

public extension FlexSealTrackable {
  /**
   Just call this in the conforming entity's initializer and it'll be tracked!
   - Parameters:
     - initialConfig: Provide the name you want to use to represent this class, and an initial max count.
     You can change that count at any other point during runtime!
   */
  func track(initialConfig: FlexSealTrackedClass) {
    DispatchQueue.main.async {
      FlexSealViewModel.shared.track(self, trackedClass: initialConfig)
    }
  }
}
