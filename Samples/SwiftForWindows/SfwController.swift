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

//////////////////////////////////
// Build Configuration Structure
//////////////////////////////////

struct BuildConf : Codable {
	var sfwbuild_version : String
	var executable_name : String
	var sources : [String]
	var subsystem : String?
	var strip : Bool?
}

//////////////////////////////
// Utility
//////////////////////////////

func quotedForCmd(_ path: String) -> String {
	return path.replacingOccurrences(of:"\"", with:"\"\"\"").replacingOccurrences(of:" ", with:"\" \"")
}

class SfwController {
	var view : SfwView?
	var frame : wx.Frame?

	init() {}


	///////////////////////
	// Callbacks
	///////////////////////

	func onSelectFile(_ event: Event) {
		let openFileDialog = wx.FileDialog((view?.panel)!, "Select a source code file...", swift_src_dir, "",
										"All files (*.swift;*.json)|*.swift;*.json|Swift files (*.swift)|*.swift|Build Configuration (*.json)|*.json",
										wx.FD_OPEN | wx.FD_FILE_MUST_EXIST)
		if (openFileDialog.showModal() == wx.ID_CANCEL) {
			return
		}
		swift_source = openFileDialog.getPath()
		view?.selected_file?.clear()
		view?.selected_file?.appendText(swift_source)
	
		if swift_source.hasSuffix(".swift") {
			let swift_source_name = URL(fileURLWithPath: swift_source).lastPathComponent
			swift_out_exe = runtime_env_dir + "\\" + swift_source_name.replacingOccurrences(of:".swift", with:".exe")

			// Show subsystem
			view?.subsystem_static?.setLabel("console")
			
			// Show strip job
			view?.strip_static?.setLabel("No")
		} else if swift_source.hasSuffix(".json") {
			let configPath = swift_source
		
			// Read config build file
			guard let data = try? Data(contentsOf:URL(fileURLWithPath: configPath), options: .mappedIfSafe) else {
				_ = wx.MessageDialog(frame!, "Error: Failed to read \(configPath)", "Select File", style:wx.OK).showModal()
				return
			}
			
			// Decode json format
			let decoder = JSONDecoder()
			guard let build_conf = try? decoder.decode(BuildConf.self, from: data) else {
				_ = wx.MessageDialog(frame!, "Error: Build configuration could not be parsed", "Select File", style:wx.OK).showModal()
				return
			}
			
			// Check sfwbuild version
			if !build_conf.sfwbuild_version.hasPrefix("0.1") {
				_ = wx.MessageDialog(frame!, "Error: Build configuration for sfwbuild v\(build_conf.sfwbuild_version) is not supported", "Select File", style:wx.OK).showModal()
				return
			}
			
			// Build executable path
			let executable_name = build_conf.executable_name
			let target_dir = installed_dir + "\\" + "RuntimeEnv"
			swift_out_exe = target_dir + "\\" + executable_name + ".exe"
			
			// Show subsystem
			if build_conf.subsystem == "console" {
				view?.subsystem_static?.setLabel(build_conf.subsystem!)
			} else if build_conf.subsystem == "windows" {
				view?.subsystem_static?.setLabel(build_conf.subsystem!)
			} else if build_conf.subsystem == nil {
				view?.subsystem_static?.setLabel("console")
			} else {
				_ = wx.MessageDialog(frame!, "Error: Unknown subsystem \(build_conf.subsystem!)", "Select File", style:wx.OK).showModal()
				return
			}
			
			// Show strip job
			if build_conf.strip != nil && build_conf.strip! {
				view?.strip_static?.setLabel("Yes")
			} else {
				view?.strip_static?.setLabel("No")
			}
		}
	}

	func onProjectLatestNews(_ event: Event) {
	_ = wx.launchDefaultBrowser("https://swiftforwindows.github.io/news")
	}

	func onHelp(_ event: Event) {
	_ = wx.launchDefaultBrowser("https://swiftforwindows.github.io/help")
	}

	func onProjectWebsite(_ event: Event) {
	_ = wx.launchDefaultBrowser("https://swiftforwindows.github.io/")
	}

	func onEnterLinkButton(_ event: Event) {
		if let evtobj = event.EventObject as? Window {
			evtobj.setBackgroundColour(wx.NullColour)
			evtobj.setWindowStyle(wx.BORDER_DEFAULT)
		}
	}

	func onLeaveLinkButton(_ event: Event) {
		if let evtobj = event.EventObject as? Window {
			evtobj.setBackgroundColour(wx.Colour(0xFFFFFF))
			evtobj.setWindowStyle(wx.BORDER_NONE)
		}
	}

