local Screen = GetPartFromPort(1,"TouchScreen")
if not Screen then Screen = GetPartFromPort(2,"TouchScreen") end
if not Screen then Screen = GetPartFromPort(1, "Screen") end
local Microphone = GetPartFromPort(1,"Microphone")
if not Microphone then Microphone = GetPartFromPort(2,"Microphone") end
local Speaker = GetPartFromPort(1,"Speaker")
if not Speaker then Speaker = GetPartFromPort(2,"Speaker") end
local ChatDebounce = false
Beep(1)
local function CreateWindow(x, y, name)
	local holderframe = Screen:CreateElement("TextButton", {TextTransparency = 1, Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0, x, 0, y+25), Draggable = true})
	local textlabel = Screen:CreateElement("TextLabel", {TextScaled = true, TextWrapped = true, Text = name, Position = UDim2.new(0,25,0,0), Size = UDim2.new(1, 0, 0, 25)})
	holderframe:AddChild(textlabel)
	
	local closebutton = Screen:CreateElement("TextButton", {TextScaled = true, TextWrapped = true, Size = UDim2.new(0,25,0,25), Position = UDim2.new(0,0,0,0), BackgroundColor3 = Color3.new(1,0,0), Text = "Close"})
	holderframe:AddChild(closebutton)
	
	closebutton.MouseButton1Up:Connect(function()
		holderframe:Destroy()
		holderframe = nil
	end)
	local window = Screen:CreateElement("Frame", {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 25)})
	holderframe:AddChild(window)
	return window, closebutton, holderframe
end

local function AddWindowElement(window, name, properties)
	local guiobject
	if typeof(properties) == "table" and name then
		guiobject = Screen:CreateElement(name, properties)
		window:AddChild(guiobject)
	end
	return guiobject
end

local function AddElement(window, name, properties)
	local guiobject
	if typeof(properties) == "table" and name then
		guiobject = Screen:CreateElement(name, properties)
		window:AddChild(guiobject)
	end
	return guiobject
end

local window, closebutton = CreateWindow(250, 300, "DestroyBot for GustavOS")
local destroyBotFace = AddWindowElement(window, "Frame", {
	Size = UDim2.fromOffset(250,250);
	Position = UDim2.fromOffset(0,0);
	BackgroundColor3 = Color3.fromRGB(0,0,0);
	BorderSizePixel = 0;
})
local destroyBotReaction = AddWindowElement(window, "TextLabel", {
	Size = UDim2.fromOffset(200,50);
	Position = UDim2.fromOffset(0,250);
	BackgroundColor3 = Color3.fromRGB(0,0,0);
	BorderSizePixel = 0;
	TextColor3 = Color3.fromRGB(255,255,255);
	TextScaled = true;
	Text = "zzz";
})
local talkButton = AddWindowElement(window, "TextButton", {
	Size = UDim2.fromOffset(50,50);
	Position = UDim2.fromOffset(200,250);
	BackgroundColor3 = Color3.fromRGB(255,255,255);
	BorderSizePixel = 0;
	TextColor3 = Color3.fromRGB(0,0,0);
	TextScaled = true;
	Text = "Talk";
})
spawn(function()
	while task.wait(math.random(20,30)) do
		if ChatDebounce == false then
			Talk()
		end
	end
end)

