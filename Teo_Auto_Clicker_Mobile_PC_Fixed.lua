local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ============================================================
-- TEO AUTO CLICKER - MOBILE + PC
-- Mobile-safe UI:
--   * Does not steal/lock the player's movement touch
--   * UI dragging only happens while touching the title bar
--   * Slider only captures the touch that started on the slider
--   * Auto-click sends a press AND release, so it cannot leave
--     the simulated mouse button held down
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeoClickerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Scale the UI for phones/tablets while leaving PC size comfortable.
local UIScale = Instance.new("UIScale")
UIScale.Parent = ScreenGui

local function updateScale()
    local viewport = Camera.ViewportSize
    local shortest = math.min(viewport.X, viewport.Y)
    UIScale.Scale = math.clamp(shortest / 650, 0.78, 1)
end

updateScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

-- ============================================================
-- Main GUI
-- ============================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 290, 0, 190)
MainFrame.Position = UDim2.new(0.5, -145, 0.5, -95)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- ============================================================
-- Title bar - ONLY this area is draggable.
-- This is important on mobile because touching the rest of the
-- UI must not interfere with the Roblox movement thumbstick.
-- ============================================================

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ TEO AUTO CLICKER ⚡"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = TitleBar

-- ============================================================
-- Status
-- ============================================================

local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(0, 250, 0, 35)
StatusFrame.Position = UDim2.new(0.5, -125, 0, 52)
StatusFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 1, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "STATUS: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 16
StatusLabel.Parent = StatusFrame

local CPSLabel = Instance.new("TextLabel")
CPSLabel.Size = UDim2.new(0, 250, 0, 20)
CPSLabel.Position = UDim2.new(0.5, -125, 0, 91)
CPSLabel.BackgroundTransparency = 1
CPSLabel.Text = "CPS: 100"
CPSLabel.TextColor3 = Color3.new(1, 1, 1)
CPSLabel.Font = Enum.Font.Gotham
CPSLabel.TextSize = 14
CPSLabel.Parent = MainFrame

-- ============================================================
-- Slider
-- ============================================================

local SliderBg = Instance.new("Frame")
SliderBg.Name = "Slider"
SliderBg.Size = UDim2.new(0, 250, 0, 10)
SliderBg.Position = UDim2.new(0.5, -125, 0, 116)
SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
SliderBg.BorderSizePixel = 0
SliderBg.Active = true
SliderBg.Parent = MainFrame

local SliderBgCorner = Instance.new("UICorner")
SliderBgCorner.CornerRadius = UDim.new(1, 0)
SliderBgCorner.Parent = SliderBg

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(1, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBg

local SliderFillCorner = Instance.new("UICorner")
SliderFillCorner.CornerRadius = UDim.new(1, 0)
SliderFillCorner.Parent = SliderFill

local SliderKnob = Instance.new("TextButton")
SliderKnob.Name = "Knob"
SliderKnob.Size = UDim2.new(0, 22, 0, 22)
SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
SliderKnob.Position = UDim2.new(1, 0, 0.5, 0)
SliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
SliderKnob.Text = ""
SliderKnob.AutoButtonColor = false
SliderKnob.Active = true
SliderKnob.Parent = SliderBg

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = SliderKnob

-- ============================================================
-- Buttons
-- ============================================================

local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(0, 250, 0, 42)
ButtonContainer.Position = UDim2.new(0.5, -125, 0, 140)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainFrame

local OnButton = Instance.new("TextButton")
OnButton.Size = UDim2.new(0, 120, 1, 0)
OnButton.Position = UDim2.new(0, 0, 0, 0)
OnButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
OnButton.Text = "ON"
OnButton.TextColor3 = Color3.new(1, 1, 1)
OnButton.Font = Enum.Font.GothamBold
OnButton.TextSize = 16
OnButton.AutoButtonColor = true
OnButton.Parent = ButtonContainer

local OnCorner = Instance.new("UICorner")
OnCorner.CornerRadius = UDim.new(0, 8)
OnCorner.Parent = OnButton

local OffButton = Instance.new("TextButton")
OffButton.Size = UDim2.new(0, 120, 1, 0)
OffButton.Position = UDim2.new(1, -120, 0, 0)
OffButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
OffButton.Text = "OFF"
OffButton.TextColor3 = Color3.new(1, 1, 1)
OffButton.Font = Enum.Font.GothamBold
OffButton.TextSize = 16
OffButton.AutoButtonColor = true
OffButton.Parent = ButtonContainer

local OffCorner = Instance.new("UICorner")
OffCorner.CornerRadius = UDim.new(0, 8)
OffCorner.Parent = OffButton

-- ============================================================
-- State
-- ============================================================

local clicking = false
local currentCPS = 100
local lastClick = 0

-- These store the exact touch/input being used by the UI.
-- We never treat arbitrary screen touches as UI dragging.
local dragInput = nil
local dragging = false
local dragStart = nil
local startPos = nil

local sliderInput = nil
local sliderDragging = false

-- ============================================================
-- Safe UI dragging
-- ============================================================

local function updateDrag(input)
    if not dragging or not dragStart or not startPos then
        return
    end

    local delta = input.Position - dragStart

    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragInput = input
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input == dragInput then
        dragging = false
        dragInput = nil
        dragStart = nil
        startPos = nil
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        updateDrag(input)
    end
end)

