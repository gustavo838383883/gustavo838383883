

<!--
**gustavo838383883/gustavo838383883** is a ✨ _special_ ✨ repository because its `README.md` (this file) appears on your GitHub profile.

Here are some ideas to get you started:

- 🔭 I’m currently working on ...
- 🌱 I’m currently learning ...
- 👯 I’m looking to collaborate on ...
- 🤔 I’m looking for help with ...
- 💬 Ask me about ...
- 📫 How to reach me: ...
- 😄 Pronouns: ...
- ⚡ Fun fact: ...
-->

Click the repository with my username and then click script.lua for GustavOS Classic (WOS Microcontroler OS) and copy the raw link and paste in a Microcontroller, you also cant have 2 or more ports with the same id or a id higher than 128, if you want the shutdown button to actually shutdown you need a deactivate polysilicon connected to a port and the microcontroller without a ethernet cable.

For GustavOSDesktop7(GustavOS 2) open the file named gustavosdesktop7.lua.


GD7Library:

GD7Library: () -> {
	Screen: TouchScreen,
	Keyboard: Keyboard,
	Microphone: Microphone,
	Speaker: Speaker,
	Disk: Disk,
 	Disks: {Disk},
	programholder1: Frame,
	programholder2: Frame,
	Taskbar: {ScrollingFrame, ImageLabel, ImageButton},
	screenresolution: Frame,
 	mainframe : Frame,
	CreateWindow: (udim2: UDim2, title: string?, maximizeDisabled: boolean, resizingDisabled: boolean, movingDisabled: boolean, minimizedtext: string or () -> string, minimizingDisabled: boolean, unminimizeButtonImageChangesOnMouseButton1Down: boolean, resizeButtonImageChangesOnClick: boolean) -> (window, holderFrame, closeButton, maximizeButton, titleTextLabel, resizeButton, minimizeButton, functionsTable),
	FileExplorer: (directory: string, functionForSelectingFile: function(name: string, dir: string), selectFile: boolean, disk: Disk) -> never,
	createnicebutton: (size: UDim2, position: UDim2, text: string, parent: ScreenObject) -> (ImageButton, TextLabel),
	createnicebutton2: (size: UDim2, position: UDim2, text: string, parent: ScreenObject) -> (ImageButton, TextLabel),
	filesystem: {Read: (filename: string,  directory: string, canReturnNil: boolean, disk: Disk) -> any, Write: (filename: string, data: any, directory: string, disk: Disk) -> successString},
	filereader: (txt: any, nameondisk: string, directory: string, disk: Disk) -> never,
	Chatted: (func: (playerString, string)) -> {Unbind: Method, Function: (playerString, string)},
 	openstartmenu: (parent: ScreenObject, func: function(buttonclicked: string)) -> ImageButton,
  	wallpaper: ImageLabel,
   	backgroundcolor: Frame,
    	getWindows: () -> {{Holderframe, Window, CloseButton, MaximizeButton, TextLabel, MinimizeButton, FunctionsTable, Focused, Name}}
}