	func onCompile(_ event: Event) {
		if !swift_source.hasSuffix(".swift") && !swift_source.hasSuffix(".json") {
			_ = wx.MessageDialog(frame!, "Select a *.swift or *.json file", "Compile", style:wx.OK).showModal()
			return
		}

		if swift_source.hasSuffix(".json") {
			// Building *.json
		
			// Change current directory
			let fileMgr = FileManager.default
			let source_dir = URL(fileURLWithPath: swift_source, relativeTo:nil)
							.deletingLastPathComponent() 
							.path
			let _ = fileMgr.changeCurrentDirectoryPath(source_dir)
			
			view?.log_textctrl?.clear()
			let compiler_command = "\"\(sfwbuild_path)\" -f \"\(swift_source)\""
			var message = compiler_command + "\n\n"
			view?.log_textctrl?.appendText(message)
			
			let exec_output = wx.executeOutErr(compiler_command)

			message = exec_output + "\n\n"
			if exec_output.contains("error:") || exec_output.contains("failed") {
			message += "Compilation Failed" + "\n"
			} else { 
			message += "Successfully compiled" + "\n"
			}

			view?.log_textctrl?.appendText(message)
		
			return
		}
	
		if swift_source.hasSuffix(".swift") {
			// Compiling *.swift

			if !wx.fileExists(swift_compiler_exe) {
			_ = wx.MessageDialog(frame!, "Compiler is not found.", "Compile", style:wx.OK).showModal()
			return
			}
		
			view?.log_textctrl?.clear()
			let compiler_command = "\"\(swift_compiler_exe)\" -swift-version 4 \"\(swift_source)\" -o \"\(swift_out_exe)\""
			var message = compiler_command + "\n\n"
			view?.log_textctrl?.appendText(message)

			let exec_output = wx.executeOutErr(compiler_command)

			message = exec_output + "\n\n"
			if exec_output.contains("error:") || exec_output.contains("failed") {
			message += "Compilation Failed" + "\n"
			} else { 
			message += "Successfully compiled" + "\n"
			}
			view?.log_textctrl?.appendText(message)
		}
	}

	func onRun(_ event: Event) {
		if !swift_source.hasSuffix(".swift") && !swift_source.hasSuffix(".json") {
			_ = wx.MessageDialog(frame!, "Select a *.swift or *.json file", "Compile", style:wx.OK).showModal()
			return
		}
		view?.log_textctrl?.appendText("\n\(swift_out_exe)")
		if !wx.fileExists(swift_out_exe) {
			_ = wx.MessageDialog(frame!, "Compile first", "Run", style:wx.OK).showModal()
			return
		}
		view?.log_textctrl?.clear()
		if run_in_new_window {
			let directory_of_swift_out_exe = String(describing: NSString(string: swift_out_exe).deletingLastPathComponent) + "\\"
	
			let run_command = "cmd /C start /wait cmd /K \"" +
							"cd \(directory_of_swift_out_exe) &" +
							"\"\(run_path)\" \"\(swift_out_exe)\" &" +
							"pause &" +
							"exit" +					   
							"\""
			_ = wx.executeOutErr(run_command)
		} else {
			let run_command = "cmd /C \"\(swift_out_exe)\""
			let exec_output = wx.executeOutErr(run_command)
			let message = exec_output
			view?.log_textctrl?.appendText(message)
		}
	}

	func onCmd(_ event: Event) {
		var cmd_start_dir = installed_dir
		if swift_source.hasSuffix(".swift") || swift_source.hasSuffix(".json") {
			cmd_start_dir = URL(fileURLWithPath: swift_source, relativeTo:nil)
							.deletingLastPathComponent()
							.path
		}
		let run_command = "cmd /K \" cd \(quotedForCmd(cmd_start_dir)) & \(quotedForCmd(swift_cmd))\""
		_ = wx.execute(run_command, EXEC_ASYNC, nil)
	}

	func binding() {
		guard let view = view else { return }

		view.select_file_btn?.bind(wx.EVT_BUTTON, onSelectFile)
		view.compile_button?.bind(wx.EVT_BUTTON, onCompile)
		view.run_button?.bind(wx.EVT_BUTTON, onRun)
		view.cmd_button?.bind(wx.EVT_BUTTON, onCmd)
		view.news_button?.bind(wx.EVT_BUTTON, onProjectLatestNews)
		view.help_button?.bind(wx.EVT_BUTTON, onHelp)
		view.project_button?.bind(wx.EVT_BUTTON, onProjectWebsite)
	}

	func showFrame() {
		view = SfwView()
		guard let view = view else { return }

		frame = view.buildFrame()
		guard let frame = frame else { return }
	
		// Output compiler setting
		view.compiler_static?.setLabel(swift_compiler_exe)
		view.version_static?.setLabel(swift_version_string)
		view.subsystem_static?.setLabel(config_subsystem)
		view.strip_static?.setLabel(binary_strip)
		view.target_static?.setLabel(compile_target)

		binding()
		frame.show()
	}
}
