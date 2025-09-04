-- NexusLib v1.0
-- Modern Roblox UI Library (PC + Mobile Support)

local NexusLib = {}
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- 🎨 Themes
local Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 30),
        Secondary = Color3.fromRGB(40, 40, 45),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Neon = {
        Background = Color3.fromRGB(15, 20, 35),
        Secondary = Color3.fromRGB(25, 30, 50),
        Accent = Color3.fromRGB(255, 0, 200),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Pastel = {
        Background = Color3.fromRGB(245, 240, 255),
        Secondary = Color3.fromRGB(230, 220, 250),
        Accent = Color3.fromRGB(120, 100, 255),
        Text = Color3.fromRGB(50, 50, 70)
    }
}

-- Utility
local function createCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

-- Main Window
function NexusLib:CreateWindow(cfg)
    cfg = cfg or {}
    local self = {}
    setmetatable(self, {__index = NexusLib})

    self.Title = cfg.Title or "Nexus UI"
    self.Theme = Themes[cfg.Theme or "Dark"]
    self.ToggleKey = cfg.ToggleKey or Enum.KeyCode.RightControl
    self.Tabs = {}

    -- ScreenGui
    self.GUI = Instance.new("ScreenGui")
    self.GUI.Name = "NexusLib_" .. math.random(9999)
    self.GUI.Parent = PlayerGui
    self.GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Frame
    self.Main = Instance.new("Frame")
    self.Main.Size = UDim2.new(0, 500, 0, 550)
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Main.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Main.BackgroundColor3 = self.Theme.Background
    self.Main.Parent = self.GUI
    createCorner(self.Main, 12)

    -- Title Bar
    local bar = Instance.new("Frame", self.Main)
    bar.Size = UDim2.new(1, 0, 0, 45)
    bar.BackgroundColor3 = self.Theme.Secondary
    createCorner(bar, 12)

    local title = Instance.new("TextLabel", bar)
    title.Size = UDim2.new(1, -10, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = self.Title
    title.TextColor3 = self.Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Position = UDim2.new(0, 10, 0, 0)

    -- Tab Buttons
    self.TabButtons = Instance.new("Frame", self.Main)
    self.TabButtons.Size = UDim2.new(0, 140, 1, -45)
    self.TabButtons.Position = UDim2.new(0, 0, 0, 45)
    self.TabButtons.BackgroundColor3 = self.Theme.Secondary
    createCorner(self.TabButtons, 10)

    local list = Instance.new("UIListLayout", self.TabButtons)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 5)

    -- Tab Content
    self.TabContent = Instance.new("Frame", self.Main)
    self.TabContent.Size = UDim2.new(1, -150, 1, -50)
    self.TabContent.Position = UDim2.new(0, 150, 0, 50)
    self.TabContent.BackgroundTransparency = 1

    -- Toggle key
    UIS.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.ToggleKey then
            self.GUI.Enabled = not self.GUI.Enabled
        end
    end)

    return self
end

-- Create Tab
function NexusLib:CreateTab(name)
    local tab = {}
    tab.Name = name or "Tab"

    -- Tab Button
    tab.Button = Instance.new("TextButton", self.TabButtons)
    tab.Button.Size = UDim2.new(1, -10, 0, 35)
    tab.Button.Text = name
    tab.Button.BackgroundColor3 = self.Theme.Background
    tab.Button.TextColor3 = self.Theme.Text
    tab.Button.Font = Enum.Font.Gotham
    tab.Button.TextScaled = true
    createCorner(tab.Button, 8)

    -- Tab Frame
    tab.Content = Instance.new("ScrollingFrame", self.TabContent)
    tab.Content.Size = UDim2.new(1, 0, 1, 0)
    tab.Content.Visible = false
    tab.Content.BackgroundTransparency = 1
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, 0)

    local layout = Instance.new("UIListLayout", tab.Content)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    tab.Button.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = self.Theme.Background
        end
        tab.Content.Visible = true
        tab.Button.BackgroundColor3 = self.Theme.Accent
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        tab.Content.Visible = true
        tab.Button.BackgroundColor3 = self.Theme.Accent
    end

    return tab
end

-- UI Elements
function NexusLib:CreateButton(tab, cfg)
    local b = Instance.new("TextButton", tab.Content)
    b.Size = UDim2.new(1, -10, 0, 35)
    b.Text = cfg.Text or "Button"
    b.BackgroundColor3 = self.Theme.Accent
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    createCorner(b, 8)

    b.MouseButton1Click:Connect(function()
        if cfg.Callback then cfg.Callback() end
    end)
end

function NexusLib:CreateToggle(tab, cfg)
    local state = cfg.Default or false
    local frame = Instance.new("TextButton", tab.Content)
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.Text = (state and "✅ " or "❌ ") .. (cfg.Text or "Toggle")
    frame.BackgroundColor3 = self.Theme.Secondary
    frame.TextColor3 = self.Theme.Text
    frame.Font = Enum.Font.Gotham
    frame.TextScaled = true
    createCorner(frame, 8)

    frame.MouseButton1Click:Connect(function()
        state = not state
        frame.Text = (state and "✅ " or "❌ ") .. (cfg.Text or "Toggle")
        if cfg.Callback then cfg.Callback(state) end
    end)
end

function NexusLib:CreateSlider(tab, cfg)
    local min, max, val = cfg.Min or 0, cfg.Max or 100, cfg.Default or 0
    local frame = Instance.new("Frame", tab.Content)
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundColor3 = self.Theme.Secondary
    createCorner(frame, 8)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = cfg.Text or "Slider"
    label.TextColor3 = self.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextScaled = true

    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 1, -15)
    sliderBg.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    createCorner(sliderBg, 4)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = self.Theme.Accent
    createCorner(sliderFill, 4)

    local dragging = false
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pct = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            val = math.floor(min + (max - min) * pct)
            sliderFill.Size = UDim2.new(pct, 0, 1, 0)
            if cfg.Callback then cfg.Callback(val) end
        end
    end)
end

return NexusLib
