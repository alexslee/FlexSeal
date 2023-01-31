# FlexSeal

A lifecycle tracking tool to find potential memory leaks during development and testing.

## Overview

FlexSeal gives us developers a helping hand in tracing the lifecycle of any object we specify. While we
tend to take ARC for granted, memory leaks do happen, and being able to see the number of objects in memory + the 
addresses of each instance, can be a valuable starting point in pinpointing where you need to patch your leak. 
Using this in conjunction with Xcode's memory graph can be a powerful way of root-causing any suspected leaks!

Check out the sample app for a simple, albeit very contrived, example of how this can be integrated and used.

## How to use

_will be added when DocC is done_

## TODOs

- [ ] DocC and clean up comments, idjit
- [ ] address the irony of not having a proper clear method that deallocates FlexSeal without leaving memory leaks of its own, because Alex is a piece of shit
- [ ] unit tests :upside_down_face:
