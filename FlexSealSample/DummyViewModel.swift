//
//  DummyViewModel.swift
//  FlexSealSample
//
//  Created by Alexander Lee on 2023-01-30.
//

import Foundation
import UIKit
import FlexSeal

class DummyViewModel: ObservableObject {
  // Step 1: add conformance to FlexSealTrackable
  class TrackMeLikeOneOfYourFrenchGirls: Identifiable, FlexSealTrackable {
    let id = UUID().uuidString
    var colorIndex = Int.random(in: 0..<6)

    init() {
      // Step 2: call the provided track(...) method.
      track(initialConfig: FlexSealTrackedClass(name: "\(DummyViewModel.self)", initialMaxAllowed: 8))
    }
  }

  @Published var growerNotAShower = [TrackMeLikeOneOfYourFrenchGirls]()
  @Published var maxBeforeLeak = 8.0

  private var isFlexSealActive = false

  func grow() {
    growerNotAShower.append(TrackMeLikeOneOfYourFrenchGirls())
  }

  func shrink() {
    guard !growerNotAShower.isEmpty else { return }
    growerNotAShower.removeLast()
  }

  func changeMaxCount() {
    FlexSeal.changeMaxCount(Int(maxBeforeLeak), for: "\(DummyViewModel.self)")
  }

  func toggleFlexSeal() {
    // holy toxic architecture referencing UI code in the view model batman
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
      isFlexSealActive.toggle()
      isFlexSealActive ? FlexSeal.start(in: windowScene) : FlexSeal.hide()
    } else {
      fatalError("what in the name of our lord and saviour")
    }
  }
}
