// Copyright (c) 2017 Han Sangjin
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information

// This is a sample program using wxSwift and provides a simple user interface.
// Compile: 
//   windres --preprocessor=mcpp -i Application.rc -o Application.obj
//   swiftc.exe SwiftForWindows.swift -o SwiftForWindows.exe -Xlinker
//              --subsystem -Xlinker windows -Xlinker Application.obj
//   strip SwiftForWindows.exe

import MinGWCrt
import wx

//////////////////////////////
// Compile and Link Options
//////////////////////////////

var link_with_subsystem_windows = false
var run_in_new_window = true


///////////////////////
// Utility Functions
///////////////////////

// If we can use Foundation module, this function will be changed or removed.
func GetSlashPositionFromLast(_ arg : String) -> Int {
  var slash_len = 0;

  if let offset = strrchr(arg, 0x5C) {  // "\\"
    slash_len = Int(strlen(offset))
  }

  if let offset = strrchr(arg, 0x2F) {  // "/"
    let length = Int(strlen(offset))
    if (length < slash_len) {
      slash_len = length
    }
  }

  if (slash_len == 0) {
    return 0
  }
  return arg.characters.count - slash_len
}

func getcwd() -> String {

    let cwd = MinGWCrt.getcwd(nil, _MAX_PATH)
    if cwd == nil {
      return ""
    }
    defer { free(cwd) }
    if let path = String(validatingUTF8: cwd!) {
      return path
    }
    
    return ""
}

///////////////////////
// Common Variables
///////////////////////

// Find out the located directory of this program
let arg = CommandLine.arguments[0]
let slash_pos = GetSlashPositionFromLast(arg)
var default_prefix = String(arg.characters.prefix(slash_pos))

// make default_prefix be the absolute path
if (slash_pos == 0) {
  default_prefix = getcwd()
} else {
  let index_1 = default_prefix.index(default_prefix.startIndex, offsetBy: 1)
  if (String(default_prefix[index_1]) != ":" ) {
    default_prefix = getcwd() + "\\" + default_prefix
  }
}

var swift_source : String = ""
var swift_out_exe : String = ""
var init_swift_compiler_exe : String = default_prefix + "\\Swift\\bin\\swiftc.exe"
var swift_src_dir : String = default_prefix + "\\My Programs"
var swift_compiler_exe : String = init_swift_compiler_exe
var swift_logo_ico : String = "swift_logo"
  
if !wx.fileExists(swift_compiler_exe) {
  swift_compiler_exe = "Compiler is not found. Double click here."
}

//////////////////////////////
// Define Text Style Button
//////////////////////////////

class TextButton : wx.Button {
  init(_ parent: Window?, id: Int32, label: String, pos: Point, size: Size) {
    super.init(parent, id:id, label:label, pos:pos, size:size, style:wx.BORDER_NONE, 
      validator:wx.DefaultValidator, name:"noname")

      setFont(wx.Font(8, wx.DECORATIVE, wx.NORMAL, wx.NORMAL))
      setBackgroundColour(wx.Colour(0xFFFFFF))
      setForegroundColour(wx.Colour(0xFFFF9933))
      
      bind(wx.EVT_ENTER_WINDOW, { _ in
        self.setBackgroundColour(wx.NullColour)
        self.setWindowStyle(wx.BORDER_DEFAULT)
      })
      
      bind(wx.EVT_LEAVE_WINDOW, { _ in
        self.setBackgroundColour(wx.Colour(0xFFFFFF))
        self.setWindowStyle(wx.BORDER_NONE)
      })
  }
}

///////////////////////
// Initialization
///////////////////////

var app = wx.App()

var frame = wx.Frame(nil, wx.ID_ANY, "Swift for Windows 1.6", size: wx.Size(1000, 600), style: wx.DEFAULT_FRAME_STYLE & ~wx.RESIZE_BORDER )

let icon = wx.Icon(swift_logo_ico, BITMAP_TYPE_ICO_RESOURCE, wx.Size(-1, -1))
frame.setIcon(icon)

var panel = wx.Panel(frame)
panel.setBackgroundColour(wx.Colour(0xFFFFFF))