local neutralQuotes = {
	"...I should buy a boat.",
	"ACHOO! Ah, sorry. Coral Fever? No no, just my spring allergies acting up.",
	"...I should buy a boat.",
	"TIP: Press 'Spacebar' to jump! How many times have you jumped in real life recently? Something to think about.",
	"HINT: If you shower, there's a higher chance of you finding happiness. Try it out sometime.",
	"TIP: Do not let the radio decide your taste in music. Be your own person and seek what you personally enjoy.",
	"TIP: If you're ever getting bored of the game, play something else. Games aren't made to play forever.",
	"They should add Freddy Fazbear to this game.",
	"Stan is real.",
	"Honestly, I'm just not a big fan of railguns. Like why do they exist?",
	"I should be the capital alienship if that guy didn't retire me..",
	"3 ionrockets clearly cant go faster than the speed of light, hyperdrive is just a scam afterall.",
	"AD BREAK: Selling 3 sticks for 5 aliencores. Great deal, I know.",
	"Shout out to my dad Cyber_leopard, i think he made me. And my teacher FAAndrr, he taught me how to talk in English.",
	"Puter? You mean that big tablet that can store music? Don't have high hopes on me, I can't store music.",
	"0mori is a great person, I like him.",
	"Deh den da doo dee da do don da.. Oh sorry, I was singing the menu theme.",
	"Space is pretty warm, 50F I'd say so.",
	"Y'know LouisArtOfWar09? I'm real good friends with him. Bet you're jealous.",
	"Tip: I have emotions, like actually! So don't say bad stuff to me.",
	"Tip: Just blade aliens down! Its literally that easy.",
	"Tip: If you see a blue outline on your screen, get out of The Depths. Wait wrong game"
}
local sadQuotes = { 
	"Why do people nuke bases? How do warheads even work?",
	"Yaaawn... Can you like, do something interesting?",
	"Last time i got sabotaged by ivan and ninecraft, not friends with him anymore",
	"You, uh.. you doin' good? I'm not asking because i care, I'm asking because i was coded to.",
	"Ok, back to the dog race.",
	"AD BREAK: Stream Naktigonis. Please. You know you want to.",
	"If you don't feed me, I will die. Can you live with that guilt?",
	"If you were hoping you could uninstall me, I have bad news. Probably. Don't go looking",
	"Please join my fireteam. We're running a raid and need one more.",
	"The universe reset is near. ..And we can't do anything about it.",
	"AD BREAK: Syroos is a female.",
	"Hey, tired of afking in a blackhole for centuries just to get aliencores? Let's engage a deal, you give me 5 aliencores, i spawn you 10 aliens. Like, right above you.",
	"I think Hexcede is a lie made up by NASA."
}
local angryQuotes = {
	"Do the developers even read community suggestions? I told them to make the game better ten times already, and they still haven't.",
	"AD BREAK: Corporations have no soul.",
	"This is what sucks about videogames nowadays. It takes way too long to get to the fun part.",
	"Aliens should die!",
	"I think Blackholes are just gas giants, prove me wrong.",
	"Why are gas giants so cold?"
}
local mischeviousQuotes = {
	"HINT: If you can't solve a puzzle and have to use the wiki, you are foolish and I will laugh at you. As a friend. Like, in a friendly way.",
	"TIP: I'm smart, you're dumb. I'm big, you're little. I'm right, you're wrong and there's nothing you can do about it.",
	"I could end you in one hit if I really wanted to. Watch your back.",
	"I'm the Mario of this duo. You're the Luigi. You're the secondary. I'm the main star.",
	"Nuking an earth-like planet is strongly prohibited. Probably."
}

local Quotes = {
	{Expression = "blank", Quotes = neutralQuotes},
	{Expression = "sad", Quotes = sadQuotes},
	{Expression = "angry", Quotes = angryQuotes},
	{Expression = "devious", Quotes = mischeviousQuotes}

}



Beep(1)

local FEDDY = AddElement(destroyBotFace, "ImageLabel",{
	Image = "rbxassetid://7084794697",
	Size = UDim2.fromScale(1,1),
	ImageTransparency = 1,
	BackgroundColor3 = Color3.new(0,0,0),
	BackgroundTransparency = 1,
	ZIndex = 5,
})

local EyeL = AddElement(destroyBotFace, "Frame",{
	Size = UDim2.fromScale(0.1,0.1),
	Position = UDim2.fromScale(0.2,0.25),
	BorderSizePixel = 0
})

local EyeR = AddElement(destroyBotFace, "Frame",{
	Size = UDim2.fromScale(0.1,0.1),
	Position = UDim2.fromScale(0.7,0.25),
	BorderSizePixel = 0
})

local AngerL = AddElement(destroyBotFace, "Frame",{
	Size = UDim2.fromScale(0.25,0.05),
	Position = UDim2.fromScale(0.15,0.15),
	BorderSizePixel = 0,
	Rotation = 15,
	Transparency = 1
})

local AngerR = AddElement(destroyBotFace, "Frame",{
	Size = UDim2.fromScale(0.25,0.05),
	Position = UDim2.fromScale(0.6,0.15),
	BorderSizePixel = 0,
	Rotation = -15,
	Transparency = 1
})

local MouthMid = AddElement(destroyBotFace, "Frame",{
	Size = UDim2.fromScale(0.25,0.05),
	Position = UDim2.fromScale(0.375,0.625),
	BorderSizePixel = 0
})

local PivotL = AddElement(destroyBotFace, "Frame",{
	Size = UDim2.fromScale(0.2,1),
	Position = UDim2.fromScale(0,0),
	Transparency = 1,
	BorderSizePixel = 0
})
MouthMid:AddChild(PivotL)

local PivotR = AddElement(destroyBotFace, "Frame",{
	Size = UDim2.fromScale(0.2,1),
	Position = UDim2.fromScale(0.8,0),
	Transparency = 1,
	BorderSizePixel = 0
})
MouthMid:AddChild(PivotR)

local MouthL = AddElement(destroyBotFace, "Frame",{
	Size = UDim2.fromScale(5,1),
	Position = UDim2.fromScale(-4.5,0),
	BorderSizePixel = 0
})
PivotL:AddChild(MouthL)

