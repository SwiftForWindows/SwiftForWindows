import wx

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

class SfwView {
	var selected_file : wx.TextCtrl?
	var log_textctrl : wx.TextCtrl?
    var compiler_static : wx.StaticText?
    var version_static : wx.StaticText?
	var subsystem_static : wx.StaticText?
	var strip_static : wx.StaticText?
    var target_static : wx.StaticText?
	var panel : wx.Panel?
    var select_file_btn : wx.Button?
    var compile_button : wx.Button?
    var run_button : wx.Button?
    var cmd_button : wx.Button?
    var news_button : TextButton?
    var help_button : TextButton?
    var project_button : TextButton?


	init() {}

    func buildFrame() -> wx.Frame {
        let frame = wx.Frame(nil, wx.ID_ANY, "Swift for Windows 2.0", size: wx.Size(1000, 600), style: wx.DEFAULT_FRAME_STYLE & ~wx.RESIZE_BORDER )

        let icon = wx.Icon(swift_logo_ico, BITMAP_TYPE_ICO_RESOURCE, wx.Size(-1, -1))
        frame.setIcon(icon)

        panel = wx.Panel(frame)
        panel?.setBackgroundColour(wx.Colour(0xFFFFFF))

        let font_log = wx.Font(9, wx.FONTFAMILY_MODERN, wx.NORMAL, wx.NORMAL)
        let font_10 = wx.Font(10, wx.DECORATIVE, wx.NORMAL, wx.NORMAL)
        let font_12 = wx.Font(12, wx.DECORATIVE, wx.NORMAL, wx.NORMAL)
        let font_12B = wx.Font(12, wx.DECORATIVE, wx.NORMAL, wx.BOLD)
        let font_15B = wx.Font(15, wx.DECORATIVE, wx.NORMAL, wx.BOLD)
        let font_17 = wx.Font(17, wx.DECORATIVE, wx.NORMAL, wx.NORMAL)
        let font_21 = wx.Font(21, wx.DECORATIVE, wx.NORMAL, wx.NORMAL)


        ///////////////////////
        // Compiler Box
        ///////////////////////

        let compiler_box = wx.StaticBox(panel!, wx.ID_ANY, "Compiler", pos: wx.Point(10, 5), size: wx.Size(965, 138))
        compiler_box.setFont(font_15B)

        selected_file = wx.TextCtrl(compiler_box, wx.ID_ANY, "Select swift file to compile or run", pos:Point(20,37), size:Size(700,35), style:wx.TE_READONLY)
        selected_file?.setFont(font_17)
        selected_file?.setBackgroundColour(wx.Colour(0xFFFFFF))

        select_file_btn = wx.Button(compiler_box, id: wx.ID_ANY, label: "Select File", pos: wx.Point(725,37), 
                                    size: wx.Size(220,35), style:0, validator:wx.DefaultValidator, name:"buttonSelectFile")
        select_file_btn?.setFont(font_15B)       

        compile_button = wx.Button(compiler_box, id: wx.ID_ANY, label: "Compile", pos: Point(20,85),
                                   size: wx.Size(390,40), style:0, validator:wx.DefaultValidator,
                                   name:"buttonCompile")
        compile_button?.setFont(font_21)       

        run_button = wx.Button(compiler_box, id:wx.ID_ANY, label:"Run", pos:Point(415,85),
                               size:wx.Size(390,40), style:0, validator:wx.DefaultValidator,
                               name:"buttonRun")
        run_button?.setFont(font_21)       

        cmd_button = wx.Button(compiler_box, id:wx.ID_ANY, label:"Swift Tools\nCommand Prompt", pos:Point(820,85),
                               size:wx.Size(125,40), style:0, validator:wx.DefaultValidator,
                               name:"buttonCmd")
        cmd_button?.setFont(font_10)       


        ///////////////////////
        // Compiler Setting Box
        ///////////////////////

        let settings_box = wx.StaticBox(panel!, wx.ID_ANY, "Compiler Settings", pos:Point(10, 150), size:Size(965, 107))
        settings_box.setFont(font_15B)

        let compiler_label_static = wx.StaticText(settings_box, wx.ID_ANY, "Compiler Path", pos:Point(15,40), size:Size(120,25))
        compiler_label_static.setFont(font_12B)

        compiler_static = wx.StaticText(settings_box, wx.ID_ANY, "", pos:Point(140,40), size:Size(300,25))
        compiler_static?.setFont(font_12)
        compiler_static?.setBackgroundColour(wx.Colour(0xFFFFFF))
    
        let version_label_static = wx.StaticText(settings_box, wx.ID_ANY, "Version Info", pos:Point(15,65), size:Size(120,20))
        version_label_static.setFont(font_12B)

        version_static = wx.StaticText(settings_box, wx.ID_ANY, "", pos:Point(140,65), size:Size(300,20))
        version_static?.setFont(font_12)
        version_static?.setBackgroundColour(wx.Colour(0xFFFFFF))

        let subsystem_label_static = wx.StaticText(settings_box, wx.ID_ANY, "Subsystem", pos:Point(500,40), size:Size(120,25))
        subsystem_label_static.setFont(font_12B)

        subsystem_static = wx.StaticText(settings_box, wx.ID_ANY, "", pos:Point(620,40), size:Size(100,25))
        subsystem_static?.setFont(font_12)
        subsystem_static?.setBackgroundColour(wx.Colour(0xFFFFFF))
        let strip_label_static = wx.StaticText(settings_box, wx.ID_ANY, "Strip", pos:Point(840,40), size:Size(60,25))
        strip_label_static.setFont(font_12B)

        strip_static = wx.StaticText(settings_box, wx.ID_ANY, "", pos:Point(900,40), size:Size(60,25))
        strip_static?.setFont(font_12)
        strip_static?.setBackgroundColour(wx.Colour(0xFFFFFF))

        let target_label_static = wx.StaticText(settings_box, wx.ID_ANY, "Target", pos:Point(500,65), size:Size(120,20))
        target_label_static.setFont(font_12B)

        target_static = wx.StaticText(settings_box, wx.ID_ANY, "", pos:Point(620,65), size:Size(300,20))
        target_static?.setFont(font_12)
        target_static?.setBackgroundColour(wx.Colour(0xFFFFFF))

        ///////////////////////
        // Logs Box
        ///////////////////////

        let logs_box = wx.StaticBox(panel!, wx.ID_ANY, "Logs", pos:Point(10, 267), size:Size(965, 257))
        logs_box.setFont(font_15B)

        log_textctrl = wx.TextCtrl(logs_box, wx.ID_ANY, "",
                                    pos:Point(5,22), size:Size(955,230), style:wx.BORDER_NONE|wx.TE_READONLY|wx.TE_MULTILINE)
        log_textctrl?.setFont(font_log)
        log_textctrl?.setBackgroundColour(wx.Colour(0xFFFFFF))


        ///////////////////////
        // Web Links
        ///////////////////////

        news_button = TextButton(panel!, id:wx.ID_ANY, label:"Project Latest News", pos:Point(10, 535),
                                    size:wx.Size(140,22))
        news_button?.setFont(font_10)

        help_button = TextButton(panel!, id:wx.ID_ANY, label:"Help", pos:Point(465,535),
                                    size:wx.Size(40,22))
        help_button?.setFont(font_10)

        project_button = TextButton(panel!, id:wx.ID_ANY, label:"Project Website", pos:Point(855,535),
                                        size:wx.Size(120,22))
        project_button?.setFont(font_10)

        return frame
    }
}
