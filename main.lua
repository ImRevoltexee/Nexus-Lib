-- NovaUI v1.0 - Premium Roblox UI Library
-- Author: you + me :)
-- Goals: colourful, polished, PC+Mobile, minimize+floating, hotkey+mobile toggle, key UI, modular API.
-- No external assets to avoid "failed to load" issues.

local NovaUI = {}
NovaUI.__index = NovaUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ========= THEME TOKENS =========
local THEMES = {
    Dark = {
        Bg = Color3.fromRGB(18,18,24),
        Panel = Color3.fromRGB(26,27,35),
        Muted = Color3.fromRGB(36,37,48),
        Accent = Color3.fromRGB(120, 90, 255),
        Accent2 = Color3.fromRGB(255, 90, 170),
        Text = Color3.fromRGB(245,245,255),
        TextDim = Color3.fromRGB(170,175,190),
        Success = Color3.fromRGB(75, 200, 130),
        Warn = Color3.fromRGB(255, 180, 70),
        Error = Color3.fromRGB(255, 95, 95)
    },
    Colorful = {
        Bg = Color3.fromRGB(16,20,32),
        Panel = Color3.fromRGB(26,30,46),
        Muted = Color3.fromRGB(34,38,60),
        Accent = Color3.fromRGB(0, 200, 255),
        Accent2 = Color3.fromRGB(255, 0, 200),
        Text = Color3.fromRGB(255,255,255),
        TextDim = Color3.fromRGB(195,200,215),
        Success = Color3.fromRGB(100, 255, 170),
        Warn = Color3.fromRGB(255, 210, 90),
        Error = Color3.fromRGB(255, 110, 110)
    },
    Minimal = {
        Bg = Color3.fromRGB(246,247,252),
        Panel = Color3.fromRGB(255,255,255),
        Muted = Color3.fromRGB(235,238,245),
        Accent = Color3.fromRGB(70,120,255),
        Accent2 = Color3.fromRGB(120,70,255),
        Text = Color3.fromRGB(45,48,60),
        TextDim = Color3.fromRGB(115,120,140),
        Success = Color3.fromRGB(50, 185, 120),
        Warn = Color3.fromRGB(255, 165, 70),
        Error = Color3.fromRGB(240, 80, 80)
    },
    Futuristic = {
        Bg = Color3.fromRGB(8,12,20),
        Panel = Color3.fromRGB(14,18,28),
        Muted = Color3.fromRGB(20,26,40),
        Accent = Color3.fromRGB(0, 255, 190),
        Accent2 = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(230,255,245),
        TextDim = Color3.fromRGB(150, 220, 210),
        Success = Color3.fromRGB(0, 240, 160),
        Warn = Color3.fromRGB(255, 210, 0),
        Error = Color3.fromRGB(255, 95, 140)
    }
}

-- ========= UTIL =========
local function corner(parent, r)
    local ui = Instance.new("UICorner")
    ui.CornerRadius = UDim.new(0, r or 10)
    ui.Parent = parent
    return ui
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.2
    s.Parent = parent
    return s
end

