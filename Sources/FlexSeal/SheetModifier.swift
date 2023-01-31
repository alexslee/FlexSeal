//
//  SheetModifier.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import SwiftUI
import Combine

extension View {
  /**
   Allows you to present a sheet in the current view context. You provide the contents of the sheet
   via the `view` parameter, and it will be shown/hidden based on the binding parameter `isPresented`
   that you pass in.
   */
  public func withSheet<SheetContent: View>(
    isPresented: Binding<Bool>,
    allowDragToDismiss: Bool = true,
    backgroundColor: Color = .clear,
    position: SheetModifier<SheetContent>.Position = .bottom,
    shouldCloseOnTap: Bool = true,
    shouldCloseOnTapOutside: Bool = false,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder view: @escaping () -> SheetContent) -> some View {
      self.modifier(SheetModifier(
        isPresented: isPresented,
        allowDragToDismiss: allowDragToDismiss,
        backgroundColor: backgroundColor,
        position: position,
        shouldCloseOnTap: shouldCloseOnTap,
        shouldCloseOnTapOutside: shouldCloseOnTapOutside,
        onDismiss: onDismiss,
        view: view))
    }
}

/**
 Displays the provided content as a sheet. Sheet animates in/out from the specified position.
 Access via the `withSheet(...)` extension method on `View`.
 */
public struct SheetModifier<SheetContent>: ViewModifier where SheetContent: View {
  /// Represents the location from which the sheet will present (top vs bottom of the view owning the sheet)
  public enum Position {
    case top
    case bottom
  }

  public enum DragState {
    case dragging(translation: CGSize)
    case inactive

    var isDragging: Bool {
      switch self {
      case .inactive:
        return false
      case .dragging:
        return true
      }
    }

    var translation: CGSize {
      switch self {
      case .inactive:
        return .zero
      case .dragging(let translation):
        return translation
      }
    }
  }

  // MARK: - State/binding variables

  /// Toggles the animation of the sheet in/out of view
  @State private var animatedContentIsPresented = false

  /// Drag to dismiss gesture state
  @GestureState private var dragState = DragState.inactive

  /// Whether or not the sheet should be presented. A binding boolean allows for it to easily transition in/out.
  @Binding var isPresented: Bool

  /// Last position for drag gesture
  @State private var lastDragPosition: CGFloat = 0

  /// The rect representing the hosting controller
  @State private var presenterContentRect: CGRect = .zero

  /// The rect representing the current sheet's contents
  @State private var sheetContentRect: CGRect = .zero

  /// lazy loading of content (no need to run bulk of the view building until sheet actually needs presentation)
  @State private var showContent = false

  // MARK: - Private properties

  /// Whether the sheet should allow dismissal by dragging
  private var allowDragToDismiss: Bool

  /// Background color for the remaining part of the screen outside of the sheet
  private let backgroundColor: SwiftUI.Color

  /// is called on any close action
  private var onDismiss: (() -> Void)?

  /// location from which the sheet will present (top vs. bottom)
  private var position: Position

  /// Whether the sheet should close on tap
  private var shouldCloseOnTap: Bool

  /// Whether the sheet should close on a tap outside of the sheet itself
  private var shouldCloseOnTapOutside: Bool

  /// view builder for what will be shown inside the sheet
  private var view: () -> SheetContent

  // MARK: - Computed properties

  /// The current background opacity
  private var currentBackgroundOpacity: Double {
    return animatedContentIsPresented ? 1.0 : 0.0
  }

  /// The current offset
  private var currentOffset: CGFloat {
    return animatedContentIsPresented ? displayedOffset : hiddenOffset
  }

  /// offset when the sheet is displayed
  private var displayedOffset: CGFloat {
    if position == .bottom {
      let screenHeight = UIScreen.main.bounds.size.height
      return screenHeight - presenterContentRect.midY - sheetContentRect.height / 2
    } else {
      return -presenterContentRect.midY + sheetContentRect.height / 2
    }
  }

