//
//  ContentView.swift
//  FlexSealSample
//
//  Created by Alexander Lee on 2023-01-30.
//

import SwiftUI

// the most contrived example you'll ever see

struct ContentView: View {
  @ObservedObject var viewModel: DummyViewModel

  var body: some View {
    List {
      Section {
        Text("Shake to toggle FlexSeal")
          .italic()

        Stepper(value: $viewModel.maxBeforeLeak, in: 0...16) {
          Text("Max allowed: \(Int(viewModel.maxBeforeLeak))")
        }
        .onChange(of: viewModel.maxBeforeLeak) { _ in
          viewModel.changeMaxCount()
        }
      }
      Section {
        ForEach($viewModel.growerNotAShower) { model in
          color(for: model.colorIndex.wrappedValue)
            .frame(height: 48)
        }
      }
    }
    .toolbar {
      ToolbarItemGroup(placement: .navigationBarTrailing) {
        Button(action: { viewModel.grow() }) {
          HStack {
            Image(systemName: "plus.circle")
            Text("Grow")
          }
        }

        Button(action: { viewModel.shrink() }) {
          HStack {
            Image(systemName: "minus.circle")
            Text("Shrink")
          }
        }
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: UIWindow.shakeItUp)) { _ in
      viewModel.toggleFlexSeal()
    }
  }

  @ViewBuilder func color(for index: Int) -> some View {
    [Color.red, .black, .blue, .orange, .green, .purple][index]
  }
}

struct ContentView_Previews: PreviewProvider {
  static func makeViewModel() -> DummyViewModel {
    let newViewModel = DummyViewModel()

    for _ in 0..<9 {
      newViewModel.grow()
    }

    return newViewModel
  }

  static var previews: some View {
    NavigationView {
      ContentView(viewModel: makeViewModel())
    }
  }
}
