//
//  FlexSealTrackedClass.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation

/**
 Contains metadata pertaining to a class being tracked by our leak checking tool. Leveraged in ``FlexSealViewModel``.
 */
public class FlexSealTrackedClass: Equatable, Comparable, ObservableObject {
  @Published var currentCount = 0
  @Published var maxAllowed = 0
  let name: String

  var objectAddresses = Set<String>()

  public init(name: String, initialMaxAllowed: Int) {
    self.name = name
    self.maxAllowed = initialMaxAllowed
  }

  /// Provides a string containing `currentCount` / `maxAllowed`, for use in displaying or printing.
  func fractionString() -> String {
    return "\(currentCount) / \(maxAllowed)"
  }

  /// Whether the current number of instances exceeds the currently specified maximum amount.
  func isLeaking() -> Bool {
    return currentCount > maxAllowed
  }

  // MARK: - Equatable

  public static func == (lhs: FlexSealTrackedClass, rhs: FlexSealTrackedClass) -> Bool {
    return lhs.name == rhs.name
  }

  // MARK: - Comparable

  public static func < (lhs: FlexSealTrackedClass, rhs: FlexSealTrackedClass) -> Bool {
    return lhs.name < rhs.name
  }
}
