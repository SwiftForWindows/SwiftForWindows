What is this?
-------------
- Swift compiler for Windows using MinGW-w64 toolchains.
- Minimal subset of the mingw64 package is included.
- Swift language 3.1 compatible

Install
-------
- Download and extract the binary [swift-mingw-20170606-bin.7z](https://github.com/tinysun212/swift-windows/releases/download/swift-mingw-20170606/swift-mingw-20170606-bin.7z).
- Add the following directories to the environment variable PATH
  1) <extracted folder>\swift\bin
  2) <extracted folder>\swift\mingw64\bin

How to run your Swift code
--------------------------
- You can run in immediate mode.
   ex) `swift Hello.swift`

- You can compile and run.
   ex) 
  ```
  Compile
    swiftc Hello.swift

  Run
    Hello.exe
  ```

Notice
------
- `Foundation module` is not included. It will be uploaded separately if prepared. (Check update in https://swiftforwindows.github.io/ )
- Compiler Source: https://github.com/tinysun212/swift-windows/releases/tag/swift-mingw-20170606
   (based on: https://github.com/apple/swift/releases/tag/swift-DEVELOPMENT-SNAPSHOT-2017-04-09-a)
