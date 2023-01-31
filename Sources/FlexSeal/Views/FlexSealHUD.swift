//
//  FlexSealHUD.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import SwiftUI

/**
 The 'heads-up display' of the leak-checking tool. Intended as a less intrusive yet still easily noticeable
 means of indicating the presence of a potential leak.
 */
struct FlexSealHUD: View {
  private static let iconSideLength: CGFloat = 64

  @Binding var showing: Bool
  @ObservedObject var viewModel: FlexSealViewModel

  var body: some View {
    Image(systemName: viewModel.leakStatus == .leaky ? "exclamationmark.triangle" : "checkmark.circle.fill")
      .resizable()
      .scaledToFit()
      .frame(width: Self.iconSideLength, height: Self.iconSideLength)
      .foregroundColor(viewModel.leakStatus == .leaky ? .warning : .success)
      .onTapGesture(count: 2, perform: { viewModel.isFlexSealVisible = false })
      .onTapGesture(count: 1, perform: { self.showing.toggle() })
  }
}

// MARK: - Previews

struct FlexSealHUD_Previews: PreviewProvider {
  private static let viewModel = FlexSealViewModel()

  static var previews: some View {
    let viewModel = viewModel
    FlexSealHUD(showing: .constant(true), viewModel: viewModel)
      .background(Color.notQuiteWhiteAndBlack)
      .padding()
      .previewLayout(.sizeThatFits)
  }
}
