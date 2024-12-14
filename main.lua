local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Signal " .. Fluent.Version,
    SubTitle = "by Signal",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aim", Icon = "crosshair" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://10734950309" }),
    Player = Window:AddTab({ Title = "Player", Icon = "rbxassetid://10747373176" }),
}

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/signal")

Window:SelectTab(1)

Fluent:Notify({
    Title = "Signal",
    Content = "Press RightControl to toggle the UI.",
    Duration = 3
})

local camera = game.Workspace.CurrentCamera
local localPlayer = game.Players.LocalPlayer

local boxESPEnabled = false
local boxESP = {}
local boxTransparency = 1

local lineESPEnabled = false
local lineESP = {}
local lineTransparency = 1

local viewportESPEnabled = false
local viewportESP = {}

local distanceESPEnabled = false
local distanceESP = {}

local headESPEnabled = false
local headESP = {}
local circleTransparency = 1

local interactables = game:GetService("Workspace").Interactable.Containers
local corpseESPEnabled = false
local corpseESP = {}

local aimbotEnabled = false
local lockedTarget = nil
local aimKey = Enum.UserInputType.MouseButton2
local aimSmoothness = 0.1

local ToggleTracer = Tabs.Visuals:AddToggle("TracerESP", { Title = "Tracer ESP", Default = false })
ToggleTracer:OnChanged(function()
    lineESPEnabled = ToggleTracer.Value
end)

local ToggleBox = Tabs.Visuals:AddToggle("BoxESP", { Title = "Box ESP", Default = false })
ToggleBox:OnChanged(function()
    boxESPEnabled = ToggleBox.Value
end)

local ToggleViewportESP = Tabs.Visuals:AddToggle("ViewportESP", { Title = "ViewPort ESP", Default = false })
ToggleViewportESP:OnChanged(function()
    viewportESPEnabled = ToggleViewportESP.Value
end)

local ToggleHeadESP = Tabs.Visuals:AddToggle("HeadESP", { Title = "Head ESP", Default = false })
ToggleHeadESP:OnChanged(function()
    headESPEnabled = ToggleHeadESP.Value
end)

local ToggleDistanceESP = Tabs.Visuals:AddToggle("DistanceESP", { Title = "Distance ESP", Default = false })
ToggleDistanceESP:OnChanged(function()
    distanceESPEnabled = ToggleDistanceESP.Value
end)

local ToggleCorpseESP = Tabs.Visuals:AddToggle("CorpseESP", { Title = "Corpse ESP", Default = false })
ToggleCorpseESP:OnChanged(function()
    corpseESPEnabled = ToggleCorpseESP.Value
end)

local SliderLineTransparency = Tabs.Settings:AddSlider("LineTransparencySlider", {
    Title = "Tracer Transparency",
    Description = "",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        lineTransparency = Value
    end
})

SliderLineTransparency:SetValue(lineTransparency)

local SliderBoxTransparency = Tabs.Settings:AddSlider("BoxTransparencySlider", {
    Title = "Box Transparency",
    Description = "",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        boxTransparency = Value
    end
})

SliderBoxTransparency:SetValue(boxTransparency)

local SliderCircleTransparency = Tabs.Settings:AddSlider("CircleTransparencySlider", {
    Title = "Head Transparency",
    Description = "",
    Default = 1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        circleTransparency = Value
    end
})

SliderCircleTransparency:SetValue(circleTransparency)

