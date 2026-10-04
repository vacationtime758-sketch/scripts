local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- State Variables
local HitboxEnabled = false
local HitboxVisible = false
local InvisibilityEnabled = false
local AntiRagdollEnabled = false
local AntiGrabEnabled = false

local FakeChar = nil
local HitboxSize = 10
local HitboxTransparency = 0.9

local TargetInput = ""
local AvoidInput = ""

local Keybinds = {
    Hitbox = Enum.KeyCode.F1,
    HitboxVisible = Enum.KeyCode.F2,
    Invisibility = Enum.KeyCode.F3,
    AntiRagdoll = Enum.KeyCode.F4,
    GoToCannon = Enum.KeyCode.F5,
    ResetChar = Enum.KeyCode.F6,
    ToggleUI = Enum.KeyCode.Insert
}

-- Target & Avoid Helper Functions
local function parseList(text)
    local list = {}
    for entry in string.gmatch(text, "[^,]+") do
        local cleaned = entry:match("^%s*(.-)%s*$"):lower()
        if cleaned ~= "" then
            table.insert(list, cleaned)
        end
    end
    return list
end

local function matchesAny(player, list)
    local username = player.Name:lower()
    local displayName = player.DisplayName:lower()
    
    for _, target in ipairs(list) do
        if username:find(target, 1, true) or displayName:find(target, 1, true) then
            return true
        end
    end
    return false
end

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "6ixx"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local parentTarget = gethui and gethui() or (CoreGui and CoreGui) or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = parentTarget

local Frame = Instance.new("Frame")
Frame.Name = "6ixx"
Frame.Size = UDim2.new(0, 280, 0, 470) 
Frame.Position = UDim2.new(1, -290, 1, -480)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Thickness = 3
UIStroke.Color = Color3.fromRGB(90, 90, 90)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 0, 35)
TitleLabel.Position = UDim2.new(0, 5, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 22
TitleLabel.Text = "6ixx"
TitleLabel.Parent = Frame

local OptionsFrame = Instance.new("Frame")
OptionsFrame.Size = UDim2.new(1, -10, 1, -80)
OptionsFrame.Position = UDim2.new(0, 5, 0, 40)
OptionsFrame.BackgroundTransparency = 1
OptionsFrame.Parent = Frame

local UIListLayout = Instance.new("UIListLayout", OptionsFrame)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIListLayout.Padding = UDim.new(0, 5)

-- Option Row Builder
local function createOptionRow(labelText, bindName, onClick)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 28)
    row.BackgroundTransparency = 1
    row.Parent = OptionsFrame

    local hotkeyBox = Instance.new("TextButton")
    hotkeyBox.Size = UDim2.new(0, 50, 1, 0)
    hotkeyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    hotkeyBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    hotkeyBox.Font = Enum.Font.SourceSansBold
    hotkeyBox.TextSize = 14
    hotkeyBox.Text = bindName and Keybinds[bindName].Name or "N/A"
    hotkeyBox.Parent = row

    local hkCorner = Instance.new("UICorner", hotkeyBox)
    hkCorner.CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextButton")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 60, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = labelText
    label.Parent = row

    if bindName then
        local rebinding = false
        hotkeyBox.MouseButton1Click:Connect(function()
            if rebinding then return end
            rebinding = true
            hotkeyBox.Text = "..."
            local connection
            connection = UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe and input.KeyCode ~= Enum.KeyCode.Unknown then
                    Keybinds[bindName] = input.KeyCode
                    hotkeyBox.Text = input.KeyCode.Name
                    rebinding = false
                    connection:Disconnect()
                end
            end)
        end)
    end

    if onClick then
        label.MouseButton1Click:Connect(onClick)
    end

    return label, row
end