var font_log = wx.Font(9, wx.FONTFAMILY_MODERN, wx.NORMAL, wx.NORMAL)
var font_12 = wx.Font(10, wx.DECORATIVE, wx.NORMAL, wx.NORMAL)
var font_19B = wx.Font(15, wx.DECORATIVE, wx.NORMAL, wx.BOLD)
var font_19 = wx.Font(15, wx.DECORATIVE, wx.NORMAL, wx.NORMAL)
var font_21 = wx.Font(17, wx.DECORATIVE, wx.NORMAL, wx.NORMAL)
var font_27 = wx.Font(21, wx.DECORATIVE, wx.NORMAL, wx.NORMAL)


///////////////////////
// Compiler Box
///////////////////////

var compiler_box = wx.StaticBox(panel, wx.ID_ANY, "Compiler", pos: wx.Point(10, 5), size: wx.Size(965, 138))
compiler_box.setFont(font_19B)

var selected_file = wx.TextCtrl(compiler_box, wx.ID_ANY, "Select swift file to compile or run", pos:Point(20,37), size:Size(700,35), style:wx.TE_READONLY)
selected_file.setFont(font_21)
selected_file.setBackgroundColour(wx.Colour(0xFFFFFF))

var select_file_btn = wx.Button(compiler_box, id: wx.ID_ANY, label: "Select File", pos: wx.Point(725,37), 
       size: wx.Size(220,35), style:0, validator:wx.DefaultValidator, name:"buttonSelectFile")
select_file_btn.setFont(font_19B)       

var compile_button = wx.Button(compiler_box, id: wx.ID_ANY, label: "Compile", pos: Point(20,85),
       size: wx.Size(460,40), style:0, validator:wx.DefaultValidator,
       name:"buttonCompile")
compile_button.setFont(font_27)       

var run_button = wx.Button(compiler_box, id:wx.ID_ANY, label:"Run", pos:Point(485,85),
       size:wx.Size(460,40), style:0, validator:wx.DefaultValidator,
       name:"buttonRun")
run_button.setFont(font_27)       


///////////////////////
// Compiler Setting Box
///////////////////////

var settings_box = wx.StaticBox(panel, wx.ID_ANY, "Compiler Settings", pos:Point(10, 150), size:Size(965, 107))
settings_box.setFont(font_19B)

var label1_static = wx.StaticText(settings_box, wx.ID_ANY, "* double click on text field to change settings values", pos:Point(15,40), size:Size(600,35))
label1_static.setFont(font_12)

var reset_button = TextButton(settings_box, id:wx.ID_ANY, label:"Reset settings", pos:Point(850,35),
       size:wx.Size(100,22))

var label2_static = wx.StaticText(settings_box, wx.ID_ANY, "Swift Compiler", pos:Point(15,65), size:Size(200,35))
label2_static.setFont(font_19B)

var compiler_textctrl = wx.TextCtrl(settings_box, wx.ID_ANY, swift_compiler_exe, pos:Point(185,65), size:Size(762,30), style:wx.TE_READONLY)
compiler_textctrl.setFont(font_19)
compiler_textctrl.setBackgroundColour(wx.Colour(0xFFFFFF))


///////////////////////
// Logs Box
///////////////////////

var logs_box = wx.StaticBox(panel, wx.ID_ANY, "Logs", pos:Point(10, 267), size:Size(965, 257))
logs_box.setFont(font_19B)

var log_textctrl = wx.TextCtrl(logs_box, wx.ID_ANY, "",
        pos:Point(5,22), size:Size(955,230), style:wx.BORDER_NONE|wx.TE_READONLY|wx.TE_MULTILINE)
log_textctrl.setFont(font_log)
log_textctrl.setBackgroundColour(wx.Colour(0xFFFFFF))


///////////////////////
// Web Links
///////////////////////

var news_button = TextButton(panel, id:wx.ID_ANY, label:"Project Latest News", pos:Point(10, 535),
       size:wx.Size(120,22))

var help_button = TextButton(panel, id:wx.ID_ANY, label:"Help", pos:Point(475,535),
       size:wx.Size(40,22))

var project_button = TextButton(panel, id:wx.ID_ANY, label:"Project Website", pos:Point(875,535),
       size:wx.Size(100,22))


///////////////////////
// Callbacks
///////////////////////

