Click the repository with my username and then click script.lua for GustavOS Classic (WOS Microcontroler OS) and copy the raw link and paste in a Microcontroller, you also cant have 2 or more ports with the same id or a id higher than 64, if you want the shutdown button to actually shutdown you need a deactivate polysilicon connected to a port and the microcontroller without a ethernet cable.

For GustavOSDesktop7(GustavOS 2), open the file named gustavosdesktop7.lua.

https://gustavo242.pythonanywhere.com/windowapi.html

GD7Library:

FrameIndex is for finding it in gputer.getWindows()

windowMeta = setmetatable(functionsTable, {
	__index = window,
	__newindex = function(array, i, v)
		if not pcall(function() return holderframe[i] end) then
			print(`{i} is not a valid nember of the Instance: {holderframe}`)
			error(`{i} is not a valid nember of the Instance: {holderframe}`)
		else
			holderframe[i] = v
		end
	end,
	__len = function()
		return 0
	end,
})

GD7Library = () -> {
	Screen: TouchScreen,
	Keyboard: Keyboard,
	Microphone: Microphone?,
	Speaker: Speaker,
	Disk: Disk,
	Disks: {Disk},
	programholder1: Frame,
	programholder2: Frame,
	Taskbar: {ScrollingFrame: ScrollingFrame, ImageLabel: ImageLabel, ImageButton: ImageButton},
	screenresolution: Frame,
	mainframe: Frame,
	textinputted: (func: (text: string, player: string) -> ()) -> {Unbind: (self) -> ()},
	CreateWindow: (udim2: UDim2, title: string?, maximizeDisabled: boolean, resizingDisabled: boolean, movingDisabled: boolean, minimizedtext: () -> string? | string?, minimizingDisabled: boolean, unminimizeButtonImageChangesOnMouseButton1Down: boolean, resizeButtonImageChangesOnClick: boolean) -> (holderFrame, windowMeta, closeButton, maximizeButton?, titleTextLabel?, resizeButton?, minimizeButton?, functionsTable),
	FileExplorer: (directory: string, functionForSelectingFile: (name: string, dir: string) -> never, selectFile: boolean, disk: Disk) -> never,
	createnicebutton: (size: UDim2, position: UDim2, text: string, parent: ScreenObject) -> (ImageButton, TextLabel),
	createnicebutton2: (size: UDim2, position: UDim2, text: string, parent: ScreenObject) -> (ImageButton, TextLabel),
	filesystem: {Read: (filename: string,  directory: string, canReturnNil: boolean, disk: Disk) -> any, Write: (filename: string, data: any, directory: string, disk: Disk) -> successString},
	filereader: (txt: any, nameondisk: string, directory: string, disk: Disk) -> never,
	Chatted: (func: (playerString, string: string) -> never) -> {Unbind: (self) -> (), Function: (playerString, string: string) -> never},
	openstartmenu: (parent: ScreenObject, func: (buttonclicked: string) -> never) -> ImageButton,
	wallpaper: ImageLabel,
	backgroundcolor: Frame,
	getWindows: () -> {{Holderframe: Frame, Window: ScrollingFrame, CloseButton: ImageButton, MaximizeButton: ImageButton, TextLabel: TextLabel, MinimizeButton: ImageButton, FunctionsTable: {(self, ...any) -> any}, Focused: boolean, Name: string}}
}
