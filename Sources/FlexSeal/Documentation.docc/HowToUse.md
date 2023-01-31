# How to use

## Setting up your classes for the tooling

### 1. Conform to FlexSealTrackable
To be tracked by our tool, a class simply has to conform to ``FlexSealTrackable`` (an empty conformance really, just 
to provide a default implementation + type abstraction).

### 2. Call track(...) in the class' init
Then, in its init, just call the ``FlexSealTrackable/track(initialConfig:)`` method provided by the protocol. Give the 
config a unique name for the class! Can be whatever you like, so long as it's unique. This is the name that will display 
in the tooling once it's up and running. For example:
  ```swift
  // marking as DEBUG only to show you can prevent at least the invocations from appearing in your release binaries
  #if DEBUG
  // here, flexSealName is just defined elsewhere
  track(initialConfig: FlexSealTrackedClass(name: Self.flexSealName, initialMaxAllowed: 3))
  #endif
  ```

### 3. (optional) Changing the max count
Changing the max count allowed is possible at any point during run time, simply by calling the static method 
  ``FlexSeal/changeMaxCount(_:for:)``. This lets you set up the tool in a way that respects 
your app's user flows, to help both yourself as a dev and whoever is testing your work (which could also be you, 
ya indie dev).

### 4. Add a way to turn the tool on/off 
Add a way for your app to show (or, ideally, toggle) this tool. See the sample app for a messy example involving the
device shake gesture. Essentially, you'll at minimum want to call ``FlexSeal/start(in:)``, and for toggle 
functionality, call ``FlexSeal/hide()`` as well. ``FlexSeal/isFlexSealVisible`` lets you keep any custom interface you
may have added up-to-date with dismissals that were done via the means provided by FlexSeal itself (double tapping on the
HUD). 

Support for a `clear()` method that properly goes and deallocates
all the tool's objects without causing any leaks of its own is in-progress. As a debug-only tool, this toggle functionality
should hopefully suffice in the meantime.

## How are the addresses helpful?

The addresses can be super-handy in tracing references when you factor in the Memory Graph tool that Xcode provides. You can
find the full graph of references to the specific instance of the class you're tracking. I'll try and write up an article
on my site for an example use case, and will link to it here once it's up, but we did manage to use this in a previous job
to pinpoint leaks reported in production.

## One last thing

While it is handy and (hopefully) fairly lightweight to track classes in this manner, it's probably not ideal to go
overboard and add tracking to a ton of classes at the same time. In future iterations, we (the royal we) can probably enrich this
tooling by adding in-app options to track certain classes, but for now just don't go on a tracking spree. It should be safe,
but may affect your debug build's performance (and the performance for others, if you merge that tracking into development).
