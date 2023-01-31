//
//  FlexSealCell.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import SwiftUI

struct FlexSealCell: View {
  @ObservedObject var trackedClass: FlexSealTrackedClass

  var body: some View {
    VStack(alignment: .leading, spacing: .extraExtraSmall) {
      Text(trackedClass.name)
        .font(.bodyStrong)

      Text(trackedClass.fractionString())
        .font(.bodyStrong)
        .foregroundColor(trackedClass.isLeaking() ? .error : .success)

      Text(trackedClass.objectAddresses.joined(separator: ", "))
        .font(.bodyRegular)
    }
  }
}

// MARK: - Previews

struct FlexSealCell_Previews: PreviewProvider {
  static var previews: some View {
    { () -> FlexSealCell in
      let trackedClass = FlexSealTrackedClass(name: "nice", initialMaxAllowed: 1)
      trackedClass.objectAddresses.insert("0x666666")
      trackedClass.objectAddresses.insert("0xDEADBEEF")

      return FlexSealCell(trackedClass: trackedClass)
    }()
    .padding()
    .previewLayout(.sizeThatFits)
  }
}
