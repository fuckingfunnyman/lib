--// SplixStyle UI Library (UI-only, safe)
--// Drop this in a ModuleScript and require it.

local SplixUI = {}
SplixUI.Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Panel      = Color3.fromRGB(22, 22, 22),
    Accent     = Color3.fromRGB(0, 255, 140),
    AccentSoft = Color3.fromRGB(0, 180, 110),
    Text       = Color3.fromRGB(230, 230, 230),
    SubText    = Color3.fromRGB(160, 160, 160)
}

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local function tween(o, t, p)
    TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play()
end

local function makeRound(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = obj
end

local function makeList(parent, padding)
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Padding = UDim.new(0, padding or 6)
    layout.Parent = parent
    return layout
end

--// Window

function SplixUI:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SplixUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 520, 0, 340)
    Main.Position = UDim2.new(0.5, -260, 0.5, -170)
    Main.BackgroundColor3 = self.Theme.Background
    Main.BorderSizePixel = 0
    makeRound(Main, 8)
    Main.Parent = ScreenGui

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 32)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -16, 1, 0)
    Title.Position = UDim2.new(0, 8, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Splix UI"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextColor3 = self.Theme.Text
    Title.Parent = TopBar

    local TabsHolder = Instance.new("Frame")
    TabsHolder.Size = UDim2.new(0, 120, 1, -32)
    TabsHolder.Position = UDim2.new(0, 0, 0, 32)
    TabsHolder.BackgroundColor3 = self.Theme.Panel
    TabsHolder.BorderSizePixel = 0
    makeRound(TabsHolder, 0)
    TabsHolder.Parent = Main

    local TabsList = makeList(TabsHolder, 2)
    TabsList.Padding = UDim.new(0, 2)

    local PagesHolder = Instance.new("Frame")
    PagesHolder.Size = UDim2.new(1, -120, 1, -32)
    PagesHolder.Position = UDim2.new(0, 120, 0, 32)
    PagesHolder.BackgroundColor3 = self.Theme.Panel
    PagesHolder.BorderSizePixel = 0
    makeRound(PagesHolder, 0)
    PagesHolder.Parent = Main

    local Window = {}
    Window._tabs = {}
    Window._pagesHolder = PagesHolder
    Window._tabsHolder = TabsHolder

    -- drag
    do
        local dragging, dragStart, startPos
        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
            end
        end)
        TopBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    function Window:AddTab(name)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.BackgroundColor3 = SplixUI.Theme.Panel
        TabButton.BorderSizePixel = 0
        TabButton.Text = name
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        TabButton.TextColor3 = SplixUI.Theme.SubText
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabsHolder

        local AccentBar = Instance.new("Frame")
        AccentBar.Size = UDim2.new(0, 3, 1, 0)
        AccentBar.Position = UDim2.new(0, 0, 0, 0)
        AccentBar.BackgroundColor3 = SplixUI.Theme.Accent
        AccentBar.BorderSizePixel = 0
        AccentBar.Visible = false
        AccentBar.Parent = TabButton

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -16, 1, -16)
        Page.Position = UDim2.new(0, 8, 0, 8)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 4
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = false
        Page.Parent = PagesHolder

        local PageList = makeList(Page, 6)
        PageList.Padding = UDim.new(0, 6)

        local Tab = {}
        Tab.Button = TabButton
        Tab.Page = Page
        Tab._list = PageList

        table.insert(Window._tabs, Tab)

        local function setActive(state)
            Page.Visible = state
            AccentBar.Visible = state
            tween(TabButton, 0.15, {
                BackgroundColor3 = state and Color3.fromRGB(30, 30, 30) or SplixUI.Theme.Panel,
                TextColor3 = state and SplixUI.Theme.Text or SplixUI.Theme.SubText
            })
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, t in ipairs(Window._tabs) do
                if t == Tab then
                    setActive(true)
                else
                    t.Page.Visible = false
                    t.Button.BackgroundColor3 = SplixUI.Theme.Panel
                    t.Button.TextColor3 = SplixUI.Theme.SubText
                    t.Button:FindFirstChildOfClass("Frame").Visible = false
                end
            end
        end)

        if #Window._tabs == 1 then
            setActive(true)
        end

        function Tab:AddSection(text)
            local Section = Instance.new("TextLabel")
            Section.Size = UDim2.new(1, -4, 0, 20)
            Section.BackgroundTransparency = 1
            Section.Text = text
            Section.Font = Enum.Font.GothamBold
            Section.TextSize = 14
            Section.TextColor3 = SplixUI.Theme.Text
            Section.TextXAlignment = Enum.TextXAlignment.Left
            Section.Parent = Page

            local Divider = Instance.new("Frame")
            Divider.Size = UDim2.new(1, -4, 0, 1)
            Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Divider.BorderSizePixel = 0
            Divider.Parent = Page

            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
        end

        function Tab:AddLabel(text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -4, 0, 18)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = SplixUI.Theme.SubText
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Page

            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
            return Label
        end

        function Tab:AddToggle(text, default, callback)
            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, -4, 0, 26)
            Holder.BackgroundTransparency = 1
            Holder.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -40, 1, 0)
            Label.Position = UDim2.new(0, 0, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = SplixUI.Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Holder

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0, 32, 0, 18)
            Button.Position = UDim2.new(1, -32, 0.5, -9)
            Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Button.BorderSizePixel = 0
            Button.Text = ""
            Button.AutoButtonColor = false
            makeRound(Button, 9)
            Button.Parent = Holder

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 14, 0, 14)
            Knob.Position = UDim2.new(0, 2, 0.5, -7)
            Knob.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
            Knob.BorderSizePixel = 0
            makeRound(Knob, 7)
            Knob.Parent = Button

            local state = default or false
            local function apply()
                if state then
                    tween(Button, 0.15, {BackgroundColor3 = SplixUI.Theme.AccentSoft})
                    tween(Knob, 0.15, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = SplixUI.Theme.Text})
                else
                    tween(Button, 0.15, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
                    tween(Knob, 0.15, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(90, 90, 90)})
                end
                if callback then
                    callback(state)
                end
            end

            Button.MouseButton1Click:Connect(function()
                state = not state
                apply()
            end)

            apply()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)

            return {
                Set = function(_, v)
                    state = v
                    apply()
                end,
                Get = function()
                    return state
                end
            }
        end

        function Tab:AddSlider(text, min, max, default, callback)
            min, max = min or 0, max or 100
            default = default or min

            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, -4, 0, 40)
            Holder.BackgroundTransparency = 1
            Holder.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 18)
            Label.BackgroundTransparency = 1
            Label.Text = ("%s: %s"):format(text, tostring(default))
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = SplixUI.Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Holder

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1, 0, 0, 6)
            Bar.Position = UDim2.new(0, 0, 0, 24)
            Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Bar.BorderSizePixel = 0
            makeRound(Bar, 3)
            Bar.Parent = Holder

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = SplixUI.Theme.Accent
            Fill.BorderSizePixel = 0
            makeRound(Fill, 3)
            Fill.Parent = Bar

            local dragging = false
            local value = default

            local function setFromX(x)
                local rel = math.clamp((x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * rel + 0.5)
                Fill.Size = UDim2.new(rel, 0, 1, 0)
                Label.Text = ("%s: %s"):format(text, tostring(value))
                if callback then
                    callback(value)
                end
            end

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    setFromX(input.Position.X)
                end
            end)

            UIS.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    setFromX(input.Position.X)
                end
            end)

            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)

            return {
                Set = function(_, v)
                    v = math.clamp(v, min, max)
                    local rel = (v - min) / (max - min)
                    value = v
                    Fill.Size = UDim2.new(rel, 0, 1, 0)
                    Label.Text = ("%s: %s"):format(text, tostring(value))
                    if callback then callback(value) end
                end,
                Get = function()
                    return value
                end
            }
        end

        function Tab:AddDropdown(text, options, default, callback)
            options = options or {}
            default = default or options[1]

            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, -4, 0, 32)
            Holder.BackgroundTransparency = 1
            Holder.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = SplixUI.Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Holder

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0.5, -4, 1, 0)
            Button.Position = UDim2.new(0.5, 4, 0, 0)
            Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Button.BorderSizePixel = 0
            Button.Text = tostring(default)
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 14
            Button.TextColor3 = SplixUI.Theme.SubText
            Button.AutoButtonColor = false
            makeRound(Button, 4)
            Button.Parent = Holder

            local ListFrame = Instance.new("Frame")
            ListFrame.Size = UDim2.new(1, 0, 0, 0)
            ListFrame.Position = UDim2.new(0, 0, 1, 2)
            ListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            ListFrame.BorderSizePixel = 0
            makeRound(ListFrame, 4)
            ListFrame.Visible = false
            ListFrame.ClipsDescendants = true
            ListFrame.Parent = Holder

            local ListLayout = makeList(ListFrame, 0)

            local current = default

            local function set(v)
                current = v
                Button.Text = tostring(v)
                if callback then callback(v) end
            end

            for _, opt in ipairs(options) do
                local OptButton = Instance.new("TextButton")
                OptButton.Size = UDim2.new(1, 0, 0, 22)
                OptButton.BackgroundTransparency = 1
                OptButton.Text = tostring(opt)
                OptButton.Font = Enum.Font.Gotham
                OptButton.TextSize = 14
                OptButton.TextColor3 = SplixUI.Theme.SubText
                OptButton.AutoButtonColor = false
                OptButton.Parent = ListFrame

                OptButton.MouseButton1Click:Connect(function()
                    set(opt)
                    tween(ListFrame, 0.15, {Size = UDim2.new(1, 0, 0, 0)})
                    task.delay(0.15, function()
                        ListFrame.Visible = false
                    end)
                end)
            end

            Button.MouseButton1Click:Connect(function()
                if ListFrame.Visible then
                    tween(ListFrame, 0.15, {Size = UDim2.new(1, 0, 0, 0)})
                    task.delay(0.15, function()
                        ListFrame.Visible = false
                    end)
                else
                    ListFrame.Visible = true
                    ListFrame.Size = UDim2.new(1, 0, 0, 0)
                    task.delay(0.01, function()
                        tween(ListFrame, 0.15, {Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y)})
                    end)
                end
            end)

            set(default)
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)

            return {
                Set = function(_, v) set(v) end,
                Get = function() return current end
            }
        end

        function Tab:AddKeybind(text, defaultKeyCode, callback)
            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, -4, 0, 30)
            Holder.BackgroundTransparency = 1
            Holder.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = SplixUI.Theme.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Holder

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0.5, -4, 1, 0)
            Button.Position = UDim2.new(0.5, 4, 0, 0)
            Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Button.BorderSizePixel = 0
            Button.Text = defaultKeyCode and defaultKeyCode.Name or "None"
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 14
            Button.TextColor3 = SplixUI.Theme.SubText
            Button.AutoButtonColor = false
            makeRound(Button, 4)
            Button.Parent = Holder

            local listening = false
            local currentKey = defaultKeyCode

            Button.MouseButton1Click:Connect(function()
                listening = true
                Button.Text = "Press key..."
                Button.TextColor3 = SplixUI.Theme.Accent
            end)

            UIS.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    currentKey = input.KeyCode
                    Button.Text = currentKey.Name
                    Button.TextColor3 = SplixUI.Theme.SubText
                elseif not listening and currentKey and input.KeyCode == currentKey then
                    if callback then callback() end
                end
            end)

            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)

            return {
                Set = function(_, key)
                    currentKey = key
                    Button.Text = key and key.Name or "None"
                end,
                Get = function()
                    return currentKey
                end
            }
        end

        return Tab
    end

    return Window
end

return SplixUI