-- ============================================================
-- CPS
-- ============================================================

local function setCPS(value)
    currentCPS = math.clamp(math.round(value), 0, 100)

    CPSLabel.Text = "CPS: " .. currentCPS

    local fillScale = currentCPS / 100
    SliderFill.Size = UDim2.new(fillScale, 0, 1, 0)
    SliderKnob.Position = UDim2.new(fillScale, 0, 0.5, 0)
end

-- ============================================================
-- Slider
-- ============================================================

local function updateSliderFromX(x)
    local sliderPos = SliderBg.AbsolutePosition.X
    local sliderWidth = SliderBg.AbsoluteSize.X

    if sliderWidth <= 0 then
        return
    end

    local relativeX = math.clamp(
        (x - sliderPos) / sliderWidth,
        0,
        1
    )

    setCPS(relativeX * 100)
end

local function beginSlider(input)
    if input.UserInputType ~= Enum.UserInputType.Touch
        and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    sliderDragging = true
    sliderInput = input
    updateSliderFromX(input.Position.X)
end

SliderBg.InputBegan:Connect(beginSlider)
SliderKnob.InputBegan:Connect(beginSlider)

UserInputService.InputChanged:Connect(function(input)
    if not sliderDragging or input ~= sliderInput then
        return
    end

    updateSliderFromX(input.Position.X)
end)

UserInputService.InputEnded:Connect(function(input)
    if input == sliderInput then
        sliderDragging = false
        sliderInput = nil
    end
end)

-- ============================================================
-- Auto-click implementation
--
-- IMPORTANT:
-- Every generated click explicitly sends DOWN then UP.
-- This prevents a stuck mouse button if the click loop stops.
--
-- Prefer VirtualInputManager when the executor exposes it.
-- Fall back to mouse1click for PC/executors that provide it.
-- ============================================================

local VirtualInputManager = nil

pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)

local function sendClick()
    local clicked = false

    if VirtualInputManager then
        clicked = pcall(function()
            local viewport = Camera.ViewportSize
            local x = math.floor(viewport.X * 0.5)
            local y = math.floor(viewport.Y * 0.5)

            VirtualInputManager:SendMouseButtonEvent(
                x, y, 0, true, game, 0
            )

            -- Always release immediately.
            VirtualInputManager:SendMouseButtonEvent(
                x, y, 0, false, game, 0
            )
        end)
    end

    if not clicked then
        pcall(function()
            mouse1click()
        end)
    end
end

-- ============================================================
-- ON / OFF
-- ============================================================

local function turnOn()
    if clicking then
        return
    end

    clicking = true
    StatusLabel.Text = "STATUS: ON"
    StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    OnButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    OffButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)

    lastClick = os.clock()
end

local function turnOff()
    if not clicking then
        return
    end

    clicking = false

    -- Do not leave a simulated mouse button held down.
    -- VirtualInputManager clicks are already released in sendClick().
    pcall(function()
        if VirtualInputManager then
            local viewport = Camera.ViewportSize
            local x = math.floor(viewport.X * 0.5)
            local y = math.floor(viewport.Y * 0.5)

            VirtualInputManager:SendMouseButtonEvent(
                x, y, 0, false, game, 0
            )
        end
    end)

    StatusLabel.Text = "STATUS: OFF"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    OnButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    OffButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
end

local function toggle()
    if clicking then
        turnOff()
    else
        turnOn()
    end
end

OnButton.Activated:Connect(turnOn)
OffButton.Activated:Connect(turnOff)

-- ============================================================
-- Click loop
-- ============================================================

RunService.Heartbeat:Connect(function()
    if not clicking or currentCPS <= 0 then
        return
    end

    local now = os.clock()
    local interval = 1 / currentCPS

    if now - lastClick >= interval then
        sendClick()
        lastClick = now
    end
end)

-- ============================================================
-- PC hotkey
-- On mobile there is no keyboard, so this simply does nothing.
-- ============================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == Enum.KeyCode.Q then
        toggle()
    end
end)

-- ============================================================
-- Emergency stop if GUI is destroyed/reloaded
-- ============================================================

ScreenGui.Destroying:Connect(function()
    clicking = false

    pcall(function()
        if VirtualInputManager then
            local viewport = Camera.ViewportSize
            local x = math.floor(viewport.X * 0.5)
            local y = math.floor(viewport.Y * 0.5)

            VirtualInputManager:SendMouseButtonEvent(
                x, y, 0, false, game, 0
            )
        end
    end)
end)

-- Initialize
setCPS(100)
