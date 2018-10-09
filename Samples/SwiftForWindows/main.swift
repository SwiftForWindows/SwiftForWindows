// Copyright (c) 2017-2018 Han Sang-jin
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information

// This is a sample program using wxSwift and provides a simple user interface.
// Compile: 
//   windres --preprocessor=mcpp -i Application.rc -o Application.obj
//   swiftc.exe SwiftForWindows.swift -o SwiftForWindows.exe -Xlinker
//              --subsystem -Xlinker windows -Xlinker Application.obj
//   strip SwiftForWindows.exe

import Foundation
import wx

//////////////////////////////
// Compile and Link Options
//////////////////////////////

var run_in_new_window = true

///////////////////////
// Common Variables
///////////////////////

// Find out the located directory of this program
let program_path = Bundle.main.executablePath!
let installed_dir = URL(fileURLWithPath: program_path, relativeTo:nil)
						.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
						.path

// make installed_dir be an absolute path
let current_dir = FileManager.default.currentDirectoryPath

var swift_source : String = ""
var swift_out_exe : String = ""
var swift_compiler_exe : String = installed_dir + "\\bin\\swiftc.exe"
var swift_src_dir : String = installed_dir + "\\Samples"
var swift_logo_ico : String = "swift_logo"
var run_path : String = installed_dir + "\\bin\\run.bat"
var swift_cmd : String = installed_dir + "\\swift-cmd.bat"
var runtime_env_dir : String = installed_dir + "\\RuntimeEnv"
var sfwbuild_path : String = installed_dir + "\\bin\\sfwbuild.exe"

var swift_version_string = ""
var compile_target = ""
 
var config_subsystem = "console"
var binary_strip = "No"

var app = wx.App()

let fileman = FileManager()
if fileman.fileExists(atPath: swift_compiler_exe) {
	let exec_output = wx.executeOutErr("\(swift_compiler_exe) --version")
	let stringToSplit = exec_output.components(separatedBy: "\n")
	swift_version_string = stringToSplit[0]
	if stringToSplit[1].hasPrefix("Target: ") {
		compile_target = stringToSplit[1]
		let index = compile_target.index(compile_target.startIndex, offsetBy: 8)
		compile_target = String(compile_target[index...])
	} else {
		compile_target = stringToSplit[1]
	}
} else {
	swift_compiler_exe = "Compiler is not found !"
}

var controller = SfwController()
controller.showFrame()
app.mainLoop()