local function padding(parent, l,t,r,b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = parent
    return p
end

local function tween(obj, ti, goal)
    return TweenService:Create(obj, ti, goal)
end

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- manage components for live theme change
local function registry()
    local tbl = {}
    function tbl:add(inst, prop, tokenName) -- tokenName refers to a key in theme (e.g. "Panel", "Text", "Accent")
        table.insert(self, {inst=inst, prop=prop, token=tokenName})
    end
    function tbl:apply(theme)
        for _,v in ipairs(self) do
            if v.inst and v.inst.Parent then
                v.inst[v.prop] = theme[v.token]
            end
        end
    end
    return tbl
end

-- ========= CONSTRUCTOR =========
function NovaUI.new(opts)
    opts = opts or {}
    local self = setmetatable({}, NovaUI)

    self._themeName = opts.Theme or "Colorful"
    self.Theme = THEMES[self._themeName] or THEMES.Colorful
    self.Title = opts.Title or "NovaUI"
    self.ToggleKey = opts.ToggleKey or Enum.KeyCode.RightControl
    self._components = registry()
    self._tabs = {}
    self._minimized = false

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "NovaUI_" .. math.random(1000,9999)
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    self.Gui = gui

    -- Root container + autoscale
    local root = Instance.new("Frame", gui)
    root.Name = "Root"
    root.AnchorPoint = Vector2.new(0.5,0.5)
    root.Position = UDim2.new(0.5,0,0.5,0)
    root.Size = UDim2.new(0, math.clamp(isMobile() and 420 or 560, 380, 640), 0, math.clamp(isMobile() and 520 or 620, 420, 720))
    root.BackgroundColor3 = self.Theme.Bg
    root.BorderSizePixel = 0
    corner(root, 14)
    stroke(root, self.Theme.Accent, 1, .6)
    self._components:add(root, "BackgroundColor3", "Bg")
    self.Root = root

    -- soft shadow (no external asset)
    local shadow = Instance.new("Frame", root)
    shadow.ZIndex = 0
    shadow.BackgroundColor3 = Color3.new(0,0,0)
    shadow.BackgroundTransparency = 0.75
    shadow.Size = UDim2.new(1,20,1,20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    corner(shadow, 18)

    -- TopBar
    local bar = Instance.new("Frame", root)
    bar.Name = "TopBar"
    bar.Size = UDim2.new(1,0,0,46)
    bar.BackgroundColor3 = self.Theme.Muted
    bar.BorderSizePixel = 0
    corner(bar, 14)
    self._components:add(bar, "BackgroundColor3", "Muted")

    local title = Instance.new("TextLabel", bar)
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0,14,0,0)
    title.Size = UDim2.new(1,-130,1,0)
    title.Font = Enum.Font.GothamSemibold
    title.TextScaled = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = self.Title
    title.TextColor3 = self.Theme.Text
    self._components:add(title, "TextColor3", "Text")

    -- topbar buttons (minimize / close / settings placeholder)
    local btnHolder = Instance.new("Frame", bar)
    btnHolder.BackgroundTransparency = 1
    btnHolder.Size = UDim2.new(0,120,1,0)
    btnHolder.Position = UDim2.new(1,-120,0,0)

    local function pillButton(txt, color)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,34,0,28)
        b.Position = UDim2.new(0,0,0.5,-14)
        b.BackgroundColor3 = color
        b.Text = txt
        b.TextScaled = true
        b.Font = Enum.Font.GothamBold
        b.TextColor3 = Color3.new(1,1,1)
        b.AutoButtonColor = false
        corner(b, 8)
        stroke(b, Color3.new(0,0,0), 1, .85)
        return b
    end

    local minimize = pillButton("–", self.Theme.Warn); minimize.Parent = btnHolder
    self._components:add(minimize, "BackgroundColor3", "Warn")
    local close = pillButton("×", self.Theme.Error); close.Position = UDim2.new(0,40,0.5,-14); close.Parent = btnHolder
    self._components:add(close, "BackgroundColor3", "Error")

    -- Tab strip
    local tabs = Instance.new("Frame", root)
    tabs.Name = "Tabs"
    tabs.BackgroundColor3 = self.Theme.Panel
    tabs.BorderSizePixel = 0
    tabs.Position = UDim2.new(0,0,0,46)
    tabs.Size = UDim2.new(0,148,1,-46)
    corner(tabs, 14)
    self._components:add(tabs, "BackgroundColor3", "Panel")

    local tabList = Instance.new("UIListLayout", tabs)
    tabList.Padding = UDim.new(0,6)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    padding(tabs, 8,10,8,10)

    -- Content area
    local content = Instance.new("Frame", root)
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0,156,0,56)
    content.Size = UDim2.new(1,-166,1,-66)

    -- Floating button (for minimized state)
    local floatBtn = Instance.new("TextButton", gui)
    floatBtn.Visible = false
    floatBtn.Size = UDim2.new(0,56,0,56)
    floatBtn.Position = UDim2.new(0,20,1,-76)
    floatBtn.BackgroundColor3 = self.Theme.Accent
    floatBtn.TextColor3 = Color3.new(1,1,1)
    floatBtn.Text = "☰"
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextScaled = true
    floatBtn.AutoButtonColor = false
    corner(floatBtn, 28)
    stroke(floatBtn, Color3.new(0,0,0), 1, .7)
    self._components:add(floatBtn, "BackgroundColor3", "Accent")
    self.FloatBtn = floatBtn

    -- Drag to move (bar)
    local dragging, dragStart, startPos = false, nil, nil
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = root.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Button behaviors
    minimize.MouseButton1Click:Connect(function()
        self:_setMinimized(true)
    end)
    floatBtn.MouseButton1Click:Connect(function()
        self:_setMinimized(false)
    end)
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Toggle (keyboard + mobile quick button at right)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.ToggleKey then
            gui.Enabled = not gui.Enabled
        end
    end)

    -- Mobile quick toggle bubble (right side)
    if isMobile() then
        local bubble = Instance.new("TextButton", gui)
        bubble.Size = UDim2.new(0,48,0,48)
        bubble.Position = UDim2.new(1,-64,1,-64)
        bubble.Text = "↔"
        bubble.TextScaled = true
        bubble.BackgroundColor3 = self.Theme.Accent2
        bubble.TextColor3 = Color3.new(1,1,1)
        bubble.AutoButtonColor = false
        corner(bubble, 24)
        stroke(bubble, Color3.new(0,0,0), 1, .7)
        self._components:add(bubble, "BackgroundColor3", "Accent2")
        bubble.MouseButton1Click:Connect(function()
            gui.Enabled = not gui.Enabled
        end)
    end

    -- store
    self.TabsFrame = tabs
    self.ContentFrame = content

    -- Key System (optional)
    if opts.KeySystem and opts.KeySystem.Enabled then
        self:_showKeyUI(opts.KeySystem)
        root.Visible = false
    end

    return self