func onSelectFile(_ event: Event) {
  let openFileDialog = wx.FileDialog(panel, "Select a source code file...", swift_src_dir, "",
                                       "Swift files (*.swift)|*.swift", wx.FD_OPEN | wx.FD_FILE_MUST_EXIST)
  if (openFileDialog.showModal() == wx.ID_CANCEL) {
    return
  }
  swift_source = openFileDialog.getPath()
  selected_file.clear()
  selected_file.appendText(swift_source)
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
  
func onReset(_ event: Event) {
  swift_compiler_exe = init_swift_compiler_exe
  compiler_textctrl.clear()
  compiler_textctrl.appendText(swift_compiler_exe)
}
  
func onCompilerSettingDblClick(_ event: Event) {
  if let evtobj = event.EventObject as? TextCtrl {
    let openFileDialog = wx.FileDialog(panel, "Select swiftc.exe file", swift_compiler_exe, "",
                                       "swiftc.exe (swiftc.exe)|swiftc.exe", wx.FD_OPEN | wx.FD_FILE_MUST_EXIST)
    if (openFileDialog.showModal() == wx.ID_CANCEL) {
      return
    }
    swift_compiler_exe = openFileDialog.getPath()
    evtobj.clear()
    evtobj.appendText(swift_compiler_exe)
  }
}

func onCompile(_ event: Event) {
  if String(swift_source.characters.suffix(6)) != ".swift" {
    _ = wx.MessageDialog(frame, "Select a *.swift file", "Compile", style:wx.OK).showModal()
    return
  }
  let len = swift_source.characters.count
  swift_out_exe = String(swift_source.characters.prefix(len - 6)) + ".exe"

  if !wx.fileExists(swift_compiler_exe) {
    _ = wx.MessageDialog(frame, "Compiler is not found.\nSet Swift Compiler", "Compile", style:wx.OK).showModal()
    return
  }
  
  log_textctrl.clear()
  var message : String = ""
  var compiler_command = "\"" + swift_compiler_exe + "\" \"" + swift_source + "\" -o \"" + swift_out_exe + "\""
  if (link_with_subsystem_windows) {
    compiler_command = compiler_command + " -Xlinker --subsystem -Xlinker windows"
  }
  
  let exec_output = wx.executeOutErr(compiler_command)
  message = compiler_command + "\n"
  if exec_output.characters.count == 0 {
    message += "\n" + "Successfully compiled" + "\n"
  } else { 
    message += "\n" + exec_output + "\n"
    message += "\n" + "Compilation Failed" + "\n"
  }
  log_textctrl.appendText(message)
}

func onRun(_ event: Event) {
  if String(swift_source.characters.suffix(6)) != ".swift" {
    _ = wx.MessageDialog(frame, "Select a *.swift file", "Compile", style:wx.OK).showModal()
    return
  }
  if !wx.fileExists(swift_out_exe) {
    _ = wx.MessageDialog(frame, "Push Compile button first", "Run", style:wx.OK).showModal()
    return
  }
  log_textctrl.clear()
  if run_in_new_window {
    let run_command = "cmd /C start /wait cmd /K" + " \"cd C:\\&\"" + swift_out_exe + "\"\""
    _ = wx.executeOutErr(run_command)
  } else {
    let run_command = "cmd /C \"" + swift_out_exe + "\""
    let exec_output = wx.executeOutErr(run_command)
    let message = exec_output
    log_textctrl.appendText(message)
  }
}

///////////////////////
// Bindings
///////////////////////

select_file_btn.bind(wx.EVT_BUTTON, onSelectFile)
compile_button.bind(wx.EVT_BUTTON, onCompile)
run_button.bind(wx.EVT_BUTTON, onRun)
reset_button.bind(wx.EVT_BUTTON, onReset)
compiler_textctrl.bind(wx.EVT_LEFT_DCLICK, onCompilerSettingDblClick)
news_button.bind(wx.EVT_BUTTON, onProjectLatestNews)
help_button.bind(wx.EVT_BUTTON, onHelp)
project_button.bind(wx.EVT_BUTTON, onProjectWebsite)

       
///////////////////////
// Main Loop
///////////////////////
frame.show()       

app.mainLoop()