-- UI Rows Creation
local HitboxLabel, HitboxRow = createOptionRow("Hitbox: OFF", "Hitbox", function()
    HitboxEnabled = not HitboxEnabled
    HitboxLabel.Text = "Hitbox: " .. (HitboxEnabled and "ON" or "OFF")
    updateAllHitboxes()
end)

local HitboxVisLabel = createOptionRow("Hitbox Visibility: OFF", "HitboxVisible", function()
    HitboxVisible = not HitboxVisible
    HitboxVisLabel.Text = "Hitbox Visibility: " .. (HitboxVisible and "ON" or "OFF")
    updateAllHitboxes()
end)

local InvisLabel = createOptionRow("Invisibility: OFF", "Invisibility", function()
    if InvisibilityEnabled then
        disableInvisibility()
        InvisLabel.Text = "Invisibility: OFF"
    else
        enableInvisibility()
        InvisLabel.Text = "Invisibility: ON"
    end
end)

local AntiRagdollLabel = createOptionRow("Anti-Ragdoll: OFF", "AntiRagdoll", function()
    AntiRagdollEnabled = not AntiRagdollEnabled
    AntiRagdollLabel.Text = "Anti-Ragdoll: " .. (AntiRagdollEnabled and "ON" or "OFF")
end)

local CannonLabel = createOptionRow("Go To Cannon", "GoToCannon", function()
    tpAndActivateCannon()
end)

local ResetLabel = createOptionRow("Reset Character", "ResetChar", function()
    resetCharacter()
end)

-- Hitbox Size Input Inside Hitbox Row
local SizeBox = Instance.new("TextBox")
SizeBox.Size = UDim2.new(0, 45, 1, -4)
SizeBox.Position = UDim2.new(1, -45, 0, 2)
SizeBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeBox.Font = Enum.Font.SourceSansBold
SizeBox.TextSize = 14
SizeBox.Text = tostring(HitboxSize)
SizeBox.ClearTextOnFocus = false
SizeBox.Parent = HitboxRow
Instance.new("UICorner", SizeBox).CornerRadius = UDim.new(0, 6)

-- Input Field Builder (Target / Avoid)
local function createInputRow(labelText, placeholder)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 28)
    row.BackgroundTransparency = 1
    row.Parent = OptionsFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 65, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = labelText
    label.Parent = row

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -70, 1, -4)
    textBox.Position = UDim2.new(0, 70, 0, 2)
    textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Font = Enum.Font.SourceSansBold
    textBox.TextSize = 14
    textBox.PlaceholderText = placeholder
    textBox.Text = ""
    textBox.ClearTextOnFocus = false
    textBox.Parent = row
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)

    return textBox
end

local TargetBox = createInputRow("Target:", "User1, User2...")
local AvoidBox = createInputRow("Avoid:", "User1, User2...")

-- Toggle Button Builder (Anti-Grab)
local function createToggleRow(labelText)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 28)
    row.BackgroundTransparency = 1
    row.Parent = OptionsFrame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 15
    btn.Text = labelText
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    return btn
end

local AntiGrabBtn = createToggleRow("Anti-Grab: OFF")

-- Unload Button
local UnloadButton = Instance.new("TextButton")
UnloadButton.Size = UDim2.new(1, -30, 0, 30)
UnloadButton.Position = UDim2.new(0, 15, 1, -35)
UnloadButton.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
UnloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadButton.Font = Enum.Font.SourceSansBold
UnloadButton.TextSize = 16
UnloadButton.Text = "Unload"
UnloadButton.Parent = Frame
Instance.new("UICorner", UnloadButton).CornerRadius = UDim.new(0, 8)

UnloadButton.MouseButton1Click:Connect(function()
    pcall(function() ScreenGui:Destroy() end)
end)

----------------------------------------------------
-- HITBOX SYSTEM
----------------------------------------------------
local hrpCache = {}