end

-- ========= INTERNAL =========
function NovaUI:_setMinimized(state)
    if self._minimized == state then return end
    self._minimized = state
    if state then
        tween(self.Root, TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
        task.delay(.25, function()
            self.Root.Visible = false
            self.FloatBtn.Visible = true
            self.FloatBtn.Size = UDim2.new(0,0,0,0)
            tween(self.FloatBtn, TweenInfo.new(.25, Enum.EasingStyle.Back), {Size = UDim2.new(0,56,0,56)}):Play()
        end)
    else
        self.FloatBtn.Visible = false
        self.Root.Visible = true
        self.Root.Size = UDim2.new(0,0,0,0)
        tween(self.Root, TweenInfo.new(.25, Enum.EasingStyle.Back), {Size = UDim2.new(0, math.clamp(isMobile() and 420 or 560, 380, 640), 0, math.clamp(isMobile() and 520 or 620, 420, 720))}):Play()
    end
end

function NovaUI:_showKeyUI(cfg)
    -- cfg: {Prompt="...", Verify=function(key)->bool, GetKey=function()end}
    local overlay = Instance.new("Frame", self.Gui)
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3 = Color3.new(0,0,0)
    overlay.BackgroundTransparency = 0.35

    local card = Instance.new("Frame", overlay)
    card.Size = UDim2.new(0, 420, 0, 260)
    card.AnchorPoint = Vector2.new(0.5,0.5)
    card.Position = UDim2.new(0.5,0,0.5,0)
    card.BackgroundColor3 = self.Theme.Panel
    corner(card, 14); stroke(card, self.Theme.Accent, 1, .5)
    self._components:add(card, "BackgroundColor3", "Panel")

    local head = Instance.new("Frame", card)
    head.Size = UDim2.new(1,0,0,52)
    head.BackgroundColor3 = self.Theme.Muted
    corner(head, 14)
    self._components:add(head, "BackgroundColor3", "Muted")

    local title = Instance.new("TextLabel", head)
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1,-20,1,0)
    title.Position = UDim2.new(0,10,0,0)
    title.Text = "🔐 Access Key Required"
    title.TextColor3 = self.Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    self._components:add(title, "TextColor3", "Text")

    local msg = Instance.new("TextLabel", card)
    msg.BackgroundTransparency = 1
    msg.Position = UDim2.new(0,16,0,70)
    msg.Size = UDim2.new(1,-32,0,40)
    msg.Text = (cfg.Prompt or "Enter your key to continue")
    msg.Font = Enum.Font.Gotham
    msg.TextScaled = true
    msg.TextColor3 = self.Theme.TextDim
    self._components:add(msg, "TextColor3", "TextDim")

    local box = Instance.new("TextBox", card)
    box.Size = UDim2.new(1,-32,0,40)
    box.Position = UDim2.new(0,16,0,120)
    box.PlaceholderText = "Paste key here..."
    box.Text = ""
    box.ClearTextOnFocus = false
    box.TextScaled = true
    box.Font = Enum.Font.Gotham
    box.TextColor3 = self.Theme.Text
    box.BackgroundColor3 = self.Theme.Muted
    corner(box, 10); stroke(box, self.Theme.Accent, 1, .4)
    self._components:add(box, "BackgroundColor3", "Muted")
    self._components:add(box, "TextColor3", "Text")

    local line = Instance.new("Frame", card)
    line.BackgroundColor3 = self.Theme.Accent
    line.Size = UDim2.new(1,-32,0,2)
    line.Position = UDim2.new(0,16,0,162)
    self._components:add(line, "BackgroundColor3", "Accent")

    local verify = Instance.new("TextButton", card)
    verify.Size = UDim2.new(1,-32,0,40)
    verify.Position = UDim2.new(0,16,0,180)
    verify.Text = "Verify Key"
    verify.TextScaled = true
    verify.Font = Enum.Font.GothamBold
    verify.TextColor3 = Color3.new(1,1,1)
    verify.BackgroundColor3 = self.Theme.Accent
    corner(verify, 10)
    self._components:add(verify, "BackgroundColor3", "Accent")

    local getkey = Instance.new("TextButton", card)
    getkey.Size = UDim2.new(0,120,0,32)
    getkey.Position = UDim2.new(1,-136,0,70)
    getkey.Text = "Get Key"
    getkey.TextScaled = true
    getkey.Font = Enum.Font.Gotham
    getkey.TextColor3 = self.Theme.Accent2
    getkey.BackgroundColor3 = self.Theme.Panel
    corner(getkey, 8); stroke(getkey, self.Theme.Accent2, 1, .4)
    self._components:add(getkey, "TextColor3", "Accent2")
    self._components:add(getkey, "BackgroundColor3", "Panel")

    verify.MouseButton1Click:Connect(function()
        local ok = (typeof(cfg.Verify)=="function") and cfg.Verify(box.Text)
        if ok then
            tween(card, TweenInfo.new(.25), {Size = UDim2.new(0,0,0,0)}):Play()
            task.delay(.25, function()
                overlay:Destroy()
                self.Root.Visible = true
            end)
        else
            -- shake + color flash
            tween(box, TweenInfo.new(.08), {BackgroundColor3 = self.Theme.Error}):Play()
            task.delay(.12, function()
                tween(box, TweenInfo.new(.15), {BackgroundColor3 = self.Theme.Muted}):Play()
            end)
        end
    end)

    getkey.MouseButton1Click:Connect(function()
        if typeof(cfg.GetKey) == "function" then
            pcall(cfg.GetKey)
        end
    end)
