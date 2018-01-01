@echo off

call ..\..\setPath.bat

TITLE Building SwiftForWindows.exe

echo Compiling...
windres --preprocessor=mcpp -i Application.rc -o Application.obj
swiftc.exe -swift-version 4 SwiftForWindows.swift -o SwiftForWindows.exe -Xlinker --subsystem -Xlinker windows -Xlinker Application.obj
strip SwiftForWindows.exe