  /// offset when the popup is hidden
  private var hiddenOffset: CGFloat {
    switch position {
    case .top:
      if presenterContentRect.isEmpty {
        return -1000
      }

      return -presenterContentRect.midY - sheetContentRect.height / 2 - 5
    case .bottom:
      if presenterContentRect.isEmpty {
        return 1000
      }
      let screenHeight = UIScreen.main.bounds.size.height
      return screenHeight - presenterContentRect.midY + sheetContentRect.height / 2 + 5
    }
  }

  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  init(isPresented: Binding<Bool>,
       allowDragToDismiss: Bool,
       backgroundColor: SwiftUI.Color,
       position: Position,
       shouldCloseOnTap: Bool,
       shouldCloseOnTapOutside: Bool,
       onDismiss: (() -> Void)?,
       view: @escaping () -> SheetContent) {
    self._isPresented = isPresented
    self.position = position
    self.allowDragToDismiss = allowDragToDismiss
    self.shouldCloseOnTap = shouldCloseOnTap
    self.shouldCloseOnTapOutside = shouldCloseOnTapOutside
    self.backgroundColor = backgroundColor
    self.onDismiss = onDismiss
    self.view = view
  }

  public func body(content: Content) -> some View {
    main(content: content)
      .tag(666)
      .onChange(of: isPresented) { newIsPresented in
        animateAppearance(isPresented: newIsPresented)
      }
  }

  @ViewBuilder
  private func main(content: Content) -> some View {
    if !showContent {
      content
    } else {
      // ZStack represents the: hosting view, and then the background color, overlaid by the sheet on top.
      ZStack {
        content
          .frameWrapper($presenterContentRect)

        backgroundColor
          .apply({ view in
            view.contentShape(Rectangle())
          }, if: shouldCloseOnTapOutside)
          .addTapGesture(if: shouldCloseOnTapOutside) {
            dismiss()
          }
          .opacity(currentBackgroundOpacity)
          .animation(.easeInOut(duration: 0.3))
      }
      .overlay(sheet())
    }
  }

  /// This is the builder for the sheet content
  private func sheet() -> some View {
    // the `view()` is the builder that was provided on init
    let sheet = ZStack {
      self.view()
        .addTapGesture(if: shouldCloseOnTap) {
          dismiss()
        }
        .frameWrapper($sheetContentRect)
        .frame(width: horizontalSizeClass == .regular ? UIScreen.main.bounds.width * 0.5 : UIScreen.main.bounds.width)
        .offset(x: 0, y: currentOffset)
        .animation(.easeInOut(duration: 0.3))
    }

    let drag = DragGesture()
      .updating($dragState) { drag, state, _ in
        state = .dragging(translation: drag.translation)
      }
      .onEnded(onDragEnded)

    return sheet
      .safeAreaInset(edge: position == .top ? .top : .bottom, content: {
        backgroundColor
          .frame(height: .large)
      })
//      .edgesIgnoringSafeArea(.all)
      .apply({
        $0.offset(y: dragOffset())
          .simultaneousGesture(drag)
      }, if: allowDragToDismiss)
  }
}

// MARK: - Helpers

extension SheetModifier {
  private func animateAppearance(isPresented: Bool) {
    if isPresented {
      showContent = true
      DispatchQueue.main.async {
        animatedContentIsPresented = true
      }
    } else {
      animatedContentIsPresented = false
    }
  }

  private func dismiss() {
    isPresented = false
    onDismiss?()
  }

  private func dragOffset() -> CGFloat {
    if (position == .bottom && dragState.translation.height > 0) ||
        (position == .top && dragState.translation.height < 0) {
      return dragState.translation.height
    }
    return lastDragPosition
  }

  private func onDragEnded(drag: DragGesture.Value) {
    let reference = sheetContentRect.height / 3
    if (position == .bottom && drag.translation.height > reference) ||
        (position == .top && drag.translation.height < -reference) {
      lastDragPosition = drag.translation.height
      withAnimation {
        lastDragPosition = 0
      }
      dismiss()
    }
  }
}
