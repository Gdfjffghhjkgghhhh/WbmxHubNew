local RS      = game.ReplicatedStorage
local N       = require(RS.Modules.Net)
local P       = game.Players.LocalPlayer
local Players = game.Players
local Enemies = workspace.Enemies
local HB      = game:GetService("RunService").Heartbeat

local hit = N:RemoteEvent("RegisterHit", true)
local atk = RS.Modules.Net["RE/RegisterAttack"]

-- ══════════════════════════════════════
--            CONFIG
-- ══════════════════════════════════════
local Config = {
    MobRange    = 60,
    PlayerRange = 60,
    MaxTargets  = 8,
    Cooldown    = 0.08, -- giây giữa mỗi lần fire (tăng nếu vẫn lag)
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
--   GetAllBladeHits() — reuse vector
-- ══════════════════════════════════════
local targets = {} -- reuse table, không tạo mới mỗi frame

local function GetAllBladeHits(pos)
    table.clear(targets)
    local rangeSqMob = Config.MobRange * Config.MobRange
    local rangeSqPlr = Config.PlayerRange * Config.PlayerRange

    for _, m in ipairs(Enemies:GetChildren()) do
        if #targets >= Config.MaxTargets then break end
        local h = m:FindFirstChild("HumanoidRootPart")
        local u = m:FindFirstChild("Humanoid")
        if h and u and u.Health > 0 then
            local d = h.Position - pos
            if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= rangeSqMob then
                targets[#targets+1] = {m, h}
            end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if #targets >= Config.MaxTargets then break end
        if plr ~= P and plr.Character then
            local h = plr.Character:FindFirstChild("HumanoidRootPart")
            local u = plr.Character:FindFirstChild("Humanoid")
            if h and u and u.Health > 0 then
                local d = h.Position - pos
                if d.X*d.X + d.Y*d.Y + d.Z*d.Z <= rangeSqPlr then
                    targets[#targets+1] = {plr.Character, h}
                end
            end
        end
    end

    return targets
end

-- ══════════════════════════════════════
--            MAIN LOOP
-- ══════════════════════════════════════
local lastFire = 0

task.spawn(function()
    HB:Connect(function()
        local now = tick()
        if now - lastFire < Config.Cooldown then return end

        local c = P.Character
        if not c then return end

        local r = c:FindFirstChild("HumanoidRootPart")
        local t = c:FindFirstChildOfClass("Tool")
        if not r or not t then return end

        local result = GetAllBladeHits(r.Position)
        if #result == 0 then return end

        lastFire = now
        atk:FireServer()
        hit:FireServer(result[1][2], result, nil, nil, makeID())
    end)
end)