local function updateHitbox(player, hrp)
    if not hrp or not hrp.Parent then return end

    local targets = parseList(TargetInput)
    local avoids = parseList(AvoidInput)

    local shouldApplyHitbox = HitboxEnabled

    -- Check Avoid list (Matches Username OR DisplayName)
    if #avoids > 0 and matchesAny(player, avoids) then
        shouldApplyHitbox = false
    end

    -- Check Target list (Matches Username OR DisplayName)
    if shouldApplyHitbox and #targets > 0 then
        if not matchesAny(player, targets) then
            shouldApplyHitbox = false
        end
    end

    if not shouldApplyHitbox then
        hrp.Size = Vector3.new(2, 2, 1)
        hrp.Transparency = 1
        hrp.Material = Enum.Material.Plastic
        hrp.CanCollide = false
        return
    end

    hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
    hrp.Transparency = HitboxVisible and HitboxTransparency or 1
    hrp.Material = HitboxVisible and Enum.Material.Neon or Enum.Material.Plastic
    hrp.CanCollide = false
end

function updateAllHitboxes()
    for player, hrp in pairs(hrpCache) do
        updateHitbox(player, hrp)
    end
end

TargetBox:GetPropertyChangedSignal("Text"):Connect(function()
    TargetInput = TargetBox.Text
    updateAllHitboxes()
end)

AvoidBox:GetPropertyChangedSignal("Text"):Connect(function()
    AvoidInput = AvoidBox.Text
    updateAllHitboxes()
end)

SizeBox.FocusLost:Connect(function()
    local newSize = tonumber(SizeBox.Text)
    if newSize and newSize > 0 then
        HitboxSize = newSize
        updateAllHitboxes()
    else
        SizeBox.Text = tostring(HitboxSize)
    end
end)

local function cachePlayerHRP(player)
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrpCache[player] = hrp
            updateHitbox(player, hrp)
        end
    end
    player.CharacterAdded:Connect(function(c)
        local hrp = c:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            hrpCache[player] = hrp
            updateHitbox(player, hrp)
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then cachePlayerHRP(p) end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then cachePlayerHRP(p) end
end)

Players.PlayerRemoving:Connect(function(p)
    hrpCache[p] = nil
end)

----------------------------------------------------
-- INVISIBILITY SYSTEM
----------------------------------------------------
function enableInvisibility()
    if not LocalPlayer.Character then return end
    local character = LocalPlayer.Character
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        FakeChar = root:Clone()
        FakeChar.Parent = Workspace
        FakeChar.Anchored = false
        FakeChar.CanCollide = false
    end
    character.Parent = Lighting
    InvisibilityEnabled = true
end

function disableInvisibility()
    if FakeChar then
        FakeChar:Destroy()
        FakeChar = nil
    end
    if LocalPlayer.Character then
        LocalPlayer.Character.Parent = Workspace
    end
    InvisibilityEnabled = false
end

----------------------------------------------------
-- RESET CHARACTER SYSTEM
----------------------------------------------------
function resetCharacter()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end
    end
end

----------------------------------------------------
-- ANTI-RAGDOLL SYSTEM
----------------------------------------------------
local BAD_STATES = {
    [Enum.HumanoidStateType.Physics]     = true,
    [Enum.HumanoidStateType.FallingDown] = true,
    [Enum.HumanoidStateType.GettingUp]   = true,
    [Enum.HumanoidStateType.Ragdoll]     = true,
}

local ragdollEvent
task.spawn(function()
    local events = ReplicatedStorage:WaitForChild("Events", 10)
    if events then 
        ragdollEvent = events:WaitForChild("RagdollState", 10) 
    end
end)

local antiRagdollConn, antiRagdollAccum = nil, 0