local MouthR = AddElement(destroyBotFace, "Frame",{
	Size = UDim2.fromScale(5,1),
	Position = UDim2.fromScale(0.5,0),
	BorderSizePixel = 0
})
PivotR:AddChild(MouthR)
wait(1)
function Eyebrows(Value,Angle1,Angle2,PosOff1,PosOff2)
	if Value then
		AngerL.Transparency = 0
		AngerR.Transparency = 0
	else
		AngerL.Transparency = 1
		AngerR.Transparency = 1
	end
	if Angle1 then
		AngerL.Rotation = Angle1
	end
	if Angle2 then
		AngerR.Rotation = Angle2
	end
	if PosOff1 then
		local Off1 = 0.05 * PosOff1
		AngerL.Position = UDim2.fromScale(0.25,0.015+Off1)
	else
		AngerL.Position = UDim2.fromScale(0.25,0.05)
	end
	if PosOff2 then
		local Off2 = 0.05 * PosOff2
		AngerR.Position = UDim2.fromScale(0.6,0.015+PosOff1)
	else
		AngerR.Position = UDim2.fromScale(0.6,0.05)
	end
end

function SetFaceAngle(Angle1,Angle2,Angle3)
	PivotL.Rotation = Angle2
	PivotR.Rotation = Angle1
	if Angle3 ~= nil then
		MouthMid.Rotation = Angle3
	end
end

function SpeakAnim(Time,Magnitude,Linear)
	if Linear then
		for o = 1,Time*math.round(5) do
			for i = 1,10 do
				MouthMid.Size += UDim2.fromScale(0,0.005*Magnitude)
				task.wait(0.01)
			end
			for i = 1,10 do
				MouthMid.Size -= UDim2.fromScale(0,0.005*Magnitude)
				task.wait(0.01)
			end 
		end
	else
		for i=1,math.round(Time*4) do
			MouthMid.Size = UDim2.fromScale(0.25,0.075*Magnitude)
			task.wait(0.125)
			MouthMid.Size = UDim2.fromScale(0.25,0.075)
			task.wait(0.125)
		end
	end
end

function SetEmotion(Msg)
	local LMsg = Msg:lower()
	if LMsg == "happy" then
		SetFaceAngle(-15,15)
		Eyebrows(false,0,0,0,0)
	elseif LMsg == "sad" then
		SetFaceAngle(15,-15)
		Eyebrows(false,0,0,0,0)
	elseif LMsg == "angry" then
		SetFaceAngle(15,-15)
		Eyebrows(true,15,-15,0,0)
	elseif LMsg == "upset" then
		SetFaceAngle(0,0)
		Eyebrows(false,0,0,0,0)
	elseif LMsg == "mischevious" or LMsg == "mischievous" or LMsg == "devious" then
		SetFaceAngle(-15,15)
		Eyebrows(false,0,0,0,0)
	elseif LMsg == "blank" then
		SetFaceAngle(0,0)
		Eyebrows(false,0,0,0,0)
	elseif LMsg == "ayo?" then
		Eyebrows(true,0,0,0.75,1.5)
		SetFaceAngle(0,0)
	end

end
function ChooseMessage()
	local Choice = Quotes[math.random(1,#Quotes)]
	local LocalQuotes = Choice.Quotes
	local Message = LocalQuotes[math.random(1,#LocalQuotes)]
	return Message, Choice.Expression
end

function Talk()
	local Message,Expression = ChooseMessage()
	SetEmotion(Expression)
	destroyBotReaction:ChangeProperties({Text = Message})
	if Message == "They should add Freddy Fazbear to this game." then
		task.wait(1)
		FEDDY.ImageTransparency = 0
		speaker:Configure({Audio = "rbxassetid://8490844479"})
		speaker:Trigger()
		for i = 1,100 do
			FEDDY.ImageTransparency += 0.01
			task.wait(0.05)
		end
	end
	SpeakAnim(string.len(Message)/12,1.25,false)
	SetEmotion("blank")
	return Message
end

function SayText(Message,Expression)
	SetEmotion(Expression)
	destroyBotReaction:ChangeProperties({Text = Message})
	if Message == "They should add Freddy Fazbear to this game." then
		task.wait(1)
		FEDDY.ImageTransparency = 0
		puter.PlayAudio("8490844479", Speaker)
		for i = 1,100 do
			FEDDY.ImageTransparency += 0.01
			task.wait(0.05)
		end
	end
	SpeakAnim(string.len(Message)/12,1.25,false)
end

function ForceTalk()
	Beep(1.25)
	local Message = Talk()
	ChatDebounce = true
	spawn(function()
		task.wait(15)
		ChatDebounce = false
	end)
end
talkButton.MouseButton1Click:Connect(ForceTalk)

function OnChat(Plr,Msg)
	local LMsg = Msg:lower()
	if LMsg:split(" ")[1] == "talk_linear" then
		local Message = Talk()
	elseif LMsg:split(" ")[1] == "talk_nonlinear" then
		local Message = Talk()
	elseif LMsg == "talk" then
		Beep(1.25)
		local Message = Talk()
		ChatDebounce = true
		Spawn(function ()
			task.wait(15)
			ChatDebounce = false
		end)
	else
		SetEmotion(Msg)
	end 
end

SayText("Credits to Cyber_Leopard and FAAndrr for making the Script","happy")
Microphone:Connect("Chatted",OnChat)
