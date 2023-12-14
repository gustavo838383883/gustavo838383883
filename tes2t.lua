local players = {}

local function newCursor(player)
    return screen:CreateElement("ImageLabel", {AnchorPoint = Vector2.new(0.5, 0.5), Image = "rbxassetid://7767269282", BackgroundTransparency = 1, Size = UDim2.fromScale(0.1, 0.1), Position = UDim2.fromScale(0.5, 0.5)}),
    screen:CreateElement("TextLabel", {Text = player, TextSize = 10, TextColor3 = Color3.new(51,51,51), BackgroundColor3 = Color3.new(255,255,255), Size = UDim2.new(0, 0, 0, 0)})
end

screen:Connect("CursorMoved", function(cursor) 
    if not players[cursor.Player] then
        local a,b = newCursor(cursor.Player)
        players[cursor.Player] = {tick(), a, b}
    end
    players[cursor.Player][2].Position = UDim2.fromOffset(cursor.X, cursor.Y)
    players[cursor.Player][3].Position = UDim2.fromOffset(cursor.X, cursor.Y+25)
    players[cursor.Player][1] = tick()
end)

while task.wait(.125) do
    for k,v in pairs(players) do
        if tick() - v[1] > 0.25 then
            v[2]:Destroy()
            v[3]:Destroy()
            players[k] = nil
            --print("marked")
        end
    end
end
