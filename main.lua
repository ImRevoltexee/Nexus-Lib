if self.Minimized then
        -- Epic minimize animation
        createTween(self.Main, AnimationPresets.Elastic, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Rotation = 360
        }):Play()
        
        wait(0.6)
        self.Main.Visible = false
        self.Main.Rotation = 0
        self.FloatingBtn.Visible = true
        
        -- Floating button entrance
        self.FloatingBtn.Size = UDim2.new(0, 0, 0, 0)
        createTween(self.FloatingBtn, AnimationPresets.Bounce, {Size = UDim2.new(0, 60, 0, 60)}):Play()
        
        showNotification("UI Minimized", "Click the floating button to restore", 2, "info")
    else
        self.FloatingBtn.Visible = false
        self.Main.Visible = true
        
        createTween(self.Main, AnimationPresets.Elastic, {
            Size = self.Size,
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        showNotification("UI Restored", "Welcome back!", 2, "success")
    end
end

function NexusUI:Toggle()
    self.Visible = not self.Visible
    
    if self.Visible then
        self.GUI.Enabled = true
        if not self.Minimized then
            self.Main.Size = UDim2.new(0, 0, 0, 0)
            createTween(self.Main, AnimationPresets.Bounce, {Size = self.Size}):Play()
        else
            self.FloatingBtn.Size = UDim2.new(0, 0, 0, 0)
            createTween(self.FloatingBtn, AnimationPresets.Bounce, {Size = UDim2.new(0, 60, 0, 60)}):Play()
        end
        showNotification("UI Shown", "Interface is now visible", 2, "info")
    else
        local fadeOutTween = createTween(self.GUI, AnimationPresets.Medium, {BackgroundTransparency = 1})
        fadeOutTween:Play()
        fadeOutTween.Completed:Connect(function()
            self.GUI.Enabled = false
            self.GUI.BackgroundTransparency = 0
        end)
        showNotification("UI Hidden", "Press " .. self.ToggleKey.Name .. " to show", 2, "info")
    end
end

function NexusUI:ChangeTheme(themeName)
    if not Themes[themeName] then return end
    
    local oldTheme = self.CurrentTheme
    self.Theme = themeName
    self.CurrentTheme = Themes[themeName]
    
    -- Smooth theme transition
    local transitionDuration = 0.5
    
    -- Update main elements
    createTween(self.Main, TweenInfo.new(transitionDuration), {BackgroundColor3 = self.CurrentTheme.Background}):Play()
    createTween(self.TitleBar, TweenInfo.new(transitionDuration), {BackgroundColor3 = self.CurrentTheme.Secondary}):Play()
    createTween(self.TabButtons, TweenInfo.new(transitionDuration), {BackgroundColor3 = self.CurrentTheme.Secondary}):Play()
    createTween(self.FloatingBtn, TweenInfo.new(transitionDuration), {BackgroundColor3 = self.CurrentTheme.Accent}):Play()
    
    -- Update control buttons
    createTween(self.ThemeBtn, TweenInfo.new(transitionDuration), {BackgroundColor3 = self.CurrentTheme.Accent}):Play()
    
    -- Update tabs with cascade effect
    for i, tab in pairs(self.Tabs) do
        spawn(function()
            wait(i * 0.1)
            if tab.Active then
                createTween(tab.Button, TweenInfo.new(transitionDuration), {BackgroundColor3 = self.CurrentTheme.Accent}):Play()
                createTween(tab.Icon_Object, TweenInfo.new(transitionDuration), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                createTween(tab.Label_Object, TweenInfo.new(transitionDuration), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            else
                createTween(tab.Button, TweenInfo.new(transitionDuration), {BackgroundColor3 = self.CurrentTheme.Secondary}):Play()
                createTween(tab.Icon_Object, TweenInfo.new(transitionDuration), {TextColor3 = self.CurrentTheme.TextDim}):Play()
                createTween(tab.Label_Object, TweenInfo.new(transitionDuration), {TextColor3 = self.CurrentTheme.TextDim}):Play()
            end
        end)
    end
    
    -- Update gradients and glows
    spawn(function()
        wait(0.2)
        -- Re-create gradients with new colors
        for _, obj in pairs(self.GUI:GetDescendants()) do
            if obj:FindFirstChild("UIGradient") then
                obj.UIGradient:Destroy()
                if obj.Name == "TitleBar" then
                    addGradient(obj, self.CurrentTheme.AccentGradient, 45)
                elseif obj.Parent and obj.Parent.Name:find("Button") and obj.Parent.Parent == self.TabButtons then
                    if self.ActiveTab and obj.Parent == self.ActiveTab.Button then
                        addGradient(obj, self.CurrentTheme.AccentGradient, 45)
                    end
                end
            end
        end
    end)
end

function NexusUI:Destroy()
    -- Dramatic exit animation
    showNotification("Goodbye!", "NexusUI is shutting down...", 2, "info")
    
    local exitTween = createTween(self.Main, AnimationPresets.Elastic, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Rotation = -360,
        BackgroundTransparency = 1
    })
    exitTween:Play()
    
    exitTween.Completed:Connect(function()
        if self.GUI then
            self.GUI:Destroy()
        end
        if self.BlurEffect then
            removeBlur(self.BlurEffect)
        end
    end)
end

-- Premium Notification Enhancement
function NexusUI:ShowNotification(title, message, duration, notificationType)
    showNotification(title, message, duration, notificationType)
end

-- Advanced API Methods

function NexusUI:UpdateElement(elementName, properties)
    -- Update element properties dynamically
    local element = self:FindElement(elementName)
    if element then
        for property, value in pairs(properties) do
            if element[property] then
                createTween(element, AnimationPresets.Fast, {[property] = value}):Play()
            end
        end
    end
end

function NexusUI:FindElement(elementName)
    -- Find element by name across all tabs
    for _, tab in pairs(self.Tabs) do
        for _, child in pairs(tab.Content:GetChildren()) do
            if child.Name == elementName then
                return child
            end
        end
    end
    return nil
end

function NexusUI:SetTabActive(tabName)
    -- Programmatically switch tabs
    for _, tab in pairs(self.Tabs) do
        if tab.Name == tabName then
            self:SwitchTab(tab)
            break
        end
    end
end

function NexusUI:AddCustomElement(tab, element)
    -- Add custom user-created elements
    element.Parent = tab.Content
    return element
end

-- Example Usage and Premium Documentation
--[[

═══════════════════════════════════════════════════════════════════════════════════
    🚀 NEXUS UI LIBRARY v2.0 - FLAGSHIP EDITION 🚀
    Premium Professional UI Library for Roblox Scripts
    Rivaling Rayfield, Sirius, and Orion in Quality & Features
═══════════════════════════════════════════════════════════════════════════════════

📋 FEATURES OVERVIEW:
✅ 6 Premium Themes (Dark, Neon, Pastel, Cyberpunk, Ocean, Sunset)
✅ Cross-Platform Support (PC & Mobile Optimized)
✅ Advanced Key System with Multi-Step Verification
✅ Draggable Floating Button (Minimize System)
✅ Real-time Theme Switching
✅ Premium Animations & Transitions
✅ Advanced Notification System
✅ Blur Effects & Glow Effects
✅ Professional Component Library
✅ Mobile-First Responsive Design

═══════════════════════════════════════════════════════════════════════════════════
📖 BASIC SETUP:
═══════════════════════════════════════════════════════════════════════════════════

-- Load the library
local NexusUI = loadstring(game:HttpGet("YOUR_SCRIPT_URL_HERE"))()

-- Create window with premium configuration
local Window = NexusUI.new({
    Title = "My Premium Script v2.0",
    Theme = "Neon", -- "Dark", "Neon", "Pastel", "Cyberpunk", "Ocean", "Sunset"
    Size = UDim2.new(0, 580, 0, 680), -- Auto-scales for mobile
    ToggleKey = Enum.KeyCode.RightControl,
    AutoScale = true, -- Enables mobile optimization
    KeySystem = {
        ValidateKey = function(key)
            -- Multi-step validation example
            local validKeys = {"premium_key_2024", "vip_access_token", "developer_key"}
            return table.find(validKeys, key) ~= nil
        end,
        KeyURL = "https://your-key-website.com/get-key"
    }
})

═══════════════════════════════════════════════════════════════════════════════════
🎨 THEME MANAGEMENT:
═══════════════════════════════════════════════════════════════════════════════════

-- Change theme at runtime with smooth transition
Window:ChangeTheme("Cyberpunk")

-- Available themes:
-- • Dark - Professional dark theme
-- • Neon - Vibrant neon colors with glow effects
-- • Pastel - Soft, modern pastel colors
-- • Cyberpunk - Pink/cyan cyberpunk aesthetic
-- • Ocean - Blue ocean-inspired theme
-- • Sunset - Orange/pink sunset gradient theme

═══════════════════════════════════════════════════════════════════════════════════
📑 CREATING TABS:
═══════════════════════════════════════════════════════════════════════════════════

local MainTab = Window:CreateTab({
    Name = "Combat",
    Icon = "⚔️"
})

local PlayerTab = Window:CreateTab({
    Name = "Player", 
    Icon = "👤"
})

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "🎨"
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "⚙️"
})

═══════════════════════════════════════════════════════════════════════════════════
🧩 UI COMPONENTS:
═══════════════════════════════════════════════════════════════════════════════════

-- SECTION (Organize content)
Window:CreateSection(MainTab, {
    Name = "CombatSection",
    Text = "Combat Features",
    Icon = "⚔️"
})

-- BUTTON (Execute actions)
Window:CreateButton(MainTab, {
    Name = "AutoFarmBtn",
    Text = "Start Auto Farm",
    Icon = "🚀",
    Callback = function()
        print("Auto farm started!")
        Window:ShowNotification("Auto Farm", "Feature activated successfully!", 3, "success")
    end
})

-- TOGGLE (Boolean switches)
Window:CreateToggle(MainTab, {
    Name = "AutoAttackToggle",
    Text = "Auto Attack",
    Icon = "⚡",
    Description = "Automatically attack nearby enemies",
    Default = false,
    Callback = function(state)
        print("Auto attack:", state)
        if state then
            Window:ShowNotification("Auto Attack", "Feature enabled!", 2, "success")
        else
            Window:ShowNotification("Auto Attack", "Feature disabled!", 2, "warning")
        end
    end
})

-- SLIDER (Numeric values)
Window:CreateSlider(PlayerTab, {
    Name = "WalkSpeedSlider",
    Text = "Walk Speed",
    Icon = "🏃",
    Min = 16,
    Max = 100,
    Default = 16,
    Suffix = " studs/s",
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        Window:ShowNotification("Speed Changed", "Walk speed set to " .. value, 1, "info")
    end
})

-- DROPDOWN (Select from options)
Window:CreateDropdown(MainTab, {
    Name = "WeaponDropdown",
    Text = "Select Weapon",
    Icon = "🗡️",
    Options = {"Sword", "Axe", "Bow", "Staff", "Dagger"},
    Default = "Sword",
    Callback = function(selected)
        print("Selected weapon:", selected)
        Window:ShowNotification("Weapon Selected", selected .. " equipped!", 2, "info")
    end
})

-- TEXTBOX (Text input)
Window:CreateTextbox(PlayerTab, {
    Name = "PlayerNameTextbox",
    Text = "Target Player",
    Icon = "🎯",
    Placeholder = "Enter player name...",
    Default = "",
    Callback = function(text, enterPressed)
        if enterPressed and text ~= "" then
            print("Target set to:", text)
            Window:ShowNotification("Target Set", "Now targeting: " .. text, 2, "success")
        end
    end
})

-- LABEL (Display information)
Window:CreateLabel(VisualsTab, {
    Name = "InfoLabel",
    Text = "ESP and visual features",
    Icon = "👁️",
    Color = Color3.fromRGB(100, 255, 100)
})

═══════════════════════════════════════════════════════════════════════════════════
🎮 ADVANCED FEATURES:
═══════════════════════════════════════════════════════════════════════════════════

-- Manual UI control
Window:Toggle() -- Show/hide UI
Window:ToggleMinimize() -- Minimize/restore
Window:SetTabActive("Combat") -- Switch to specific tab

-- Notifications
Window:ShowNotification("Custom Title", "Your message here", 5, "success")
-- Types: "info", "success", "warning", "error"

-- Theme switching with notification
Window:ChangeTheme("Ocean")

-- Cleanup
Window:Destroy() -- Proper cleanup with exit animation

═══════════════════════════════════════════════════════════════════════════════════
📱 MOBILE OPTIMIZATION:
═══════════════════════════════════════════════════════════════════════════════════

The library automatically detects mobile devices and:
• Increases button sizes for touch input
• Optimizes spacing and layout
• Adjusts font sizes for readability  
• Enables touch-friendly interactions
• Scales UI elements appropriately

═══════════════════════════════════════════════════════════════════════════════════
🔧 ADVANCED CUSTOMIZATION:
═══════════════════════════════════════════════════════════════════════════════════

-- Custom element properties
local button = Window:CreateButton(MainTab, {...})
Window:UpdateElement("ButtonName", {
    BackgroundColor3 = Color3.fromRGB(255, 0, 0),
    Size = UDim2.new(1, 0, 0, 50)
})

-- Find elements
local element = Window:FindElement("ElementName")

-- Add custom elements
local customFrame = Instance.new("Frame")
Window:AddCustomElement(MainTab, customFrame)

═══════════════════════════════════════════════════════════════════════════════════
⚡ PERFORMANCE & QUALITY:
═══════════════════════════════════════════════════════════════════════════════════

✅ Optimized for 60+ FPS
✅ Memory efficient
✅ No external dependencies
✅ Clean, maintainable code
✅ Professional error handling
✅ Smooth animations and transitions
✅ Premium visual effects
✅ Cross-platform compatibility

═══════════════════════════════════════════════════════════════════════════════════

This library represents the pinnacle of Roblox UI design, combining beautiful aesthetics
with powerful functionality. Built to compete with and exceed the quality of popular
libraries like Rayfield, Sirius, and Orion.

Made with ❤️ for the Roblox scripting community.

═══════════════════════════════════════════════════════════════════════════════════

]]

return NexusUI
    
    updateToggle()
    
    return toggleFrame
end

function NexusUI:CreateSlider(tab, options)
    options = options or {}
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = options.Name or "Slider"
    sliderFrame.Size = UDim2.new(1, 0, 0, isMobile() and 70 or 65)
    sliderFrame.BackgroundColor3 = self.CurrentTheme.Secondary
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = tab.Content
    
    addCorner(sliderFrame, 12)
    addStroke(sliderFrame, self.CurrentTheme.Accent, 2, 0.3)
    
    -- Slider icon
    local sliderIcon = Instance.new("TextLabel")
    sliderIcon.Size = UDim2.new(0, 30, 0, 30)
    sliderIcon.Position = UDim2.new(0, 15, 0, 8)
    sliderIcon.BackgroundTransparency = 1
    sliderIcon.Text = options.Icon or "🎚️"
    sliderIcon.TextColor3 = self.CurrentTheme.Accent
    sliderIcon.TextScaled = true
    sliderIcon.Font = Enum.Font.GothamBold
    sliderIcon.Parent = sliderFrame
    
    -- Slider label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -55, 0, 20)
    label.Position = UDim2.new(0, 55, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = options.Text or "Slider"
    label.TextColor3 = self.CurrentTheme.Text
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    -- Value display
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.5, -15, 0, 25)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 5)
    valueLabel.BackgroundColor3 = self.CurrentTheme.Accent
    valueLabel.BorderSizePixel = 0
    valueLabel.Text = tostring(options.Default or options.Min or 0)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextScaled = true
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = sliderFrame
    
    addCorner(valueLabel, 6)
    addGradient(valueLabel, self.CurrentTheme.AccentGradient, 45)
    
    -- Slider track
    local sliderBG = Instance.new("Frame")
    sliderBG.Size = UDim2.new(1, -30, 0, 8)
    sliderBG.Position = UDim2.new(0, 15, 1, -20)
    sliderBG.BackgroundColor3 = self.CurrentTheme.Tertiary
    sliderBG.BorderSizePixel = 0
    sliderBG.Parent = sliderFrame
    
    addCorner(sliderBG, 4)
    
    -- Slider fill with gradient
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = self.CurrentTheme.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBG
    
    addCorner(sliderFill, 4)
    addGradient(sliderFill, self.CurrentTheme.AccentGradient, 0)
    
    -- Premium slider knob
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 20, 0, 20)
    sliderKnob.Position = UDim2.new(0, -10, 0.5, -10)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Parent = sliderFill
    
    addCorner(sliderKnob, 10)
    addStroke(sliderKnob, self.CurrentTheme.Accent, 3)
    addShadow(sliderKnob, self.CurrentTheme.Accent, 5, 0.6)
    
    local min = options.Min or 0
    local max = options.Max or 100
    local current = options.Default or min
    local suffix = options.Suffix or ""
    local dragging = false
    
    local function updateSlider(value)
        current = math.clamp(value, min, max)
        local percentage = (current - min) / (max - min)
        
        createTween(sliderFill, AnimationPresets.Fast, {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
        createTween(sliderKnob, AnimationPresets.Fast, {Position = UDim2.new(percentage, -10, 0.5, -10)}):Play()
        
        valueLabel.Text = string.format("%.1f", current) .. suffix
        
        -- Animate value label
        createTween(valueLabel, TweenInfo.new(0.1), {Size = UDim2.new(0.5, -12, 0, 28)}):Play()
        wait(0.1)
        createTween(valueLabel, TweenInfo.new(0.1), {Size = UDim2.new(0.5, -15, 0, 25)}):Play()
        
        if options.Callback then
            spawn(function() options.Callback(current) end)
        end
    end
    
    local function onInput(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local percentage = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
                updateSlider(min + percentage * (max - min))
            end
        end
    end
    
    sliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            createTween(sliderKnob, AnimationPresets.Fast, {Size = UDim2.new(0, 24, 0, 24)}):Play()
            local percentage = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
            updateSlider(min + percentage * (max - min))
        end
    end)
    
    UserInputService.InputChanged:Connect(onInput)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                createTween(sliderKnob, AnimationPresets.Fast, {Size = UDim2.new(0, 20, 0, 20)}):Play()
            end
        end
    end)
    
    updateSlider(current)
    
    return sliderFrame
end

function NexusUI:CreateDropdown(tab, options)
    options = options or {}
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = options.Name or "Dropdown"
    dropdownFrame.Size = UDim2.new(1, 0, 0, isMobile() and 55 or 50)
    dropdownFrame.BackgroundColor3 = self.CurrentTheme.Secondary
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = tab.Content
    
    addCorner(dropdownFrame, 12)
    addStroke(dropdownFrame, self.CurrentTheme.Accent, 2, 0.3)
    
    -- Dropdown icon
    local dropdownIcon = Instance.new("TextLabel")
    dropdownIcon.Size = UDim2.new(0, 30, 0, 30)
    dropdownIcon.Position = UDim2.new(0, 15, 0.5, -15)
    dropdownIcon.BackgroundTransparency = 1
    dropdownIcon.Text = options.Icon or "📋"
    dropdownIcon.TextColor3 = self.CurrentTheme.Accent
    dropdownIcon.TextScaled = true
    dropdownIcon.Font = Enum.Font.GothamBold
    dropdownIcon.Parent = dropdownFrame
    
    -- Dropdown label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, -55, 1, 0)
    label.Position = UDim2.new(0, 55, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = options.Text or "Dropdown"
    label.TextColor3 = self.CurrentTheme.Text
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdownFrame
    
    -- Dropdown button
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.6, -25, 0, 35)
    dropdown.Position = UDim2.new(0.4, 5, 0.5, -17.5)
    dropdown.BackgroundColor3 = self.CurrentTheme.Background
    dropdown.BorderSizePixel = 0
    dropdown.Text = ""
    dropdown.Parent = dropdownFrame
    
    addCorner(dropdown, 8)
    addStroke(dropdown, self.CurrentTheme.Accent, 1)
    
    -- Dropdown text
    local dropdownText = Instance.new("TextLabel")
    dropdownText.Size = UDim2.new(1, -35, 1, 0)
    dropdownText.Position = UDim2.new(0, 10, 0, 0)
    dropdownText.BackgroundTransparency = 1
    dropdownText.Text = options.Default or (options.Options and options.Options[1]) or "Select..."
    dropdownText.TextColor3 = self.CurrentTheme.Text
    dropdownText.TextScaled = true
    dropdownText.Font = Enum.Font.Gotham
    dropdownText.TextXAlignment = Enum.TextXAlignment.Left
    dropdownText.Parent = dropdown
    
    -- Animated arrow
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = self.CurrentTheme.Accent
    arrow.TextScaled = true
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = dropdown
    
    -- Options container
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "OptionsContainer"
    optionsContainer.Size = UDim2.new(0.6, -25, 0, 0)
    optionsContainer.Position = UDim2.new(0.4, 5, 1, 10)
    optionsContainer.BackgroundColor3 = self.CurrentTheme.Background
    optionsContainer.BorderSizePixel = 0
    optionsContainer.Visible = false
    optionsContainer.ZIndex = 20
    optionsContainer.Parent = dropdownFrame
    
    addCorner(optionsContainer, 8)
    addStroke(optionsContainer, self.CurrentTheme.Accent, 2)
    addShadow(optionsContainer, Color3.fromRGB(0, 0, 0), 10, 0.4)
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = optionsContainer
    
    local function createOption(text, index)
        local optionBtn = Instance.new("TextButton")
        optionBtn.Name = "Option_" .. index
        optionBtn.Size = UDim2.new(1, 0, 0, 35)
        optionBtn.BackgroundColor3 = self.CurrentTheme.Background
        optionBtn.BorderSizePixel = 0
        optionBtn.Text = ""
        optionBtn.Parent = optionsContainer
        
        local optionText = Instance.new("TextLabel")
        optionText.Size = UDim2.new(1, -15, 1, 0)
        optionText.Position = UDim2.new(0, 10, 0, 0)
        optionText.BackgroundTransparency = 1
        optionText.Text = text
        optionText.TextColor3 = self.CurrentTheme.Text
        optionText.TextScaled = true
        optionText.Font = Enum.Font.Gotham
        optionText.TextXAlignment = Enum.TextXAlignment.Left
        optionText.Parent = optionBtn
        
        optionBtn.MouseEnter:Connect(function()
            createTween(optionBtn, AnimationPresets.Fast, {
                BackgroundColor3 = self.CurrentTheme.Accent:lerp(self.CurrentTheme.Background, 0.8)
            }):Play()
            createTween(optionText, AnimationPresets.Fast, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)
        
        optionBtn.MouseLeave:Connect(function()
            createTween(optionBtn, AnimationPresets.Fast, {BackgroundColor3 = self.CurrentTheme.Background}):Play()
            createTween(optionText, AnimationPresets.Fast, {TextColor3 = self.CurrentTheme.Text}):Play()
        end)
        
        optionBtn.MouseButton1Click:Connect(function()
            dropdownText.Text = text
            optionsContainer.Visible = false
            arrow.Text = "▼"
            dropdownFrame.Size = UDim2.new(1, 0, 0, isMobile() and 55 or 50)
            
            createTween(arrow, AnimationPresets.Fast, {Rotation = 0}):Play()
            
            if options.Callback then
                spawn(function() options.Callback(text) end)
            end
        end)
    end
    
    if options.Options then
        for i, option in ipairs(options.Options) do
            createOption(option, i)
        end
        
        optionsContainer.Size = UDim2.new(0.6, -25, 0, #options.Options * 35)
    end
    
    dropdown.MouseButton1Click:Connect(function()
        local isOpen = optionsContainer.Visible
        
        if not isOpen then
            optionsContainer.Visible = true
            optionsContainer.Size = UDim2.new(0.6, -25, 0, 0)
            createTween(optionsContainer, AnimationPresets.Medium, {
                Size = UDim2.new(0.6, -25, 0, #options.Options * 35)
            }):Play()
            dropdownFrame.Size = UDim2.new(1, 0, 0, (isMobile() and 55 or 50) + (#options.Options * 35) + 15)
            arrow.Text = "▲"
            createTween(arrow, AnimationPresets.Fast, {Rotation = 180}):Play()
        else
            createTween(optionsContainer, AnimationPresets.Fast, {Size = UDim2.new(0.6, -25, 0, 0)}):Play()
            wait(0.2)
            optionsContainer.Visible = false
            dropdownFrame.Size = UDim2.new(1, 0, 0, isMobile() and 55 or 50)
            arrow.Text = "▼"
            createTween(arrow, AnimationPresets.Fast, {Rotation = 0}):Play()
        end
    end)
    
    return dropdownFrame
end

function NexusUI:CreateTextbox(tab, options)
    options = options or {}
    
    local textboxFrame = Instance.new("Frame")
    textboxFrame.Name = options.Name or "Textbox"
    textboxFrame.Size = UDim2.new(1, 0, 0, isMobile() and 55 or 50)
    textboxFrame.BackgroundColor3 = self.CurrentTheme.Secondary
    textboxFrame.BorderSizePixel = 0
    textboxFrame.Parent = tab.Content
    
    addCorner(textboxFrame, 12)
    addStroke(textboxFrame, self.CurrentTheme.Accent, 2, 0.3)
    
    -- Textbox icon
    local textboxIcon = Instance.new("TextLabel")
    textboxIcon.Size = UDim2.new(0, 30, 0, 30)
    textboxIcon.Position = UDim2.new(0, 15, 0.5, -15)
    textboxIcon.BackgroundTransparency = 1
    textboxIcon.Text = options.Icon or "✏️"
    textboxIcon.TextColor3 = self.CurrentTheme.Accent
    textboxIcon.TextScaled = true
    textboxIcon.Font = Enum.Font.GothamBold
    textboxIcon.Parent = textboxFrame
    
    -- Textbox label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.3, -55, 1, 0)
    label.Position = UDim2.new(0, 55, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = options.Text or "Textbox"
    label.TextColor3 = self.CurrentTheme.Text
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = textboxFrame
    
    -- Enhanced textbox
    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(0.7, -25, 0, 35)
    textbox.Position = UDim2.new(0.3, 5, 0.5, -17.5)
    textbox.BackgroundColor3 = self.CurrentTheme.Background
    textbox.BorderSizePixel = 0
    textbox.PlaceholderText = options.Placeholder or "Enter text..."
    textbox.PlaceholderColor3 = self.CurrentTheme.TextDim
    textbox.Text = options.Default or ""
    textbox.TextColor3 = self.CurrentTheme.Text
    textbox.TextScaled = true
    textbox.Font = Enum.Font.Gotham
    textbox.ClearTextOnFocus = false
    textbox.Parent = textboxFrame
    
    addCorner(textbox, 8)
    addStroke(textbox, self.CurrentTheme.Accent, 1)
    
    local textboxPadding = Instance.new("UIPadding")
    textboxPadding.PaddingLeft = UDim.new(0, 10)
    textboxPadding.PaddingRight = UDim.new(0, 10)
    textboxPadding.Parent = textbox
    
    -- Enhanced focus animations
    textbox.Focused:Connect(function()
        createTween(textbox, AnimationPresets.Fast, {
            BackgroundColor3 = self.CurrentTheme.Background:lerp(self.CurrentTheme.Accent, 0.1),
            Size = UDim2.new(0.7, -21, 0, 35)
        }):Play()
        createTween(textboxIcon, AnimationPresets.Fast, {
            TextColor3 = self.CurrentTheme.Accent,
            Rotation = 15
        }):Play()
        addGlow(textbox, self.CurrentTheme.Accent, 3, 0.8)
    end)
    
    textbox.FocusLost:Connect(function(enterPressed)
        createTween(textbox, AnimationPresets.Fast, {
            BackgroundColor3 = self.CurrentTheme.Background,
            Size = UDim2.new(0.7, -25, 0, 35)
        }):Play()
        createTween(textboxIcon, AnimationPresets.Fast, {
            TextColor3 = self.CurrentTheme.Accent,
            Rotation = 0
        }):Play()
        
        if options.Callback then
            spawn(function() options.Callback(textbox.Text, enterPressed) end)
        end
    end)
    
    return textboxFrame
end

function NexusUI:CreateLabel(tab, options)
    options = options or {}
    
    local labelFrame = Instance.new("Frame")
    labelFrame.Name = options.Name or "Label"
    labelFrame.Size = UDim2.new(1, 0, 0, options.Size or (isMobile() and 40 or 35))
    labelFrame.BackgroundTransparency = 1
    labelFrame.Parent = tab.Content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = (options.Icon or "ℹ️") .. " " .. (options.Text or "Label")
    label.TextColor3 = options.Color or self.CurrentTheme.Text
    label.TextScaled = true
    label.Font = options.Font or Enum.Font.Gotham
    label.TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Left
    label.Parent = labelFrame
    
    return labelFrame
end

function NexusUI:CreateSection(tab, options)
    options = options or {}
    
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = options.Name or "Section"
    sectionFrame.Size = UDim2.new(1, 0, 0, isMobile() and 50 or 45)
    sectionFrame.BackgroundColor3 = self.CurrentTheme.Secondary
    sectionFrame.BorderSizePixel = 0
    sectionFrame.Parent = tab.Content
    
    addCorner(sectionFrame, 12)
    addGradient(sectionFrame, self.CurrentTheme.AccentGradient, 90)
    
    local sectionIcon = Instance.new("TextLabel")
    sectionIcon.Size = UDim2.new(0, 30, 0, 30)
    sectionIcon.Position = UDim2.new(0, 15, 0.5, -15)
    sectionIcon.BackgroundTransparency = 1
    sectionIcon.Text = options.Icon or "📁"
    sectionIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    sectionIcon.TextScaled = true
    sectionIcon.Font = Enum.Font.GothamBold
    sectionIcon.Parent = sectionFrame
    
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Size = UDim2.new(1, -60, 1, 0)
    sectionLabel.Position = UDim2.new(0, 55, 0, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = options.Text or "Section"
    sectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sectionLabel.TextScaled = true
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = sectionFrame
    
    return sectionFrame
end

-- Enhanced System Functions

function NexusUI:MakeDraggable()
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.Main.Position
            
            -- Visual feedback
            createTween(self.Main, AnimationPresets.Fast, {Size = self.Size:lerp(UDim2.new(self.Size.X.Scale, self.Size.X.Offset - 4, self.Size.Y.Scale, self.Size.Y.Offset - 4), 1)}):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                createTween(self.Main, AnimationPresets.Fast, {Size = self.Size}):Play()
            end
        end
    end)
end

function NexusUI:SetupToggle()
    -- Enhanced floating button
    self.FloatingBtn = Instance.new("TextButton")
    self.FloatingBtn.Name = "FloatingBtn"
    self.FloatingBtn.Size = UDim2.new(0, 60, 0, 60)
    self.FloatingBtn.Position = UDim2.new(0, 25, 0, 25)
    self.FloatingBtn.BackgroundColor3 = self.CurrentTheme.Accent
    self.FloatingBtn.BorderSizePixel = 0
    self.FloatingBtn.Text = ""
    self.FloatingBtn.Visible = false
    self.FloatingBtn.ZIndex = 100
    self.FloatingBtn.Parent = self.GUI
    
    addCorner(self.FloatingBtn, 30)
    addGradient(self.FloatingBtn, self.CurrentTheme.AccentGradient, 45)
    addShadow(self.FloatingBtn, self.CurrentTheme.Shadow, 15, 0.5)
    addGlow(self.FloatingBtn, self.CurrentTheme.Accent, 8, 0.7)
    
    -- Floating button icon
    local floatingIcon = Instance.new("TextLabel")
    floatingIcon.Size = UDim2.new(0.7, 0, 0.7, 0)
    floatingIcon.Position = UDim2.new(0.15, 0, 0.15, 0)
    floatingIcon.BackgroundTransparency = 1
    floatingIcon.Text = "⚡"
    floatingIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatingIcon.TextScaled = true
    floatingIcon.Font = Enum.Font.GothamBold
    floatingIcon.Parent = self.FloatingBtn
    
    -- Pulsing animation for floating button
    spawn(function()
        while self.FloatingBtn.Parent do
            if self.FloatingBtn.Visible then
                createTween(self.FloatingBtn, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 65, 0, 65)}):Play()
                createTween(floatingIcon, TweenInfo.new(2, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
                wait(1)
                createTween(self.FloatingBtn, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 60, 0, 60)}):Play()
                wait(1)
                floatingIcon.Rotation = 0
            else
                wait(0.1)
            end
        end
    end)
    
    -- Make floating button draggable
    local floatingDragging = false
    local floatingDragStart = nil
    local floatingStartPos = nil
    
    self.FloatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatingDragging = true
            floatingDragStart = input.Position
            floatingStartPos = self.FloatingBtn.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if floatingDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - floatingDragStart
            self.FloatingBtn.Position = UDim2.new(floatingStartPos.X.Scale, floatingStartPos.X.Offset + delta.X, floatingStartPos.Y.Scale, floatingStartPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatingDragging = false
        end
    end)
    
    self.FloatingBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Toggle key functionality
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == self.ToggleKey then
            self:Toggle()
        end
    end)
end

function NexusUI:ToggleMinimize()
    self.Minimized = not self.Minimized
    -- NexusUI Library v2.0 - FLAGSHIP EDITION
-- Premium Professional UI Library for Roblox
-- Rivaling Rayfield, Sirius, and Orion quality
-- Cross-platform support with flagship-grade animations

local NexusUI = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Premium Theme Configurations
local Themes = {
    Dark = {
        Name = "Dark Elegance",
        Background = Color3.fromRGB(18, 18, 23),
        Secondary = Color3.fromRGB(25, 25, 32),
        Tertiary = Color3.fromRGB(32, 32, 40),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentGradient = {Color3.fromRGB(88, 101, 242), Color3.fromRGB(139, 69, 255)},
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(170, 170, 185),
        Success = Color3.fromRGB(87, 242, 135),
        Warning = Color3.fromRGB(255, 202, 40),
        Error = Color3.fromRGB(237, 66, 69),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    Neon = {
        Name = "Neon Dreams",
        Background = Color3.fromRGB(5, 5, 15),
        Secondary = Color3.fromRGB(10, 10, 25),
        Tertiary = Color3.fromRGB(15, 15, 35),
        Accent = Color3.fromRGB(0, 255, 127),
        AccentGradient = {Color3.fromRGB(0, 255, 127), Color3.fromRGB(0, 191, 255)},
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 255, 200),
        Success = Color3.fromRGB(57, 255, 20),
        Warning = Color3.fromRGB(255, 159, 10),
        Error = Color3.fromRGB(255, 20, 147),
        Shadow = Color3.fromRGB(0, 255, 127)
    },
    Pastel = {
        Name = "Soft Pastel",
        Background = Color3.fromRGB(248, 250, 255),
        Secondary = Color3.fromRGB(255, 255, 255),
        Tertiary = Color3.fromRGB(245, 247, 252),
        Accent = Color3.fromRGB(139, 69, 255),
        AccentGradient = {Color3.fromRGB(139, 69, 255), Color3.fromRGB(255, 154, 158)},
        Text = Color3.fromRGB(45, 55, 72),
        TextDim = Color3.fromRGB(113, 128, 150),
        Success = Color3.fromRGB(72, 187, 120),
        Warning = Color3.fromRGB(237, 137, 54),
        Error = Color3.fromRGB(245, 101, 101),
        Shadow = Color3.fromRGB(139, 69, 255)
    },
    Cyberpunk = {
        Name = "Cyberpunk 2077",
        Background = Color3.fromRGB(8, 8, 16),
        Secondary = Color3.fromRGB(15, 15, 25),
        Tertiary = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(255, 20, 147),
        AccentGradient = {Color3.fromRGB(255, 20, 147), Color3.fromRGB(0, 255, 255)},
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(255, 20, 147),
        Success = Color3.fromRGB(0, 255, 0),
        Warning = Color3.fromRGB(255, 255, 0),
        Error = Color3.fromRGB(255, 0, 0),
        Shadow = Color3.fromRGB(255, 20, 147)
    },
    Ocean = {
        Name = "Ocean Breeze",
        Background = Color3.fromRGB(12, 25, 45),
        Secondary = Color3.fromRGB(16, 35, 55),
        Tertiary = Color3.fromRGB(20, 45, 65),
        Accent = Color3.fromRGB(0, 150, 255),
        AccentGradient = {Color3.fromRGB(0, 150, 255), Color3.fromRGB(0, 255, 200)},
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 200, 255),
        Success = Color3.fromRGB(0, 255, 150),
        Warning = Color3.fromRGB(255, 200, 50),
        Error = Color3.fromRGB(255, 100, 100),
        Shadow = Color3.fromRGB(0, 150, 255)
    },
    Sunset = {
        Name = "Sunset Glow",
        Background = Color3.fromRGB(20, 15, 25),
        Secondary = Color3.fromRGB(30, 25, 35),
        Tertiary = Color3.fromRGB(40, 35, 45),
        Accent = Color3.fromRGB(255, 154, 0),
        AccentGradient = {Color3.fromRGB(255, 154, 0), Color3.fromRGB(255, 69, 140)},
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(255, 200, 150),
        Success = Color3.fromRGB(0, 255, 100),
        Warning = Color3.fromRGB(255, 200, 0),
        Error = Color3.fromRGB(255, 69, 58),
        Shadow = Color3.fromRGB(255, 154, 0)
    }
}

-- Enhanced Animation System
local AnimationPresets = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Medium = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    Elastic = TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
}

