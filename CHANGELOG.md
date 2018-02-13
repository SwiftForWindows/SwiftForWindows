Swift for Windows 1.9 (2018-02-14)
==================================
New Features, Improvements
--------------------------
- includes XCTest module

Fixed Bugs
----------
- Foundation module:
  - Issue with Date (thanks damuellen, https://github.com/SwiftForWindows/SwiftForWindows/issues/16)
  - Issue with Date/DateComponents/Calendar (thanks kanchudeep, https://github.com/SwiftForWindows/SwiftForWindows/issues/34)
  - Init Double from String did not work (thanks damuellen, https://github.com/SwiftForWindows/SwiftForWindows/issues/38)
  - NSString couldn't read text file (thanks MHX792, https://github.com/SwiftForWindows/SwiftForWindows/issues/39)
  - Support Unicode paths and others (thanks GunGraveKoga, https://github.com/tinysun212/swift-corelibs-foundation/pulls?q=is%3Apr+author%3AGunGraveKoga)
- Weak references didn't work (thanks GunGraveKoga, https://github.com/SwiftForWindows/SwiftForWindows/issues/42)
  
Compiler Source
---------------
- https://github.com/tinysun212/swift-windows/releases/tag/swift-4.0.3+mingw.20180212
  - Based on: https://github.com/apple/swift/releases/tag/swift-4.0.3-RELEASE


Swift for Windows 1.8 (2018-01-03)
==================================
New Features, Improvements
--------------------------
- includes Swift 4.0.3 compiler

Compiler Source
---------------
- https://github.com/tinysun212/swift-windows/releases/tag/swift-4.0.3+mingw.20180102
  - Based on: https://github.com/apple/swift/releases/tag/swift-4.0.3-RELEASE


Swift for Windows 1.7 (2017-12-01)
==================================
New Features, Improvements
--------------------------
- includes Foundation module

Compiler Source
---------------
- https://github.com/tinysun212/swift-windows/releases/tag/swift-mingw-20171201
  - Based on: https://github.com/apple/swift/releases/tag/swift-DEVELOPMENT-SNAPSHOT-2017-04-09-a


Swift for Windows 1.6 (2017-06-08)
==================================
New Features, Improvements
--------------------------
- Support Swift language 3.1
- Inclues wxSwift module alpha version
- GUI is re-implemented in wxSwift by tinysun212

Compiler Source
---------------
- https://github.com/tinysun212/swift-windows/releases/tag/swift-mingw-20170606
  - Based on: https://github.com/apple/swift/releases/tag/swift-DEVELOPMENT-SNAPSHOT-2017-04-09-a


Swift for Windows 1.5 (2017-04-20)
==================================
New Features, Improvements
--------------------------
- Swift compiler changed to MinGW-w64 port
- MinGWCrt module is included. It is a Glibc-like module for the MinGW C runtime library.
- Does not require any additional SDK.
  - C/C++ runtime libraries are included
  - Minimal subset of the mingw64 package is included.

Compiler Source
---------------
- https://github.com/tinysun212/swift-windows/releases/tag/swift-mingw-20160815
  - Based on: https://github.com/apple/swift/releases/tag/swift-DEVELOPMENT-SNAPSHOT-2016-08-07-a


Swift for Windows 1.0 (2016-05-01)
==================================
New Features, Improvements
--------------------------
- Includes Swift compiler for MSVC
- Includes GUI implemented in C# written by vineetchoudhary
- Includes Swift compiler for MSVC, compiled and packaged by tinysun212
- Required Visual C++ Redistributable or Visual Studio 2015 to compile

Compiler Source
---------------
- https://github.com/tinysun212/swift-windows/releases/tag/swift-msvc-20160418
  - Based on: https://github.com/apple/swift/releases/tag/swift-DEVELOPMENT-SNAPSHOT-2016-04-12-a
