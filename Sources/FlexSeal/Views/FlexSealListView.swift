//
//  FlexSealListView.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import SwiftUI

/**
 The full list of objects being tracked. The cells within the list show info useful for developers
 (memory addresses of each instance, and the number of instances that are live, both of which can help
 you cross-reference with the memory graph to start tracing the root causes).
 */
struct FlexSealListView: View {
  @ObservedObject var viewModel: FlexSealViewModel

  var body: some View {
    GeometryReader { geometry in
      VStack {
        Spacer().frame(height: geometry.safeAreaInsets.top)
          .background(Color.defaultColor)

        List {
          ForEach(viewModel.trackedClasses.sorted(by: { $0.key < $1.key }), id: \.key) { _, value in
            FlexSealCell(trackedClass: value)
          }
        }

        Capsule()
          .fill(Color.white)
          .frame(width: 72, height: .extraSmall)
          .padding(.top, 15)
          .padding(.bottom, 10)
      }
      .background(viewModel.leakStatus == .leaky ? Color.warning : Color.success)
      .cornerRadius(.extraExtraLarge, corners: [.bottomLeft, .bottomRight])
      .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
    }
  }
}

// MARK: - Previews

struct FlexSealListView_Previews: PreviewProvider {
  private static var viewModel: FlexSealViewModel = {
    let viewModel = FlexSealViewModel()

    let trackedClass = FlexSealTrackedClass(name: "preview", initialMaxAllowed: 1)
    trackedClass.objectAddresses.insert("0x666666")
    trackedClass.objectAddresses.insert("0xDEADBEEF")
    viewModel.trackedClasses["preview"] = trackedClass

    return viewModel
  }()

  static var previews: some View {
    FlexSealListView(viewModel: viewModel)
      .padding()
      .previewLayout(.sizeThatFits)
  }
}
