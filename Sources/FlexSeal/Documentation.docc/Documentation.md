# ``FlexSeal``

A lifecycle tracking tool to find potential memory leaks during development and testing. Copyright infringement not intended (but you're a real one if you get the reference).

## Overview

_"Stop leaks fast!"®_ - The biggest of shout-outs to [Flex Seal](https://flexsealproducts.com/) for hopefully not issuing a takedown request for this free publicity to the max two developers who will ever see this.

FlexSeal™ gives us developers a helping hand in tracing the lifecycle of any object we specify. While we
tend to take ARC for granted, memory leaks do happen, and being able to see the number of objects in memory + the 
addresses of each instance, can be a valuable starting point in pinpointing where you need to patch your leak. 
Using this in conjunction with Xcode's memory graph can be a powerful way of root-causing any suspected leaks!

Check out the sample app for a simple, albeit very contrived, example of how this can be integrated and used.

## Topics

### Using FlexSeal™
You can get up and running in just a couple of lines of code! Check out this tutorial to find out how.
- <doc:HowToUse>