end

-- ========= PUBLIC API =========

function NovaUI:ChangeTheme(name)
    if THEMES[name] then
        self._themeName = name
        self.Theme = THEMES[name]
        self._components:apply(self.Theme)
    end
end

-- Tabs / Sections / Controls

function NovaUI:CreateTab(cfg)
    cfg = typeof(cfg)=="table" and cfg or {Name = tostring(cfg)}
    local name = cfg.Name or "Tab"

    local btn = Instance.new("TextButton", self.TabsFrame)
    btn.Size = UDim2.new(1,0,0,36)
    btn.Text = name
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = self.Theme.Text
    btn.BackgroundColor3 = self.Theme.Panel
    btn.AutoButtonColor = false
    corner(btn, 10)
    stroke(btn, self.Theme.Muted, 1, .6)
    self._components:add(btn, "BackgroundColor3", "Panel")
    self._components:add(btn, "TextColor3", "Text")

    local page = Instance.new("ScrollingFrame", self.ContentFrame)
    page.Visible = false
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 6
    page.CanvasSize = UDim2.new(0,0,0,0)

    local list = Instance.new("UIListLayout", page)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0,10)
    padding(page, 10, 8, 10, 12)
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y + 20)
    end)

    btn.MouseButton1Click:Connect(function()
        for _,t in ipairs(self._tabs) do
            t.Button.BackgroundColor3 = self.Theme.Panel
            t.Page.Visible = false
        end
        page.Visible = true
        tween(btn, TweenInfo.new(.18), {BackgroundColor3 = self.Theme.Accent}):Play()
    end)

    local tabObj = {Button = btn, Page = page}
    table.insert(self._tabs, tabObj)
    -- activate first
    if #self._tabs == 1 then
        page.Visible = true
        btn.BackgroundColor3 = self.Theme.Accent
    end

    -- section factory
    function tabObj:AddSection(title)
        local holder = Instance.new("Frame", page)
        holder.Size = UDim2.new(1,0,0,40)
        holder.BackgroundColor3 = self.Theme.Muted
        corner(holder, 12); stroke(holder, self.Theme.Accent, 1, .6)
        selfRef._components:add(holder, "BackgroundColor3", "Muted") -- delayed selfRef assign below

        local lbl = Instance.new("TextLabel", holder)
        lbl.BackgroundTransparency = 1
        lbl.Position = UDim2.new(0,12,0,0)
        lbl.Size = UDim2.new(1,-24,1,0)
        lbl.Text = title or "Section"
        lbl.Font = Enum.Font.GothamBold
        lbl.TextScaled = true
        lbl.TextColor3 = Nova.Theme.Text -- will be rebind
        return {
            _root = holder,
            _label = lbl,
            AddButton = function(selfCtrl, cfg2)
                local b = Instance.new("TextButton", page)
                b.Size = UDim2.new(1,0,0,36)
                b.Text = cfg2.Text or "Button"
                b.Font = Enum.Font.GothamBold
                b.TextScaled = true
                b.TextColor3 = Color3.new(1,1,1)
                b.BackgroundColor3 = Nova.Theme.Accent
                corner(b, 10)
                if cfg2.Callback then
                    b.MouseButton1Click:Connect(function()
                        pcall(cfg2.Callback)
                    end)
                end
                return b
            end
        }
    end

    -- bind proper theme refs for section helpers
    local selfRef = self
    local Nova = {Theme = self.Theme}
    tabObj.AddSection = function(_, title)
        local holder = Instance.new("Frame", page)
        holder.Size = UDim2.new(1,0,0,40)
        holder.BackgroundColor3 = self.Theme.Muted
        corner(holder, 12); stroke(holder, self.Theme.Accent, 1, .5)
        self._components:add(holder, "BackgroundColor3", "Muted")

        local lbl = Instance.new("TextLabel", holder)
        lbl.BackgroundTransparency = 1
        lbl.Position = UDim2.new(0,12,0,0)
        lbl.Size = UDim2.new(1,-24,1,0)
        lbl.Text = title or "Section"
        lbl.Font = Enum.Font.GothamBold
        lbl.TextScaled = true
        lbl.TextColor3 = self.Theme.Text
        self._components:add(lbl, "TextColor3", "Text")
        return {
            AddButton = function(_, cfg2)
                local b = Instance.new("TextButton", page)
                b.Size = UDim2.new(1,0,0,36)
                b.Text = cfg2.Text or "Button"
                b.Font = Enum.Font.GothamBold
                b.TextScaled = true
                b.TextColor3 = Color3.new(1,1,1)
                b.BackgroundColor3 = self.Theme.Accent
                corner(b, 10)
                self._components:add(b, "BackgroundColor3", "Accent")
                if cfg2.Callback then b.MouseButton1Click:Connect(function() pcall(cfg2.Callback) end) end
                return b
            end,
            AddToggle = function(_, cfg2)
                local state = cfg2.Default or false
                local f = Instance.new("TextButton", page)
                f.Size = UDim2.new(1,0,0,36)
                f.BackgroundColor3 = self.Theme.Panel
                f.Text = (state and "✅ " or "❌ ") .. (cfg2.Text or "Toggle")
                f.Font = Enum.Font.Gotham
                f.TextScaled = true
                f.TextColor3 = self.Theme.Text
                corner(f, 10); stroke(f, self.Theme.Muted, 1, .6)
                self._components:add(f, "BackgroundColor3", "Panel")
                self._components:add(f, "TextColor3", "Text")

                f.MouseButton1Click:Connect(function()
                    state = not state
                    f.Text = (state and "✅ " or "❌ ") .. (cfg2.Text or "Toggle")
                    if cfg2.Callback then pcall(cfg2.Callback, state) end
                end)
                return f
            end,
            AddSlider = function(_, cfg2)
                local min,max,val = cfg2.Min or 0, cfg2.Max or 100, cfg2.Default or (cfg2.Min or 0)

                local frame = Instance.new("Frame", page)
                frame.Size = UDim2.new(1,0,0,54)
                frame.BackgroundColor3 = self.Theme.Panel
                corner(frame, 10); stroke(frame, self.Theme.Muted, 1, .6)
                self._components:add(frame, "BackgroundColor3", "Panel")

                local lab = Instance.new("TextLabel", frame)
                lab.BackgroundTransparency = 1
                lab.Position = UDim2.new(0,12,0,4)
                lab.Size = UDim2.new(1,-24,0,22)
                lab.Text = cfg2.Text or "Slider"
                lab.Font = Enum.Font.Gotham
                lab.TextScaled = true
                lab.TextColor3 = self.Theme.Text
                self._components:add(lab, "TextColor3", "Text")

                local bg = Instance.new("Frame", frame)
                bg.Size = UDim2.new(1,-24,0,6)
                bg.Position = UDim2.new(0,12,1,-14)
                bg.BackgroundColor3 = self.Theme.Muted
                corner(bg, 4)
                self._components:add(bg, "BackgroundColor3", "Muted")

                local fill = Instance.new("Frame", bg)
                local pct = (val-min)/(max-min)
                fill.Size = UDim2.new(pct,0,1,0)
                fill.BackgroundColor3 = self.Theme.Accent
                corner(fill, 4)
                self._components:add(fill, "BackgroundColor3", "Accent")

                local dragging=false
                local function updateFromX(x)
                    local p = math.clamp((x - bg.AbsolutePosition.X)/bg.AbsoluteSize.X, 0, 1)
                    val = math.floor(min + (max-min)*p + .5)
                    fill.Size = UDim2.new(p,0,1,0)
                    if cfg2.Callback then pcall(cfg2.Callback, val) end
                end
                bg.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        dragging = true
                        updateFromX(i.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                        updateFromX(i.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        dragging=false
                    end
                end)

                return frame
            end,
            AddDropdown = function(_, cfg2)
                local options = cfg2.Options or {}
                local current = cfg2.Default or options[1] or "Select..."
                local frame = Instance.new("Frame", page)
                frame.Size = UDim2.new(1,0,0,40)
                frame.BackgroundColor3 = self.Theme.Panel
                corner(frame, 10); stroke(frame, self.Theme.Muted, 1, .6)
                self._components:add(frame, "BackgroundColor3", "Panel")

                local btn = Instance.new("TextButton", frame)
                btn.BackgroundColor3 = self.Theme.Panel
                btn.AutoButtonColor = false
                btn.Text = current
                btn.TextScaled = true
                btn.Font = Enum.Font.Gotham
                btn.TextColor3 = self.Theme.Text
                btn.Size = UDim2.new(1,-16,1,-8)
                btn.Position = UDim2.new(0,8,0,4)
                corner(btn, 8)
                self._components:add(btn, "TextColor3", "Text")
                self._components:add(btn, "BackgroundColor3", "Panel")

                local listFrame = Instance.new("Frame", frame)
                listFrame.Visible = false
                listFrame.BackgroundColor3 = self.Theme.Panel
                listFrame.Position = UDim2.new(0,8,1,6)
                listFrame.Size = UDim2.new(1,-16,0,#options*30 + 10)
                corner(listFrame, 8); stroke(listFrame, self.Theme.Accent, 1, .5)
                self._components:add(listFrame, "BackgroundColor3", "Panel")
                local lay = Instance.new("UIListLayout", listFrame); lay.Padding = UDim.new(0,6)
                padding(listFrame, 8,8,8,8)

                local function addOpt(txt)
                    local o = Instance.new("TextButton", listFrame)
                    o.Text = txt
                    o.TextScaled = true
                    o.Font = Enum.Font.Gotham
                    o.TextColor3 = self.Theme.Text
                    o.BackgroundColor3 = self.Theme.Muted
                    o.Size = UDim2.new(1,0,0,30)
                    corner(o, 8)
                    self._components:add(o, "BackgroundColor3", "Muted")
                    self._components:add(o, "TextColor3", "Text")
                    o.MouseButton1Click:Connect(function()
                        current = txt
                        btn.Text = current
                        listFrame.Visible = false
                        if cfg2.Callback then pcall(cfg2.Callback, current) end
                    end)
                end
                for _,opt in ipairs(options) do addOpt(opt) end

                btn.MouseButton1Click:Connect(function()
                    listFrame.Visible = not listFrame.Visible
                end)

                return frame
            end,
            AddTextbox = function(_, cfg2)
                local frame = Instance.new("Frame", page)
                frame.Size = UDim2.new(1,0,0,40)
                frame.BackgroundColor3 = self.Theme.Panel
                corner(frame, 10); stroke(frame, self.Theme.Muted, 1, .6)
                self._components:add(frame, "BackgroundColor3", "Panel")

                local tb = Instance.new("TextBox", frame)
                tb.Size = UDim2.new(1,-16,1,-8)
                tb.Position = UDim2.new(0,8,0,4)
                tb.PlaceholderText = cfg2.Placeholder or "Enter text..."
                tb.Text = cfg2.Default or ""
                tb.TextScaled = true
                tb.Font = Enum.Font.Gotham
                tb.TextColor3 = self.Theme.Text
                tb.BackgroundColor3 = self.Theme.Muted
                corner(tb, 8)
                self._components:add(tb, "BackgroundColor3", "Muted")
                self._components:add(tb, "TextColor3", "Text")

                tb.FocusLost:Connect(function(enter)
                    if cfg2.Callback then pcall(cfg2.Callback, tb.Text, enter) end
                end)
                return frame
            end,
            AddLabel = function(_, cfg2)
                local l = Instance.new("TextLabel", page)
                l.BackgroundTransparency = 1
                l.Text = cfg2.Text or "Label"
                l.TextScaled = true
                l.Font = Enum.Font.Gotham
                l.TextColor3 = self.Theme.TextDim
                l.Size = UDim2.new(1,0,0,28)
                self._components:add(l, "TextColor3", "TextDim")
                return l
            end
        }
    end

    return tabObj
end

return NovaUI
