//
//  View+Extensions.swift
//
//
//  Created by Alex Lee on 3/3/22.
//


import Foundation
import SwiftUI

extension View {
  /// Convenience view builder that conditionally applies a tap gesture to perform the given closure.
  @ViewBuilder
  func addTapGesture(if condition: Bool, onTap: @escaping () -> Void) -> some View {
    if condition {
      self.simultaneousGesture(TapGesture().onEnded {
        onTap()
      })
    } else {
      self
    }
  }

  /// Convenience view builder that applies the provided transform if a given bool evaluates to true.
  @ViewBuilder
  func apply<T: View>(_ block: (Self) -> T, if condition: Bool) -> some View {
    if condition {
      block(self)
    } else {
      self
    }
  }

  /// Rounds the specified corners of a view, using the given radius.
  public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners))
  }

  func frameWrapper(_ frame: Binding<CGRect>) -> some View {
    modifier(FrameWrapper(frame: frame))
  }
}

/// Convenience modifier that lets us fetch the frame of a view at any point
struct FrameWrapper: ViewModifier {
  @Binding var frame: CGRect

  func body(content: Content) -> some View {
    content
      .background(GeometryReader { proxy -> AnyView in
        let rect = proxy.frame(in: .global)
        // This avoids an infinite layout loop
        if rect.integral != self.frame.integral {
          DispatchQueue.main.async {
            self.frame = rect
          }
        }
        return AnyView(EmptyView())
      })
  }
}

/// Defines a path by which a SwiftUI View could be rounded. See the `cornerRadius(...)` extension on `View`.
public struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners

  public func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect,
                            byRoundingCorners: corners,
                            cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}