-- Advanced Notification System
local NotificationQueue = {}
local ActiveNotifications = {}

-- Utility functions
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function createTween(object, info, properties)
    return TweenService:Create(object, info, properties)
end

local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object
    return corner
end

local function addGradient(object, colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = rotation or 0
    gradient.Parent = object
    return gradient
end

local function addStroke(object, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = object
    return stroke
end

local function addShadow(object, color, size, transparency)
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, size * 2, 1, size * 2)
    shadow.Position = UDim2.new(0, -size, 0, -size)
    shadow.BackgroundColor3 = color or Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = transparency or 0.5
    shadow.ZIndex = object.ZIndex - 1
    shadow.Parent = object
    addCorner(shadow, size)
    return shadow
end

local function addGlow(object, color, size, transparency)
    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, size * 2, 1, size * 2)
    glow.Position = UDim2.new(0, -size, 0, -size)
    glow.BackgroundColor3 = color
    glow.BackgroundTransparency = transparency or 0.7
    glow.ZIndex = object.ZIndex - 1
    glow.Parent = object
    addCorner(glow, size + 5)
    
    -- Animated glow effect
    local glowTween = createTween(glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        BackgroundTransparency = (transparency or 0.7) + 0.2
    })
    glowTween:Play()
    
    return glow
end