local WalkSpeed = Tabs.Player:AddSlider("WalkSpeedSlider", {
    Title = "WalkSpeed",
    Description = "",
    Default = game.Players.LocalPlayer.Character.Humanoid.WalkSpeed,
    Min = 0,
    Max = 250,
    Rounding = 0,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

WalkSpeed:SetValue(game.Players.LocalPlayer.Character.Humanoid.WalkSpeed)

local JumpPower = Tabs.Player:AddSlider("JumpPowerSlider", {
    Title = "JumpPower",
    Description = "",
    Default = game.Players.LocalPlayer.Character.Humanoid.JumpPower,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end
})

JumpPower:SetValue(game.Players.LocalPlayer.Character.Humanoid.JumpPower)

local function ToggleAimbot(Value)
    aimbotEnabled = Value
    if not aimbotEnabled then
        lockedTarget = nil
    end
end

local AimbotToggle = Tabs.Aimbot:AddToggle("AimbotToggle", {
    Title = "Aim Lock [RMB]",
    Default = false
})
AimbotToggle:OnChanged(function()
    ToggleAimbot(AimbotToggle.Value)
end)

local SmoothingSlider = Tabs.Aimbot:AddSlider("AimbotSmoothingSlider", {
    Title = "Aimbot Smoothness",
    Description = "Adjust the smoothness of aimlock.",
    Default = aimSmoothness,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        aimSmoothness = Value
    end
})

SmoothingSlider:SetValue(aimSmoothness)

local function FindNearestPlayer()
    local closestPlayer = nil
    local closestDistance = 250 
    local mousePos = game:GetService("Players").LocalPlayer:GetMouse().Hit.Position

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = player.Character.HumanoidRootPart.Position
            local distance = (mousePos - targetPos).Magnitude

            if distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end

    return closestPlayer
end

local function LockOntoTarget()
    if aimbotEnabled then
        lockedTarget = FindNearestPlayer()
    end
end

local function SmoothAim(targetPos)
    local currentCFrame = camera.CFrame
    local targetCFrame = CFrame.new(camera.CFrame.Position, targetPos)

    local invertedSmoothness = math.clamp(1 - aimSmoothness, 0.01, 1)
    local smoothedCFrame = currentCFrame:Lerp(targetCFrame, invertedSmoothness)
    camera.CFrame = smoothedCFrame
end

local function Aimbot()
    if lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("Head") then
        local targetPos = lockedTarget.Character.Head.Position
        SmoothAim(targetPos)
    end
end

game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.UserInputType == aimKey then
        if aimbotEnabled then
            LockOntoTarget()
        end
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == aimKey then
        if aimbotEnabled then
            lockedTarget = nil
        end
    end
end)

local function UpdateBoxESP()
    if boxESPEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not boxESP[player] then
                    local box = Drawing.new("Square")
                    box.Thickness = 1
                    box.Transparency = boxTransparency
                    box.Color = Color3.fromRGB(255, 255, 255)
                    box.Filled = false
                    boxESP[player] = box
                end

                local character = player.Character
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local rootPos = humanoidRootPart.Position
                    local screenPos, onScreen = camera:WorldToViewportPoint(rootPos)

                    if onScreen then
                        local distance = (camera.CFrame.Position - rootPos).Magnitude
                        local scaleFactor = math.max(1000 / distance, 0.75)
                        local extentsSize = character:GetExtentsSize()
                        local width = extentsSize.X * scaleFactor
                        local height = extentsSize.Y * scaleFactor

                        local characterPos = Vector2.new(screenPos.X - width / 2, screenPos.Y - height / 2)

                        local box = boxESP[player]
                        box.Position = characterPos
                        box.Size = Vector2.new(width, height)
                        box.Transparency = boxTransparency
                        box.Visible = true
                    else
                        boxESP[player].Visible = false
                    end
                end
            elseif boxESP[player] then
                boxESP[player]:Remove()
                boxESP[player] = nil
            end
        end
    else
        for _, box in pairs(boxESP) do
            if box then
                box:Remove()
            end
        end
        boxESP = {}
    end
end

local function UpdateTracerESP()
    if lineESPEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local line = lineESP[player]

                if teamCheckEnabled and player.Team == localPlayer.Team then
                    if lineESP[player] then
                        lineESP[player].Visible = false
                    end
                    continue
                end

                if not line then
                    line = Drawing.new("Line")
                    line.Thickness = 1
                    line.Transparency = lineTransparency
                    line.Color = Color3.fromRGB(255, 255, 255)
                    lineESP[player] = line
                end

                local character = player.Character
                local head = character:FindFirstChild("Head")
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

                if head and humanoidRootPart then
                    local headPos = head.Position
                    local rootPos = humanoidRootPart.Position
                    local screenPos, onScreen = camera:WorldToViewportPoint(headPos)
                    local rootScreenPos, rootOnScreen = camera:WorldToViewportPoint(rootPos)

                    if onScreen then
                        if boxESP[player] and boxESP[player].Visible then
                            local box = boxESP[player]
                            local boxBottomCenter = Vector2.new(box.Position.X + box.Size.X / 2, box.Position.Y + box.Size.Y)
                            line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            line.To = boxBottomCenter
                        else
                            line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            line.To = Vector2.new(rootScreenPos.X, rootScreenPos.Y)
                        end
                        line.Transparency = lineTransparency
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                end
            elseif lineESP[player] then
                lineESP[player]:Remove()
                lineESP[player] = nil
            end
        end
    else
        for _, line in pairs(lineESP) do
            if line then
                line:Remove()
            end
        end
        lineESP = {}
    end
end

local function UpdateViewportESP()
    if viewportESPEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                if not viewportESP[player] then
                    local beam = Instance.new("Beam")
                    local attachment0 = Instance.new("Attachment")
                    local attachment1 = Instance.new("Attachment")

                    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
                    beam.LightEmission = 1
                    beam.LightInfluence = 0
                    beam.Width0 = 0.1
                    beam.Width1 = 0.1
                    beam.Transparency = NumberSequence.new(0.2)

                    attachment0.Parent = workspace.Terrain
                    attachment1.Parent = workspace.Terrain

                    beam.Attachment0 = attachment0
                    beam.Attachment1 = attachment1

                    beam.Parent = workspace.Terrain
                    viewportESP[player] = { beam = beam, attachment0 = attachment0, attachment1 = attachment1 }
                end

                local character = player.Character
                local head = character:FindFirstChild("Head")
                local cameraCFrame = head.CFrame * CFrame.new(0, 0, -1)

                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = { player.Character }
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

                local raycastResult = workspace:Raycast(cameraCFrame.Position, cameraCFrame.LookVector * 500, raycastParams)

                local beamData = viewportESP[player]
                beamData.attachment0.WorldPosition = cameraCFrame.Position

                if raycastResult then
                    beamData.attachment1.WorldPosition = raycastResult.Position
                else
                    beamData.attachment1.WorldPosition = cameraCFrame.Position + cameraCFrame.LookVector * 500
                end

                beamData.beam.Enabled = true
            elseif viewportESP[player] then
                local beamData = viewportESP[player]
                beamData.beam.Enabled = false
            end
        end
    else
        for _, beamData in pairs(viewportESP) do
            if beamData then
                beamData.beam:Destroy()
                beamData.attachment0:Destroy()
                beamData.attachment1:Destroy()
            end
        end
        viewportESP = {}
    end
end

local function UpdateDistanceESP()
    if distanceESPEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if teamCheckEnabled and player.Team == localPlayer.Team then
                    if distanceESP[player] then
                        distanceESP[player].Visible = false
                    end
                    continue
                end

                if not distanceESP[player] then
                    local text = Drawing.new("Text")
                    text.Center = true
                    text.Outline = true
                    text.Color = Color3.fromRGB(255, 255, 255)
                    text.Size = 12
                    distanceESP[player] = text
                end

                local character = player.Character
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

                if humanoidRootPart then
                    local distance = (localPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                    local screenPos, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)

                    local text = distanceESP[player]
                    if onScreen then
                        if boxESPEnabled then
                            local box = boxESP[player]
                            local boxPosition = box.Position
                            text.Position = Vector2.new(boxPosition.X + box.Size.X / 2, boxPosition.Y + box.Size.Y + 5)
                        else
                            text.Position = Vector2.new(screenPos.X, screenPos.Y --[[ - 25]])
                        end
                        text.Text = string.format("[ %dm ]", math.floor(distance))
                        text.Visible = true
                    else
                        text.Visible = false
                    end
                end
            elseif distanceESP[player] then
                distanceESP[player]:Remove()
                distanceESP[player] = nil
            end
        end
    else
        for _, text in pairs(distanceESP) do
            if text then
                text:Remove()
            end
        end
        distanceESP = {}
    end
end

local function UpdateHeadESP()
    if headESPEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                if not headESP[player] then
                    local circle = Drawing.new("Circle")
                    circle.Thickness = 1
                    circle.Transparency = circleTransparency  -- Set initial transparency from slider
                    circle.Color = Color3.fromRGB(255, 255, 255)
                    circle.Filled = false
                    headESP[player] = circle
                end

                local character = player.Character
                local head = character:FindFirstChild("Head")

                if head then
                    local headPos, onScreen = camera:WorldToViewportPoint(head.Position)

                    if onScreen then
                        local headSize = head.Size.X

                        local distance = (camera.CFrame.Position - head.Position).Magnitude

                        local scale = 1000 / distance
                        local circleRadius = (headSize * scale) / 2 

                        local circle = headESP[player]
                        circle.Position = Vector2.new(headPos.X, headPos.Y)
                        circle.Radius = circleRadius
                        circle.Transparency = circleTransparency
                        circle.Visible = true
                    else
                        headESP[player].Visible = false
                    end
                end
            elseif headESP[player] then
                headESP[player]:Remove()
                headESP[player] = nil
            end
        end
    else
        for _, circle in pairs(headESP) do
            if circle then
                circle:Remove()
            end
        end
        headESP = {}
    end
end

local function UpdateCorpseESP()
    if corpseESPEnabled then
        local currentInteractables = {}

        for _, interactable in pairs(interactables:GetChildren()) do
            if interactable:IsA("Model") and string.find(interactable.Name:lower(), "corpse") then
                currentInteractables[interactable] = true

                if not corpseESP[interactable] then
                    local text = Drawing.new("Text")
                    text.Center = true
                    text.Outline = true
                    text.Color = Color3.fromRGB(255, 0, 0)
                    text.Size = 12
                    corpseESP[interactable] = text
                end

                local primaryPart = interactable.PrimaryPart or interactable:FindFirstChild("HumanoidRootPart") or interactable:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    local screenPos, onScreen = camera:WorldToViewportPoint(primaryPart.Position)

                    local distance = (localPlayer.Character.HumanoidRootPart.Position - primaryPart.Position).Magnitude

                    local text = corpseESP[interactable]
                    if onScreen then
                        text.Position = Vector2.new(screenPos.X, screenPos.Y --[[- 25]])
                        text.Text = string.format("%s | [ %dm ]", interactable.Name, math.floor(distance))
                        text.Visible = true
                    else
                        text.Visible = false
                    end
                else
                    if corpseESP[interactable] then
                        corpseESP[interactable]:Remove()
                        corpseESP[interactable] = nil
                    end
                end
            elseif corpseESP[interactable] then
                corpseESP[interactable]:Remove()
                corpseESP[interactable] = nil
            end
        end

        for interactable, _ in pairs(corpseESP) do
            if not currentInteractables[interactable] then
                if corpseESP[interactable] then
                    corpseESP[interactable]:Remove()
                    corpseESP[interactable] = nil
                end
            end
        end
    else
        for _, text in pairs(corpseESP) do
            if text then
                text:Remove()
            end
        end
        corpseESP = {}
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    if aimbotEnabled and lockedTarget then
        Aimbot()
    end

    UpdateBoxESP()
    UpdateTracerESP()
    UpdateViewportESP()
    UpdateDistanceESP()
    UpdateHeadESP()
    UpdateCorpseESP()
end)

game.Players.PlayerRemoving:Connect(function(player)
    if boxESP[player] then
        boxESP[player]:Remove()
        boxESP[player] = nil
    end
    if lineESP[player] then
        lineESP[player]:Remove()
        lineESP[player] = nil
    end
    if viewportESP[player] then
        local beamData = viewportESP[player]
        beamData.beam:Destroy()
        beamData.attachment0:Destroy()
        beamData.attachment1:Destroy()
        viewportESP[player] = nil
    end
    if distanceESP[player] then
        distanceESP[player]:Remove()
        distanceESP[player] = nil
    end
    if headESP[player] then
        headESP[player]:Remove()
        headESP[player] = nil
    end
end)
