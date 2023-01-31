//
//  FlexSealContentView.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import SwiftUI

/**
 Simple window intended for overlaying on top of the main window. Passes touches through to the main app
 unless a view exists with a tag value matching that of the provided `nonPassThroughTag`.
 Currently only intended for use in overlaying debug information.
 */
class PassThroughWindow: UIWindow {
  static let flexSealParentTag = 666666
  var nonPassThroughTag: Int?

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hitView = super.hitTest(point, with: event)

    if let nonPassThroughTag = nonPassThroughTag {
      if nonPassThroughTag == hitView?.tag {
        return hitView
      } else if hitView?.viewController as? UIHostingController<FlexSealContentView> != nil,
          !(hitView?.tag == Self.flexSealParentTag) {
        return hitView
      }
    }

    return nil
  }
}

/**
 The 'root' view of the leak checking tool. Contains the HUD and, when the HUD has been tapped, is modified
 to display the popup.
 */
struct FlexSealContentView: View {
  @State private var currLoc = CGPoint(x: .extraLarge, y: .extraLarge) // initial centroid of the HUD
  @State private var isSheetPresented = false

  @ObservedObject var viewModel: FlexSealViewModel

  var body: some View {
    FlexSealHUD(showing: $isSheetPresented, viewModel: viewModel)
      .tag(666)
      .position(currLoc)
      .gesture(DragGesture().onChanged { value in
        withAnimation { self.currLoc = value.location }
      })
    .withSheet(
      isPresented: $isSheetPresented,
      allowDragToDismiss: true,
      position: .top,
      shouldCloseOnTap: true,
      shouldCloseOnTapOutside: true,
      view: {
        FlexSealListView(viewModel: viewModel)
      })
  }
}

// MARK: - Previews

struct FlexSealContentView_Previews: PreviewProvider {
  private static let viewModel = FlexSealViewModel()

  static var previews: some View {
    FlexSealContentView(viewModel: viewModel)
      .padding()
      .previewLayout(.sizeThatFits)
  }
}