local function startAntiRagdoll()
    if antiRagdollConn then antiRagdollConn:Disconnect() end
    antiRagdollAccum = 0
    antiRagdollConn = RunService.Heartbeat:Connect(function(dt)
        if not AntiRagdollEnabled then return end
        antiRagdollAccum += dt
        if antiRagdollAccum < 0.1 then return end
        antiRagdollAccum = 0

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or not hum.Parent then return end

        if ragdollEvent then 
            pcall(function() ragdollEvent:FireServer(false) end) 
        end
        
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        
        if BAD_STATES[hum:GetState()] then 
            hum:ChangeState(Enum.HumanoidStateType.Running) 
        end
        
        if hum.PlatformStand then 
            hum.PlatformStand = false 
        end
    end)
end

startAntiRagdoll()

----------------------------------------------------
-- ANTI-GRAB SYSTEM
----------------------------------------------------
RunService.Stepped:Connect(function()
    if not AntiGrabEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("JointInstance") or part:IsA("Weld") or part:IsA("WeldConstraint") then
            local part0 = part.Part0
            local part1 = part.Part1
            if part0 and not part0:IsDescendantOf(char) then
                part:Destroy()
            elseif part1 and not part1:IsDescendantOf(char) then
                part:Destroy()
            end
        end
    end
end)

AntiGrabBtn.MouseButton1Click:Connect(function()
    AntiGrabEnabled = not AntiGrabEnabled
    AntiGrabBtn.Text = "Anti-Grab: " .. (AntiGrabEnabled and "ON" or "OFF")
    AntiGrabBtn.BackgroundColor3 = AntiGrabEnabled and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(40, 40, 40)
end)

----------------------------------------------------
-- CANNON TELEPORT LOGIC
----------------------------------------------------
function tpAndActivateCannon()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local cannonTarget = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if (name:find("cannon") or name:find("cañon")) and not name:find("fito") then
                cannonTarget = obj
                break
            end
        end
    end

    if cannonTarget then
        local targetPart = cannonTarget:IsA("Model") and cannonTarget.PrimaryPart or cannonTarget
        if not targetPart and cannonTarget:IsA("Model") then
            for _, p in ipairs(cannonTarget:GetDescendants()) do
                if p:IsA("BasePart") then
                    targetPart = p
                    break
                end
            end
        end
        
        if targetPart then
            hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.05)
            
            local prompt = cannonTarget:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                fireproximityprompt(prompt)
            else
                local click = cannonTarget:FindFirstChildWhichIsA("ClickDetector", true)
                if click then
                    fireclickdetector(click)
                else
                    firetouchinterest(hrp, targetPart, 0)
                    task.wait(0.02)
                    firetouchinterest(hrp, targetPart, 1)
                end
            end
        end
    end
end

----------------------------------------------------
-- KEYBOARD INPUT HANDLING
----------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Keybinds.Hitbox then
        HitboxEnabled = not HitboxEnabled
        HitboxLabel.Text = "Hitbox: " .. (HitboxEnabled and "ON" or "OFF")
        updateAllHitboxes()

    elseif input.KeyCode == Keybinds.HitboxVisible then
        HitboxVisible = not HitboxVisible
        HitboxVisLabel.Text = "Hitbox Visibility: " .. (HitboxVisible and "ON" or "OFF")
        updateAllHitboxes()

    elseif input.KeyCode == Keybinds.Invisibility then
        if InvisibilityEnabled then
            disableInvisibility()
            InvisLabel.Text = "Invisibility: OFF"
        else
            enableInvisibility()
            InvisLabel.Text = "Invisibility: ON"
        end

    elseif input.KeyCode == Keybinds.AntiRagdoll then
        AntiRagdollEnabled = not AntiRagdollEnabled
        AntiRagdollLabel.Text = "Anti-Ragdoll: " .. (AntiRagdollEnabled and "ON" or "OFF")

    elseif input.KeyCode == Keybinds.GoToCannon then
        tpAndActivateCannon()

    elseif input.KeyCode == Keybinds.ResetChar then
        resetCharacter()

    elseif input.KeyCode == Keybinds.ToggleUI then
        Frame.Visible = not Frame.Visible
    end
end)