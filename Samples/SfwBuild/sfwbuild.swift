// Copyright (c) 2018 Han Sang-jin
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
import Foundation

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


func SfwBuild(configPath: String, installDir: String) throws -> [String]? {
	// Read config build file
	guard let data = try? Data(contentsOf:URL(fileURLWithPath: configPath), options: .mappedIfSafe) else {
		print("Error: Failed to read \(configPath)")
		return nil
	}
	
	// Decode json format
	let decoder = JSONDecoder()
	guard let build_conf = try? decoder.decode(BuildConf.self, from: data) else {
		print("Error: Build configuration could not be parsed")
		return nil
	}
	
	// Check sfwbuild version
	if !build_conf.sfwbuild_version.hasPrefix("0.1") {
		print("Error: Build configuration for sfwbuild v\(build_conf.sfwbuild_version) is not supported")
		return nil
	}
	
	// Build executable path
	let executable_name = build_conf.executable_name
	let target_dir = installDir + "\\" + "RuntimeEnv"
	let executable_path = target_dir + "\\" + executable_name + ".exe"
	
	// classify sources into .swift and .rc
	var swift_src_list : [String] = []
	var rc_src_list : [String] = []
	for source in build_conf.sources {
		if source.hasSuffix(".swift") {
			swift_src_list.append(source)
		} else if source.hasSuffix(".rc") {
			rc_src_list.append(source)
		} else {
			print("Error: Unknown source file type \(source)")
			return nil
		}
	}
	
	// Check subsystem
	var subsystem_is_windows : Bool = true
	if build_conf.subsystem == "console" {
		subsystem_is_windows = false
	} else if build_conf.subsystem == "windows" {
		subsystem_is_windows = true
	} else if build_conf.subsystem == nil {
		subsystem_is_windows = false
	} else {
		print("Error: Unknown subsystem \(build_conf.subsystem!)")
		return nil
	}
	
	// Build subsystem option if it is windows subsystem
	var linker_subsytem_option = ""
	if subsystem_is_windows {
		linker_subsytem_option = "-Xlinker --subsystem -Xlinker windows "
	}
	
	// Build rc compile job and build linker option for compiled rc
	var job_list : [String] = []
	var linker_rc_obj_options = ""
	if rc_src_list.count > 0 {
		for rc_src in rc_src_list {
			let rc_obj = rc_src.replacingOccurrences(of:".rc", with:".obj")
			job_list.append("\(quotedForCmd(installDir))\\mingw64\\bin\\windres --preprocessor=\(quotedForCmd(quotedForCmd(installDir)))\\mingw64\\bin\\mcpp -i \(quotedForCmd(rc_src)) -o \(quotedForCmd(rc_obj))")
			linker_rc_obj_options = linker_rc_obj_options + "-Xlinker \(quotedForCmd(rc_obj)) "
		}
	}
	
	// Build swift compile job
	let swift_src_list_string = swift_src_list.map(quotedForCmd).joined(separator: " ")
	var linker_allow_multiple_option = ""
	if swift_src_list.count > 1 {
		linker_allow_multiple_option = "-Xlinker --allow-multiple-definition "
	}
	let linker_options = linker_subsytem_option + linker_rc_obj_options + linker_allow_multiple_option
	job_list.append("\(quotedForCmd(installDir))\\bin\\swiftc.exe -swift-version 4 \(swift_src_list_string) -o \(quotedForCmd(executable_path)) \(linker_options)")
	
	// Build strip job
	if let _ = build_conf.strip {
		job_list.append("\(quotedForCmd(installDir))\\mingw64\\bin\\strip \(quotedForCmd(executable_path))")
	}
	
	return job_list
}

func Usage() {
	print("SFW Build v0.1")
	print("")
	print("Usage: sfwbuild [option]")
	print("")
	print("Options:")
	print("  <NO OPTION>  Read build.json as a build config file")
	print("  -f <file>    Read <file> as a build config file")
	print("  -h           Print this message and exit.")
}


var build_conf_name : String = ""
if CommandLine.argc == 1 {
	build_conf_name = "build.json"
} else if CommandLine.argc == 3 && CommandLine.arguments[1] == "-f" {
	build_conf_name = CommandLine.arguments[2]
} else if CommandLine.argc == 2 && CommandLine.arguments[1] == "-h" {
    Usage()
	exit(0)
} else {
	print("Error: Unknown options '\(CommandLine.arguments[1...].joined(separator: " "))'. Use option -h for help.")
	exit(0)
}

// Find out the located directory of this program

let program_path = Bundle.main.executablePath!
let installed_dir = URL(fileURLWithPath: program_path, relativeTo:nil)
						.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
						.path
let build_conf_path = URL(fileURLWithPath: build_conf_name, relativeTo:nil)
						.path

if let job_list = try SfwBuild(configPath: build_conf_path, installDir: installed_dir) {
	for job in job_list {
		print(job)
		let ret = system(job)
		if ret != 0 {
			exit(1)
		}
	}
}