local function createBlur()
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting
    
    createTween(blur, AnimationPresets.Medium, {Size = 24}):Play()
    
    return blur
end

local function removeBlur(blur)
    if blur then
        createTween(blur, AnimationPresets.Medium, {Size = 0}):Play()
        game:GetService("Debris"):AddItem(blur, 0.5)
    end
end

-- Advanced Notification System
local function showNotification(title, message, duration, notificationType)
    duration = duration or 3
    notificationType = notificationType or "info"
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 350, 0, 80)
    notification.Position = UDim2.new(1, 20, 0, 20 + (#ActiveNotifications * 90))
    notification.BackgroundColor3 = Themes.Dark.Secondary
    notification.BorderSizePixel = 0
    notification.Parent = PlayerGui
    
    addCorner(notification, 12)
    addStroke(notification, notificationType == "error" and Themes.Dark.Error or 
                           notificationType == "success" and Themes.Dark.Success or 
                           notificationType == "warning" and Themes.Dark.Warning or 
                           Themes.Dark.Accent, 2)
    addShadow(notification, Color3.fromRGB(0, 0, 0), 8, 0.3)
    
    -- Gradient background
    local gradientColors = notificationType == "error" and {Themes.Dark.Error, Themes.Dark.Secondary} or
                          notificationType == "success" and {Themes.Dark.Success, Themes.Dark.Secondary} or
                          notificationType == "warning" and {Themes.Dark.Warning, Themes.Dark.Secondary} or
                          {Themes.Dark.Accent, Themes.Dark.Secondary}
    
    addGradient(notification, gradientColors, 45)
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 15, 0.5, -20)
    icon.BackgroundTransparency = 1
    icon.Text = notificationType == "error" and "❌" or 
                notificationType == "success" and "✅" or 
                notificationType == "warning" and "⚠️" or "ℹ️"
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextScaled = true
    icon.Font = Enum.Font.GothamBold
    icon.Parent = notification
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -70, 0, 25)
    titleLabel.Position = UDim2.new(0, 60, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -70, 0, 20)
    messageLabel.Position = UDim2.new(0, 60, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Themes.Dark.TextDim
    messageLabel.TextScaled = true
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = notification
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = notification
    
    -- Animations
    notification.Position = UDim2.new(1, 20, 0, 20 + (#ActiveNotifications * 90))
    createTween(notification, AnimationPresets.Medium, {Position = UDim2.new(1, -370, 0, 20 + (#ActiveNotifications * 90))}):Play()
    
    table.insert(ActiveNotifications, notification)
    
    -- Auto close
    local function closeNotification()
        createTween(notification, AnimationPresets.Medium, {
            Position = UDim2.new(1, 20, 0, notification.Position.Y.Offset)
        }):Play()
        
        wait(0.3)
        
        for i, notif in ipairs(ActiveNotifications) do
            if notif == notification then
                table.remove(ActiveNotifications, i)
                break
            end
        end
        
        notification:Destroy()
        
        -- Reposition remaining notifications
        for i, notif in ipairs(ActiveNotifications) do
            createTween(notif, AnimationPresets.Fast, {Position = UDim2.new(1, -370, 0, 20 + ((i-1) * 90))}):Play()
        end
    end
    
    closeBtn.MouseButton1Click:Connect(closeNotification)
    
    spawn(function()
        wait(duration)
        closeNotification()
    end)
end

-- Main Library Class
function NexusUI.new(options)
    options = options or {}
    local self = {}
    
    -- Configuration
    self.Title = options.Title or "NexusUI"
    self.Theme = options.Theme or "Dark"
    self.KeySystem = options.KeySystem
    self.ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    self.Size = options.Size or UDim2.new(0, isMobile() and 420 or 580, 0, isMobile() and 580 or 680)
    self.AutoScale = options.AutoScale ~= false
    
    -- State
    self.Minimized = false
    self.Visible = true
    self.CurrentTheme = Themes[self.Theme]
    self.Tabs = {}
    self.ActiveTab = nil
    self.Elements = {}
    self.BlurEffect = nil
    
    -- Create main GUI
    self:CreateMainUI()
    
    -- Key system check
    if self.KeySystem then
        self:ShowKeySystem()
    else
        self:ShowMainUI()
    end
    
    -- Setup toggle functionality
    self:SetupToggle()
    
    -- Welcome notification
    showNotification("NexusUI Loaded", "Premium UI Library v2.0 initialized successfully!", 4, "success")
    
    return self
end

function NexusUI:CreateMainUI()
    -- Main ScreenGui
    self.GUI = Instance.new("ScreenGui")
    self.GUI.Name = "NexusUI_" .. HttpService:GenerateGUID(false):sub(1, 8)
    self.GUI.ResetOnSpawn = false
    self.GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.GUI.DisplayOrder = 100
    self.GUI.Parent = PlayerGui
    
    -- Main Frame
    self.Main = Instance.new("Frame")
    self.Main.Name = "Main"
    self.Main.Size = self.Size
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Main.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Main.BackgroundColor3 = self.CurrentTheme.Background
    self.Main.BorderSizePixel = 0
    self.Main.ClipsDescendants = true
    self.Main.Parent = self.GUI
    
    addCorner(self.Main, 16)
    addStroke(self.Main, self.CurrentTheme.Accent, 2)
    addShadow(self.Main, self.CurrentTheme.Shadow, 20, 0.4)
    
    -- Animated background gradient
    local bgGradient = addGradient(self.Main, {
        self.CurrentTheme.Background, 
        self.CurrentTheme.Secondary:lerp(self.CurrentTheme.Background, 0.5)
    }, 45)
    
    -- Title bar with gradient
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 60)
    self.TitleBar.BackgroundColor3 = self.CurrentTheme.Secondary
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.Main
    
    addCorner(self.TitleBar, 16)
    addGradient(self.TitleBar, self.CurrentTheme.AccentGradient, 45)
    
    -- Title with animation
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -150, 1, 0)
    titleLabel.Position = UDim2.new(0, 25, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🚀 " .. self.Title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = self.TitleBar
    
    -- Version label
    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(0, 100, 0, 20)
    versionLabel.Position = UDim2.new(0, 25, 1, -25)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = "v2.0 Flagship"
    versionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    versionLabel.TextTransparency = 0.3
    versionLabel.TextScaled = true
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.Parent = self.TitleBar
    
    -- Control buttons with enhanced design
    self:CreateControlButtons()
    
    -- Tab container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(1, 0, 1, -60)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 60)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.Main
    
    -- Tab buttons frame with gradient
    self.TabButtons = Instance.new("Frame")
    self.TabButtons.Name = "TabButtons"
    self.TabButtons.Size = UDim2.new(0, isMobile() and 100 or 160, 1, 0)
    self.TabButtons.BackgroundColor3 = self.CurrentTheme.Secondary
    self.TabButtons.BorderSizePixel = 0
    self.TabButtons.Parent = self.TabContainer
    
    addCorner(self.TabButtons, 0)
    
    -- Tab buttons layout
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.FillDirection = Enum.FillDirection.Vertical
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = self.TabButtons
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 15)
    tabPadding.PaddingLeft = UDim.new(0, 8)
    tabPadding.PaddingRight = UDim.new(0, 8)
    tabPadding.PaddingBottom = UDim.new(0, 15)
    tabPadding.Parent = self.TabButtons
    
    -- Tab content frame
    self.TabContent = Instance.new("Frame")
    self.TabContent.Name = "TabContent"
    self.TabContent.Size = UDim2.new(1, isMobile() and -100 or -160, 1, 0)
    self.TabContent.Position = UDim2.new(0, isMobile() and 100 or 160, 0, 0)
    self.TabContent.BackgroundTransparency = 1
    self.TabContent.Parent = self.TabContainer
    
    -- Make draggable with smooth animation
    self:MakeDraggable()
    
    -- Theme selector
    self:CreateThemeSelector()
end

function NexusUI:CreateControlButtons()
    -- Button container
    local controlContainer = Instance.new("Frame")
    controlContainer.Size = UDim2.new(0, 120, 0, 35)
    controlContainer.Position = UDim2.new(1, -130, 0.5, -17.5)
    controlContainer.BackgroundTransparency = 1
    controlContainer.Parent = self.TitleBar
    
    local controlLayout = Instance.new("UIListLayout")
    controlLayout.FillDirection = Enum.FillDirection.Horizontal
    controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlLayout.Padding = UDim.new(0, 8)
    controlLayout.Parent = controlContainer
    
    -- Theme button
    self.ThemeBtn = Instance.new("TextButton")
    self.ThemeBtn.Name = "ThemeBtn"
    self.ThemeBtn.Size = UDim2.new(0, 35, 0, 35)
    self.ThemeBtn.BackgroundColor3 = self.CurrentTheme.Accent
    self.ThemeBtn.BorderSizePixel = 0
    self.ThemeBtn.Text = "🎨"
    self.ThemeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.ThemeBtn.TextScaled = true
    self.ThemeBtn.Font = Enum.Font.GothamBold
    self.ThemeBtn.Parent = controlContainer
    
    addCorner(self.ThemeBtn, 8)
    addGlow(self.ThemeBtn, self.CurrentTheme.Accent, 3, 0.8)
    
    -- Minimize button
    self.MinimizeBtn = Instance.new("TextButton")
    self.MinimizeBtn.Name = "MinimizeBtn"
    self.MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    self.MinimizeBtn.BackgroundColor3 = self.CurrentTheme.Warning
    self.MinimizeBtn.BorderSizePixel = 0
    self.MinimizeBtn.Text = "−"
    self.MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.MinimizeBtn.TextScaled = true
    self.MinimizeBtn.Font = Enum.Font.GothamBold
    self.MinimizeBtn.Parent = controlContainer
    
    addCorner(self.MinimizeBtn, 8)
    
    -- Close button
    self.CloseBtn = Instance.new("TextButton")
    self.CloseBtn.Name = "CloseBtn"
    self.CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    self.CloseBtn.BackgroundColor3 = self.CurrentTheme.Error
    self.CloseBtn.BorderSizePixel = 0
    self.CloseBtn.Text = "×"
    self.CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.CloseBtn.TextScaled = true
    self.CloseBtn.Font = Enum.Font.GothamBold
    self.CloseBtn.Parent = controlContainer
    
    addCorner(self.CloseBtn, 8)
    
    -- Enhanced button animations
    local function createButtonHover(button, hoverColor)
        button.MouseEnter:Connect(function()
            createTween(button, AnimationPresets.Fast, {
                BackgroundColor3 = hoverColor:lerp(Color3.fromRGB(255, 255, 255), 0.1),
                Size = UDim2.new(0, 37, 0, 37)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            createTween(button, AnimationPresets.Fast, {
                BackgroundColor3 = hoverColor,
                Size = UDim2.new(0, 35, 0, 35)
            }):Play()
        end)
        
        button.MouseButton1Down:Connect(function()
            createTween(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 33, 0, 33)}):Play()
        end)
        
        button.MouseButton1Up:Connect(function()
            createTween(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 37, 0, 37)}):Play()
        end)
    end
    
    createButtonHover(self.ThemeBtn, self.CurrentTheme.Accent)
    createButtonHover(self.MinimizeBtn, self.CurrentTheme.Warning)
    createButtonHover(self.CloseBtn, self.CurrentTheme.Error)
    
    -- Button functionality
    self.ThemeBtn.MouseButton1Click:Connect(function()
        self:ToggleThemeSelector()
    end)
    
    self.MinimizeBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
end

function NexusUI:CreateThemeSelector()
    self.ThemeSelector = Instance.new("Frame")
    self.ThemeSelector.Name = "ThemeSelector"
    self.ThemeSelector.Size = UDim2.new(0, 200, 0, 0)
    self.ThemeSelector.Position = UDim2.new(1, -210, 0, 70)
    self.ThemeSelector.BackgroundColor3 = self.CurrentTheme.Secondary
    self.ThemeSelector.BorderSizePixel = 0
    self.ThemeSelector.Visible = false
    self.ThemeSelector.ZIndex = 50
    self.ThemeSelector.Parent = self.GUI
    
    addCorner(self.ThemeSelector, 12)
    addStroke(self.ThemeSelector, self.CurrentTheme.Accent, 2)
    addShadow(self.ThemeSelector, Color3.fromRGB(0, 0, 0), 10, 0.5)
    
    local themeLayout = Instance.new("UIListLayout")
    themeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    themeLayout.Padding = UDim.new(0, 5)
    themeLayout.Parent = self.ThemeSelector
    
    local themePadding = Instance.new("UIPadding")
    themePadding.PaddingAll = UDim.new(0, 10)
    themePadding.Parent = self.ThemeSelector
    
    for themeName, themeData in pairs(Themes) do
        local themeBtn = Instance.new("TextButton")
        themeBtn.Size = UDim2.new(1, 0, 0, 35)
        themeBtn.BackgroundColor3 = themeData.Accent
        themeBtn.BorderSizePixel = 0
        themeBtn.Text = themeData.Name
        themeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        themeBtn.TextScaled = true
        themeBtn.Font = Enum.Font.Gotham
        themeBtn.Parent = self.ThemeSelector
        
        addCorner(themeBtn, 6)
        addGradient(themeBtn, themeData.AccentGradient, 45)
        
        themeBtn.MouseEnter:Connect(function()
            createTween(themeBtn, AnimationPresets.Fast, {Size = UDim2.new(1, -4, 0, 35)}):Play()
        end)
        
        themeBtn.MouseLeave:Connect(function()
            createTween(themeBtn, AnimationPresets.Fast, {Size = UDim2.new(1, 0, 0, 35)}):Play()
        end)
        
        themeBtn.MouseButton1Click:Connect(function()
            self:ChangeTheme(themeName)
            self:ToggleThemeSelector()
            showNotification("Theme Changed", "Switched to " .. themeData.Name .. " theme", 2, "success")
        end)
    end
    
    -- Auto-size the selector
    spawn(function()
        wait()
        self.ThemeSelector.Size = UDim2.new(0, 200, 0, themeLayout.AbsoluteContentSize.Y + 20)
    end)
end

function NexusUI:ToggleThemeSelector()
    local targetSize = self.ThemeSelector.Visible and UDim2.new(0, 200, 0, 0) or 
                      UDim2.new(0, 200, 0, (#Themes * 40) + 30)
    
    if not self.ThemeSelector.Visible then
        self.ThemeSelector.Visible = true
    end
    
    createTween(self.ThemeSelector, AnimationPresets.Medium, {Size = targetSize}):Play()
    
    if self.ThemeSelector.Visible and targetSize.Y.Offset == 0 then
        wait(0.3)
        self.ThemeSelector.Visible = false
    end
end

function NexusUI:ShowKeySystem()
    -- Create blur effect
    self.BlurEffect = createBlur()
    
    -- Create key system UI with premium design
    self.KeyFrame = Instance.new("Frame")
    self.KeyFrame.Name = "KeySystem"
    self.KeyFrame.Size = UDim2.new(0, 450, 0, 350)
    self.KeyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.KeyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.KeyFrame.BackgroundColor3 = self.CurrentTheme.Background
    self.KeyFrame.BorderSizePixel = 0
    self.KeyFrame.Parent = self.GUI
    
    addCorner(self.KeyFrame, 16)
    addStroke(self.KeyFrame, self.CurrentTheme.Accent, 3)
    addShadow(self.KeyFrame, self.CurrentTheme.Shadow, 25, 0.6)
    addGlow(self.KeyFrame, self.CurrentTheme.Accent, 8, 0.8)
    
    -- Animated gradient background
    addGradient(self.KeyFrame, {
        self.CurrentTheme.Background,
        self.CurrentTheme.Secondary:lerp(self.CurrentTheme.Background, 0.7)
    }, 45)
    
    -- Header section
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 80)
    headerFrame.BackgroundColor3 = self.CurrentTheme.Secondary
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = self.KeyFrame
    
    addCorner(headerFrame, 16)
    addGradient(headerFrame, self.CurrentTheme.AccentGradient, 45)
    
    -- Key system icon
    local keyIcon = Instance.new("TextLabel")
    keyIcon.Size = UDim2.new(0, 60, 0, 60)
    keyIcon.Position = UDim2.new(0, 30, 0.5, -30)
    keyIcon.BackgroundTransparency = 1
    keyIcon.Text = "🔐"
    keyIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyIcon.TextScaled = true
    keyIcon.Font = Enum.Font.GothamBold
    keyIcon.Parent = headerFrame
    
    -- Rotating animation for icon
    spawn(function()
        while self.KeyFrame.Parent do
            createTween(keyIcon, TweenInfo.new(2, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
            wait(2)
            keyIcon.Rotation = 0
        end
    end)
    
    -- Key system title
    local keyTitle = Instance.new("TextLabel")
    keyTitle.Size = UDim2.new(1, -120, 0, 35)
    keyTitle.Position = UDim2.new(0, 100, 0, 15)
    keyTitle.BackgroundTransparency = 1
    keyTitle.Text = "Premium Key System"
    keyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyTitle.TextScaled = true
    keyTitle.Font = Enum.Font.GothamBold
    keyTitle.TextXAlignment = Enum.TextXAlignment.Left
    keyTitle.Parent = headerFrame
    
    -- Subtitle
    local keySubtitle = Instance.new("TextLabel")
    keySubtitle.Size = UDim2.new(1, -120, 0, 25)
    keySubtitle.Position = UDim2.new(0, 100, 0, 45)
    keySubtitle.BackgroundTransparency = 1
    keySubtitle.Text = "Enter your premium access key"
    keySubtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    keySubtitle.TextTransparency = 0.3
    keySubtitle.TextScaled = true
    keySubtitle.Font = Enum.Font.Gotham
    keySubtitle.TextXAlignment = Enum.TextXAlignment.Left
    keySubtitle.Parent = headerFrame
    
    -- Key input section
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -60, 0, 50)
    inputFrame.Position = UDim2.new(0, 30, 0, 120)
    inputFrame.BackgroundColor3 = self.CurrentTheme.Secondary
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = self.KeyFrame
    
    addCorner(inputFrame, 12)
    addStroke(inputFrame, self.CurrentTheme.Accent, 2)
    
    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(1, -20, 1, -10)
    keyInput.Position = UDim2.new(0, 10, 0, 5)
    keyInput.BackgroundTransparency = 1
    keyInput.PlaceholderText = "Enter your key here..."
    keyInput.PlaceholderColor3 = self.CurrentTheme.TextDim
    keyInput.Text = ""
    keyInput.TextColor3 = self.CurrentTheme.Text
    keyInput.TextScaled = true
    keyInput.Font = Enum.Font.Gotham
    keyInput.TextXAlignment = Enum.TextXAlignment.Left
    keyInput.Parent = inputFrame
    
    -- Submit button with premium design
    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(1, -60, 0, 45)
    submitBtn.Position = UDim2.new(0, 30, 0, 190)
    submitBtn.BackgroundColor3 = self.CurrentTheme.Accent
    submitBtn.BorderSizePixel = 0
    submitBtn.Text = "🚀 Verify Key"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.TextScaled = true
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.Parent = self.KeyFrame
    
    addCorner(submitBtn, 12)
    addGradient(submitBtn, self.CurrentTheme.AccentGradient, 45)
    addGlow(submitBtn, self.CurrentTheme.Accent, 5, 0.7)
    
    -- Get key button
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(1, -60, 0, 40)
    getKeyBtn.Position = UDim2.new(0, 30, 0, 250)
    getKeyBtn.BackgroundColor3 = self.CurrentTheme.Secondary
    getKeyBtn.BorderSizePixel = 0
    getKeyBtn.Text = "🔗 Get Key"
    getKeyBtn.TextColor3 = self.CurrentTheme.Accent
    getKeyBtn.TextScaled = true
    getKeyBtn.Font = Enum.Font.Gotham
    getKeyBtn.Parent = self.KeyFrame
    
    addCorner(getKeyBtn, 10)
    addStroke(getKeyBtn, self.CurrentTheme.Accent, 2)
    
    -- Enhanced button animations
    submitBtn.MouseEnter:Connect(function()
        createTween(submitBtn, AnimationPresets.Fast, {
            Size = UDim2.new(1, -56, 0, 45),
            BackgroundTransparency = 0.1
        }):Play()
    end)
    
    submitBtn.MouseLeave:Connect(function()
        createTween(submitBtn, AnimationPresets.Fast, {
            Size = UDim2.new(1, -60, 0, 45),
            BackgroundTransparency = 0
        }):Play()
    end)
    
    getKeyBtn.MouseEnter:Connect(function()
        createTween(getKeyBtn, AnimationPresets.Fast, {
            BackgroundColor3 = self.CurrentTheme.Accent:lerp(self.CurrentTheme.Secondary, 0.8)
        }):Play()
    end)
    
    getKeyBtn.MouseLeave:Connect(function()
        createTween(getKeyBtn, AnimationPresets.Fast, {
            BackgroundColor3 = self.CurrentTheme.Secondary
        }):Play()
    end)
    
    -- Error shake animation
    local function shakeError()
        local originalPos = inputFrame.Position
        for i = 1, 6 do
            createTween(inputFrame, TweenInfo.new(0.05), {Position = originalPos + UDim2.new(0, math.random(-5, 5), 0, 0)}):Play()
            wait(0.05)
        end
        createTween(inputFrame, TweenInfo.new(0.1), {Position = originalPos}):Play()
        
        -- Flash error color
        createTween(inputFrame, TweenInfo.new(0.1), {BackgroundColor3 = self.CurrentTheme.Error}):Play()
        wait(0.1)
        createTween(inputFrame, TweenInfo.new(0.3), {BackgroundColor3 = self.CurrentTheme.Secondary}):Play()
    end
    
    -- Button functionality
    submitBtn.MouseButton1Click:Connect(function()
        local enteredKey = keyInput.Text
        if self.KeySystem.ValidateKey then
            if self.KeySystem.ValidateKey(enteredKey) then
                showNotification("Access Granted", "Key verified successfully! Loading interface...", 3, "success")
                self:ShowMainUI()
                removeBlur(self.BlurEffect)
                self.KeyFrame:Destroy()
            else
                shakeError()
                showNotification("Access Denied", "Invalid key! Please try again.", 3, "error")
            end
        end
    end)
    
    getKeyBtn.MouseButton1Click:Connect(function()
        if self.KeySystem.KeyURL then
            if setclipboard then
                setclipboard(self.KeySystem.KeyURL)
                showNotification("Link Copied", "Key link copied to clipboard!", 3, "success")
            else
                showNotification("Get Key", "Visit: " .. self.KeySystem.KeyURL, 5, "info")
            end
        end
    end)
    
    -- Entrance animation
    self.KeyFrame.Size = UDim2.new(0, 0, 0, 0)
    createTween(self.KeyFrame, AnimationPresets.Elastic, {Size = UDim2.new(0, 450, 0, 350)}):Play()
    
    -- Hide main UI initially
    self.Main.Visible = false
end

function NexusUI:ShowMainUI()
    self.Main.Visible = true
    
    -- Epic entrance animation
    self.Main.Size = UDim2.new(0, 0, 0, 0)
    self.Main.Rotation = 180
    self.Main.BackgroundTransparency = 1
    
    local entranceTween = createTween(self.Main, AnimationPresets.Elastic, {
        Size = self.Size,
        Rotation = 0,
        BackgroundTransparency = 0
    })
    entranceTween:Play()
    
    -- Cascade animation for child elements
    spawn(function()
        wait(0.3)
        for i, child in ipairs(self.Main:GetChildren()) do
            if child:IsA("GuiObject") and child ~= self.TitleBar then
                child.BackgroundTransparency = 1
                createTween(child, AnimationPresets.Fast, {BackgroundTransparency = 0}):Play()
                wait(0.1)
            end
        end
    end)
end

function NexusUI:CreateTab(options)
    options = options or {}
    local tab = {}
    
    tab.Name = options.Name or "Tab"
    tab.Icon = options.Icon or "📋"
    tab.Active = false
    tab.Order = #self.Tabs + 1
    
    -- Tab button with premium design
    tab.Button = Instance.new("TextButton")
    tab.Button.Name = tab.Name .. "_Button"
    tab.Button.LayoutOrder = tab.Order
    tab.Button.Size = UDim2.new(1, 0, 0, isMobile() and 50 or 45)
    tab.Button.BackgroundColor3 = self.CurrentTheme.Secondary
    tab.Button.BorderSizePixel = 0
    tab.Button.Text = ""
    tab.Button.Parent = self.TabButtons
    
    addCorner(tab.Button, 10)
    
    -- Tab button content frame
    local buttonContent = Instance.new("Frame")
    buttonContent.Size = UDim2.new(1, 0, 1, 0)
    buttonContent.BackgroundTransparency = 1
    buttonContent.Parent = tab.Button
    
    -- Tab icon
    local tabIcon = Instance.new("TextLabel")
    tabIcon.Size = UDim2.new(0, isMobile() and 30 or 25, 0, isMobile() and 30 or 25)
    tabIcon.Position = UDim2.new(0, 12, 0.5, isMobile() and -15 or -12.5)
    tabIcon.BackgroundTransparency = 1
    tabIcon.Text = tab.Icon
    tabIcon.TextColor3 = self.CurrentTheme.TextDim
    tabIcon.TextScaled = true
    tabIcon.Font = Enum.Font.GothamBold
    tabIcon.Parent = buttonContent
    
    -- Tab label
    local tabLabel = Instance.new("TextLabel")
    if isMobile() then
        tabLabel.Size = UDim2.new(1, -50, 0, 20)
        tabLabel.Position = UDim2.new(0, 12, 1, -25)
    else
        tabLabel.Size = UDim2.new(1, -50, 1, 0)
        tabLabel.Position = UDim2.new(0, 45, 0, 0)
    end
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = tab.Name
    tabLabel.TextColor3 = self.CurrentTheme.TextDim
    tabLabel.TextScaled = true
    tabLabel.Font = Enum.Font.Gotham
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.Parent = buttonContent
    
    -- Tab content frame with scroll
    tab.Content = Instance.new("ScrollingFrame")
    tab.Content.Name = tab.Name .. "_Content"
    tab.Content.Size = UDim2.new(1, -20, 1, -20)
    tab.Content.Position = UDim2.new(0, 10, 0, 10)
    tab.Content.BackgroundTransparency = 1
    tab.Content.BorderSizePixel = 0
    tab.Content.ScrollBarThickness = 6
    tab.Content.ScrollBarImageColor3 = self.CurrentTheme.Accent
    tab.Content.ScrollBarImageTransparency = 0.5
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.Content.Visible = false
    tab.Content.Parent = self.TabContent
    
    -- Content layout
    tab.Layout = Instance.new("UIListLayout")
    tab.Layout.SortOrder = Enum.SortOrder.LayoutOrder
    tab.Layout.FillDirection = Enum.FillDirection.Vertical
    tab.Layout.Padding = UDim.new(0, 12)
    tab.Layout.Parent = tab.Content
    
    -- Auto-resize canvas with animation
    tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        createTween(tab.Content, AnimationPresets.Fast, {
            CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y + 30)
        }):Play()
    end)
    
    -- Enhanced tab button animations
    tab.Button.MouseEnter:Connect(function()
        if not tab.Active then
            createTween(tab.Button, AnimationPresets.Fast, {
                BackgroundColor3 = self.CurrentTheme.Accent:lerp(self.CurrentTheme.Secondary, 0.8),
                Size = UDim2.new(1, -4, 0, tab.Button.Size.Y.Offset)
            }):Play()
            createTween(tabIcon, AnimationPresets.Fast, {Rotation = 10}):Play()
        end
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if not tab.Active then
            createTween(tab.Button, AnimationPresets.Fast, {
                BackgroundColor3 = self.CurrentTheme.Secondary,
                Size = UDim2.new(1, 0, 0, tab.Button.Size.Y.Offset)
            }):Play()
            createTween(tabIcon, AnimationPresets.Fast, {Rotation = 0}):Play()
        end
    end)
    
    tab.Button.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    -- Store references
    tab.Icon_Object = tabIcon
    tab.Label_Object = tabLabel
    
    table.insert(self.Tabs, tab)
    
    -- Activate first tab
    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end
    
    return tab
end

function NexusUI:SwitchTab(targetTab)
    -- Deactivate all tabs with animation
    for _, tab in pairs(self.Tabs) do
        if tab.Active then
            -- Slide out animation
            createTween(tab.Content, AnimationPresets.Fast, {
                Position = UDim2.new(-1, 10, 0, 10)
            }):Play()
            
            wait(0.1)
            tab.Content.Visible = false
            tab.Content.Position = UDim2.new(1, 10, 0, 10)
        end
        
        tab.Active = false
        createTween(tab.Button, AnimationPresets.Medium, {
            BackgroundColor3 = self.CurrentTheme.Secondary,
            Size = UDim2.new(1, 0, 0, tab.Button.Size.Y.Offset)
        }):Play()
        createTween(tab.Icon_Object, AnimationPresets.Medium, {
            TextColor3 = self.CurrentTheme.TextDim,
            Rotation = 0
        }):Play()
        createTween(tab.Label_Object, AnimationPresets.Medium, {
            TextColor3 = self.CurrentTheme.TextDim
        }):Play()
    end
    
    -- Activate target tab
    targetTab.Active = true
    self.ActiveTab = targetTab
    
    createTween(targetTab.Button, AnimationPresets.Medium, {
        BackgroundColor3 = self.CurrentTheme.Accent,
        Size = UDim2.new(1, -6, 0, targetTab.Button.Size.Y.Offset)
    }):Play()
    
    -- Add gradient to active tab
    addGradient(targetTab.Button, self.CurrentTheme.AccentGradient, 45)
    addGlow(targetTab.Button, self.CurrentTheme.Accent, 2, 0.9)
    
    createTween(targetTab.Icon_Object, AnimationPresets.Medium, {
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Rotation = 360
    }):Play()
    createTween(targetTab.Label_Object, AnimationPresets.Medium, {
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    -- Slide in animation
    spawn(function()
        wait(0.2)
        targetTab.Content.Visible = true
        createTween(targetTab.Content, AnimationPresets.Medium, {
            Position = UDim2.new(0, 10, 0, 10)
        }):Play()
    end)
end

-- Enhanced UI Elements with Premium Design

function NexusUI:CreateButton(tab, options)
    options = options or {}
    
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = options.Name or "Button"
    buttonFrame.Size = UDim2.new(1, 0, 0, isMobile() and 50 or 45)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = tab.Content
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = self.CurrentTheme.Accent
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = buttonFrame
    
    addCorner(button, 12)
    addGradient(button, self.CurrentTheme.AccentGradient, 45)
    addGlow(button, self.CurrentTheme.Accent, 4, 0.8)
    
    -- Button content
    local buttonIcon = Instance.new("TextLabel")
    buttonIcon.Size = UDim2.new(0, 30, 0, 30)
    buttonIcon.Position = UDim2.new(0, 15, 0.5, -15)
    buttonIcon.BackgroundTransparency = 1
    buttonIcon.Text = options.Icon or "🚀"
    buttonIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    buttonIcon.TextScaled = true
    buttonIcon.Font = Enum.Font.GothamBold
    buttonIcon.Parent = button
    
    local buttonText = Instance.new("TextLabel")
    buttonText.Size = UDim2.new(1, -60, 1, 0)
    buttonText.Position = UDim2.new(0, 50, 0, 0)
    buttonText.BackgroundTransparency = 1
    buttonText.Text = options.Text or "Button"
    buttonText.TextColor3 = Color3.fromRGB(255, 255, 255)
    buttonText.TextScaled = true
    buttonText.Font = Enum.Font.GothamBold
    buttonText.TextXAlignment = Enum.TextXAlignment.Left
    buttonText.Parent = button
    
    -- Enhanced click animation
    button.MouseEnter:Connect(function()
        createTween(button, AnimationPresets.Fast, {
            Size = UDim2.new(1, -4, 1, -2),
            BackgroundTransparency = 0.1
        }):Play()
        createTween(buttonIcon, AnimationPresets.Fast, {Rotation = 15}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        createTween(button, AnimationPresets.Fast, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 0
        }):Play()
        createTween(buttonIcon, AnimationPresets.Fast, {Rotation = 0}):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        createTween(button, TweenInfo.new(0.1), {Size = UDim2.new(1, -8, 1, -4)}):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        createTween(button, AnimationPresets.Bounce, {Size = UDim2.new(1, -4, 1, -2)}):Play()
        
        if options.Callback then
            spawn(options.Callback)
        end
    end)
    
    return buttonFrame
end

function NexusUI:CreateToggle(tab, options)
    options = options or {}
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = options.Name or "Toggle"
    toggleFrame.Size = UDim2.new(1, 0, 0, isMobile() and 55 or 50)
    toggleFrame.BackgroundColor3 = self.CurrentTheme.Secondary
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = tab.Content
    
    addCorner(toggleFrame, 12)
    addStroke(toggleFrame, self.CurrentTheme.Accent, 2, 0.3)
    
    -- Toggle icon
    local toggleIcon = Instance.new("TextLabel")
    toggleIcon.Size = UDim2.new(0, 30, 0, 30)
    toggleIcon.Position = UDim2.new(0, 15, 0.5, -15)
    toggleIcon.BackgroundTransparency = 1
    toggleIcon.Text = options.Icon or "⚡"
    toggleIcon.TextColor3 = self.CurrentTheme.Accent
    toggleIcon.TextScaled = true
    toggleIcon.Font = Enum.Font.GothamBold
    toggleIcon.Parent = toggleFrame
    
    -- Toggle label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -120, 0, 25)
    label.Position = UDim2.new(0, 55, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = options.Text or "Toggle"
    label.TextColor3 = self.CurrentTheme.Text
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    -- Toggle description
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, -120, 0, 15)
    description.Position = UDim2.new(0, 55, 0, 28)
    description.BackgroundTransparency = 1
    description.Text = options.Description or "Toggle this feature on/off"
    description.TextColor3 = self.CurrentTheme.TextDim
    description.TextScaled = true
    description.Font = Enum.Font.Gotham
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Parent = toggleFrame
    
    -- Premium toggle switch
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 60, 0, 30)
    toggle.Position = UDim2.new(1, -75, 0.5, -15)
    toggle.BackgroundColor3 = self.CurrentTheme.TextDim
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.Parent = toggleFrame
    
    addCorner(toggle, 15)
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 24, 0, 24)
    indicator.Position = UDim2.new(0, 3, 0.5, -12)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    indicator.BorderSizePixel = 0
    indicator.Parent = toggle
    
    addCorner(indicator, 12)
    addShadow(indicator, Color3.fromRGB(0, 0, 0), 3, 0.3)
    
    local state = options.Default or false
    
    local function updateToggle()
        if state then
            createTween(toggle, AnimationPresets.Medium, {BackgroundColor3 = self.CurrentTheme.Accent}):Play()
            createTween(indicator, AnimationPresets.Medium, {Position = UDim2.new(1, -27, 0.5, -12)}):Play()
            createTween(toggleIcon, AnimationPresets.Medium, {
                TextColor3 = self.CurrentTheme.Accent,
                Rotation = 360
            }):Play()
            
            -- Add glow effect
            addGlow(toggle, self.CurrentTheme.Accent, 3, 0.8)
        else
            createTween(toggle, AnimationPresets.Medium, {BackgroundColor3 = self.CurrentTheme.TextDim}):Play()
            createTween(indicator, AnimationPresets.Medium, {Position = UDim2.new(0, 3, 0.5, -12)}):Play()
            createTween(toggleIcon, AnimationPresets.Medium, {
                TextColor3 = self.CurrentTheme.TextDim,
                Rotation = 0
            }):Play()
        end
        
        if options.Callback then
            spawn(function() options.Callback(state) end)
        end
    end
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        
        -- Haptic feedback simulation
        createTween(toggleFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, -4, 0, toggleFrame.Size.Y.Offset)}):Play()
        wait
