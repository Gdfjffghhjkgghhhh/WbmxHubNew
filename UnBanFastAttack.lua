local RS = game.ReplicatedStorage
local N = require(RS.Modules.Net)
local C = require(RS.Modules.CombatUtil)
local P = game.Players.LocalPlayer
local Players = game.Players
local Enemies = workspace.Enemies

local hit = N:RemoteEvent("RegisterHit", true)
local atk = RS.Modules.Net["RE/RegisterAttack"]

-- Cache ID một lần, không tạo lại mỗi frame
local baseID = tostring(P.UserId):sub(2, 4)
local idCounter = 0

local function makeID()
    idCounter = (idCounter + 1) % 99999
    return baseID .. string.format("%05d", idCounter)
end

local function getTargets(root)
    local targets = {}
    local pos = root.Position
    local rangeSq = 60 * 60 -- dùng magnitude² tránh sqrt

    for _, m in ipairs(Enemies:GetChildren()) do
        local h = m:FindFirstChild("HumanoidRootPart")
        local u = m:FindFirstChild("Humanoid")
        if h and u and u.Health > 0 then
            local dx = h.Position - pos
            if dx.X*dx.X + dx.Y*dx.Y + dx.Z*dx.Z <= rangeSq then
                table.insert(targets, {m, h})
            end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= P and plr.Character then
            local h = plr.Character:FindFirstChild("HumanoidRootPart")
            local u = plr.Character:FindFirstChild("Humanoid")
            if h and u and u.Health > 0 then
                local dx = h.Position - pos
                if dx.X*dx.X + dx.Y*dx.Y + dx.Z*dx.Z <= rangeSq then
                    table.insert(targets, {plr.Character, h})
                end
            end
        end
    end

    return targets
end

task.spawn(function()
    -- RunService.Heartbeat = mỗi frame, không delay như task.wait()
    game:GetService("RunService").Heartbeat:Connect(function()
        local c = P.Character
        if not c then return end

        local r = c:FindFirstChild("HumanoidRootPart")
        local t = c:FindFirstChildOfClass("Tool")
        if not r or not t then return end

        local targets = getTargets(r)
        if #targets == 0 then return end

        local id = makeID()
        atk:FireServer()
        hit:FireServer(targets[1][2], targets, nil, nil, id)
    end)
end)
