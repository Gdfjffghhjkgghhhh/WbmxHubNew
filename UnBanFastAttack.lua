local RS      = game.ReplicatedStorage
local N       = require(RS.Modules.Net)
local C       = require(RS.Modules.CombatUtil)
local P       = game.Players.LocalPlayer
local Players = game.Players
local Enemies = workspace.Enemies

local hit = N:RemoteEvent("RegisterHit", true)
local atk = RS.Modules.Net["RE/RegisterAttack"]

-- ══════════════════════════════════════
--            CONFIG
-- ══════════════════════════════════════
local Config = {
    MobRange    = 60,
    PlayerRange = 60,
    MaxMobs     = 10,
    MaxPlayers  = 5,
}

-- ══════════════════════════════════════
--            ID GENERATOR
-- ══════════════════════════════════════
local baseID    = tostring(P.UserId):sub(2, 4)
local idCounter = 0
local function makeID()
    idCounter = (idCounter + 1) % 99999
    return baseID .. string.format("%05d", idCounter)
end

-- ══════════════════════════════════════
--   GetBladeHits() — CHỈ MOB
-- ══════════════════════════════════════
local function GetBladeHits(root, range)
    local pos  = root.Position
    local dist = range or Config.MobRange
    local hits = {}

    for _, m in ipairs(Enemies:GetChildren()) do
        if #hits >= Config.MaxMobs then break end
        local h = m:FindFirstChild("HumanoidRootPart")
        local u = m:FindFirstChild("Humanoid")
        if h and u and u.Health > 0 and (h.Position - pos).Magnitude <= dist then
            table.insert(hits, {m, h})
        end
    end

    return hits
end

-- ══════════════════════════════════════
--   GetPlayerHit() — CHỈ PLAYER
-- ══════════════════════════════════════
local function GetPlayerHit(root, range)
    local pos  = root.Position
    local dist = range or Config.PlayerRange
    local hits = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if #hits >= Config.MaxPlayers then break end
        if plr ~= P and plr.Character then
            local h = plr.Character:FindFirstChild("HumanoidRootPart")
            local u = plr.Character:FindFirstChild("Humanoid")
            if h and u and u.Health > 0 and (h.Position - pos).Magnitude <= dist then
                table.insert(hits, {plr.Character, h})
            end
        end
    end

    return hits
end

-- ══════════════════════════════════════
--   GetAllBladeHits() — MOB + PLAYER
-- ══════════════════════════════════════
local function GetAllBladeHits(root, mobRange, playerRange)
    local hits = {}

    for _, v in ipairs(GetBladeHits(root, mobRange))   do table.insert(hits, v) end
    for _, v in ipairs(GetPlayerHit(root, playerRange)) do table.insert(hits, v) end

    return hits
end

-- ══════════════════════════════════════
--            MAIN LOOP
-- ══════════════════════════════════════
task.spawn(function()
    game:GetService("RunService").Heartbeat:Connect(function()
        local c = P.Character
        if not c then return end

        local r = c:FindFirstChild("HumanoidRootPart")
        local t = c:FindFirstChildOfClass("Tool")
        if not r or not t then return end

        -- Lấy tất cả: mob + player
        local targets = GetAllBladeHits(r)
        if #targets == 0 then return end

        local id = makeID()
        atk:FireServer()
        hit:FireServer(targets[1][2], targets, nil, nil, id)
    end)
end)
