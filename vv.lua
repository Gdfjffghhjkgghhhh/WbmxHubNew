--// Services (giữ nguyên)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent = Net:WaitForChild("RE/ShootGunEvent")
local GunValidator = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Validator2")

--// Config SUPER FAST (2026)
local Config = {
    AttackDistance = 70,
    AttackMobs = true,
    AttackPlayers = true,
    ComboResetTime = 0,          -- ← Siêu quan trọng: 0 để combo không reset
    MaxCombo = math.huge,
    MaxTargets = 25,
    AutoClickEnabled = true,
    
    -- 🔥 SIÊU TỐC ĐỘ
    SpamPerFrame = 55,           -- 35 = mạnh | 45 = siêu mạnh | 55 = cực mạnh (dễ lag)
    UltraSpamIntensity = 35,     -- Loop while task.wait(0)
    UseUltraMode = true,         -- Bật = true để giống hồi trước
}

--// FastAttack Class (giữ nguyên như trước, chỉ chỉnh ComboResetTime)
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        Debounce = 0,
        ComboDebounce = 0,
        ShootDebounce = 0,
        M1Combo = 0,
        EnemyRootPart = nil,
        Connections = {},
        Overheat = {Dragonstorm = {MaxOverheat = 3, Cooldown = 0, TotalOverheat = 0, Distance = 350, Shooting = false}},
        ShootsPerTarget = {["Dual Flintlock"] = 2},
        SpecialShoots = {["Skull Guitar"] = "TAP", ["Bazooka"] = "Position", ["Cannon"] = "Position", ["Dragonstorm"] = "Overheat"}
    }, FastAttack)

    pcall(function()
        self.CombatFlags = require(Modules.Flags).COMBAT_REMOTE_THREAD
        self.ShootFunction = getupvalue(require(ReplicatedStorage.Controllers.CombatController).Attack, 9)
        local LocalScript = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if LocalScript and getsenv then
            self.HitFunction = getsenv(LocalScript)._G.SendHitsToServer
        end
    end)
    return self
end

-- (Các hàm IsEntityAlive, CheckStun, GetBladeHits, GetCombo, ShootInTarget, GetValidator2, UseNormalClick, UseFruitM1, Attack giữ NGUYÊN như phiên bản trước mình đưa)

--// Instance
local AttackInstance = FastAttack.new()

--// 🔥 OPTIMIZED SPAM (Heartbeat + RenderStepped)
local function OptimizedSpam()
    for i = 1, Config.SpamPerFrame do
        pcall(AttackInstance.Attack, AttackInstance)
    end
end

table.insert(AttackInstance.Connections, RunService.Heartbeat:Connect(OptimizedSpam))
table.insert(AttackInstance.Connections, RunService.RenderStepped:Connect(OptimizedSpam))

--// 🔥 ULTRA MODE (giống hồi trước – siêu nhanh)
if Config.UseUltraMode then
    task.spawn(function()
        while true do
            for i = 1, Config.UltraSpamIntensity do
                pcall(AttackInstance.Attack, AttackInstance)
            end
            task.wait(0)  -- task.wait(0) = nhanh nhất có thể
        end
    end)
end

print("🚀 SUPER FAST ATTACK LOADED | Spam:", Config.SpamPerFrame, "+ Ultra:", Config.UltraSpamIntensity, "| ComboReset = 0")

--// Cleanup (nếu cần tắt)
function AttackInstance:Destroy()
    for _, conn in ipairs(AttackInstance.Connections) do conn:Disconnect() end
end

return FastAttack
