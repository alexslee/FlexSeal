//
//  FlexSealViewModel.swift
//
//
//  Created by Alex Lee on 3/3/22.
//

import Foundation
import Combine
import SwiftUI

/// Whether or not FlexSeal has detected a potential leak in the app's current state
enum FlexSealStatus {
  case leaky, sealed
}

/**
 Keeps track of the lifecycle of all objects that conform to `FlexSealTrackable`, and informs observers
 of any updates.
 */
class FlexSealViewModel: ObservableObject {
  static var shared = FlexSealViewModel()

  @Published var canShowFlexSealView = false {
    didSet {
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        FlexSeal.isVisible = self.canShowFlexSealView
      }
    }
  }

  @Published var leakStatus: FlexSealStatus = .sealed
  @Published var trackedClasses = [String: FlexSealTrackedClass]()

  /**
   Maintain a lock to provide write safety when multiple objects attempt to update their tracking status.
   Using a `NSRecursiveLock` ensures objects can update on the same thread without a deadlock.
   */
  private let lock = NSRecursiveLock()

  /**
   Alter the max count of an entity for which you had already started tracking at least once prior.
   - Parameters:
     - newVal: The new max count
     - name: The name of the corresponding entity.
   */
  func changeMaxCount(_ newVal: Int, for name: String) {
    lock.lock()
    guard let existingClass = trackedClasses[name] else { return }
    existingClass.maxAllowed = newVal
    updateLeakStatus()
    lock.unlock()
  }

  /**
   Begins tracking the lifecycle of the provided object. You shouldn't call this directly; rather, simply
   invoke `FlexSealTrackable`'s `track(initialConfig:)` from your class' initializer.
   */
  func track(_ object: Any, trackedClass: FlexSealTrackedClass) {
    lock.lock()

    let address = obtainAddressString(of: object)
    updateTracking(for: address, trackedClass: trackedClass, shouldIncrement: true)

    deinitTracingConfiguration(for: object) { [weak self] in
      guard let self = self else { return }
      self.lock.lock()
      self.updateTracking(for: address, trackedClass: trackedClass, shouldIncrement: false)
      self.lock.unlock()
      self.objectWillChange.send()
    }

    DispatchQueue.main.async { [weak self] in
      self?.objectWillChange.send()
    }

    lock.unlock()
  }

  /**
   Gets a tracker ready to trace the deallocation of the provided object.
   - Parameters:
     - object: the object on which a dealloc tracker will be placed.
     - completion: a closure that will be executed once the object is deallocated.
   */
  private func deinitTracingConfiguration(for object: Any, completion: @escaping () -> Void) {
    var tracker = FlexSealDeallocTracker(onDealloc: completion)
    objc_setAssociatedObject(object, &tracker, tracker, .OBJC_ASSOCIATION_RETAIN)
  }

  /// Extracts the address of the given object and returns the string.
  private func obtainAddressString(of object: Any) -> String {
    return "\(Unmanaged<AnyObject>.passUnretained(object as AnyObject).toOpaque())"
  }

  /**
   Updates the map of `trackedClasses` to account for a change coming in for an instance of the provided class.
   - Parameters:
     - objectAddress: the location of the instance in question, in memory.
     - trackedClass: metadata pertaining to the class being tracked.
     - shouldIncrement: whether the function should increment or decrement the running tally of instances
     for the given class (i.e. whether the instance is being allocated/deallocated).
   */
  private func updateTracking(for objectAddress: String, trackedClass: FlexSealTrackedClass, shouldIncrement: Bool) {
    // if the object's class has already been tracked before, update the existing values
    if let existingClass = trackedClasses[trackedClass.name] {
      // the most recently instantiated object declared should override any previous maxAllowed, if different
      if trackedClass.maxAllowed != existingClass.maxAllowed {
        existingClass.maxAllowed = trackedClass.maxAllowed
      }

      existingClass.currentCount += (shouldIncrement ? 1 : -1)

      if shouldIncrement {
        existingClass.objectAddresses.insert(objectAddress)
      } else {
        existingClass.objectAddresses.remove(objectAddress)
      }

      updateLeakStatus()
    } else {
      trackedClasses[trackedClass.name] = trackedClass
      // fill in the initial address value and increment once
      trackedClasses[trackedClass.name]?.objectAddresses.insert(objectAddress)
      trackedClasses[trackedClass.name]?.currentCount += 1
    }
  }

  /// What the name says on the tin - goes through the current set of tracked classes and flags if any are leaking.
  private func updateLeakStatus() {
    let isLeakFree = trackedClasses.values.allSatisfy({ $0.isLeaking() == false })
    leakStatus = isLeakFree ? .sealed : .leaky
  }
}

/**
 For `objc_setAssociatedObject` to work, we need to provide a separate object to associate with the
 instance we are trying to track. This simple class fulfills that purpose. When the instance we're tracking
 is getting deallocated, this one will too, at which point the given closure will run.
 */
class FlexSealDeallocTracker {
  let onDealloc: () -> Void

  init(onDealloc: @escaping () -> Void) {
    self.onDealloc = onDealloc
  }

  deinit {
    onDealloc()
  }
}
