--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent = Net:WaitForChild("RE/ShootGunEvent")
local GunValidator = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Validator2")

--// Cấu hình (có thể chỉnh qua GUI)
local Config = {
    Enabled = true,
    AttackDistance = 70,
    AttackMobs = true,
    AttackPlayers = true,
    MaxTargets = 50,                -- Số mục tiêu tối đa mỗi đòn
    GunRange = 120,
    GunFireRate = 0.005,            -- Khoảng cách giữa các phát súng (giây)
    BurstCount = 10,                 -- Số lần tấn công mỗi frame (tăng để "cực nhanh")
    UseRandomDelay = false,          -- Tắt để đạt tốc độ tối đa
}

--// FastAttack Class
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        Debounce = 0,
        ComboDebounce = 0,
        ShootDebounce = 0,
        M1Combo = 0,
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

function FastAttack:IsEntityAlive(entity)
    local humanoid = entity and entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

function FastAttack:CheckStun(Character, Humanoid, ToolTip)
    local Stun = Character:FindFirstChild("Stun")
    local Busy = Character:FindFirstChild("Busy")
    if Humanoid.Sit and (ToolTip == "Sword" or ToolTip == "Melee" or ToolTip == "Blox Fruit") then
        return false
    elseif Stun and Stun.Value > 0 or Busy and Busy.Value then
        return false
    end
    return true
end

function FastAttack:GetBladeHits(Character, Distance)
    local Position = Character:GetPivot().Position
    local BladeHits = {}
    Distance = Distance or Config.AttackDistance
    local function ProcessTargets(Folder)
        for _, Enemy in ipairs(Folder:GetChildren()) do
            if #BladeHits >= Config.MaxTargets then return end
            if Enemy ~= Character and self:IsEntityAlive(Enemy) then
                local BasePart = Enemy:FindFirstChild("HumanoidRootPart")
                if BasePart and (Position - BasePart.Position).Magnitude <= Distance then
                    table.insert(BladeHits, {Enemy, BasePart})
                end
            end
        end
    end
    if Config.AttackMobs then ProcessTargets(Workspace.Enemies) end
    if Config.AttackPlayers then ProcessTargets(Workspace.Characters) end
    return BladeHits
end

function FastAttack:GetCombo()
    local Combo = (tick() - self.ComboDebounce) <= 0.025 and self.M1Combo or 0
    Combo = Combo + 1
    self.ComboDebounce = tick()
    self.M1Combo = Combo
    return Combo
end

-- Bắn súng tối ưu
function FastAttack:ShootInTarget(TargetPosition)
    local Character = Player.Character
    if not self:IsEntityAlive(Character) then return end
    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped or Equipped.ToolTip ~= "Gun" then return end
    if (tick() - self.ShootDebounce) < Config.GunFireRate then return end

    local ShootType = self.SpecialShoots[Equipped.Name] or "Normal"
    
    if ShootType == "Position" or (ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent")) then
        Equipped:SetAttribute("LocalTotalShots", (Equipped:GetAttribute("LocalTotalShots") or 0) + 1)
        GunValidator:FireServer(self:GetValidator2())
        if ShootType == "TAP" then
            Equipped.RemoteEvent:FireServer("TAP", TargetPosition)
        else
            ShootGunEvent:FireServer(TargetPosition)
        end
    else
        if Equipped:FindFirstChild("RemoteEvent") then
            Equipped.RemoteEvent:FireServer("TAP", TargetPosition)
        else
            ShootGunEvent:FireServer(TargetPosition)
        end
    end
    
    self.ShootDebounce = tick()
end

function FastAttack:GetValidator2()
    -- Giữ nguyên code validator (có thể cần cập nhật theo game)
    local v1 = getupvalue(self.ShootFunction, 15)
    local v2 = getupvalue(self.ShootFunction, 13)
    local v3 = getupvalue(self.ShootFunction, 16)
    local v4 = getupvalue(self.ShootFunction, 17)
    local v5 = getupvalue(self.ShootFunction, 14)
    local v6 = getupvalue(self.ShootFunction, 12)
    local v7 = getupvalue(self.ShootFunction, 18)
    local v8 = v6 * v2
    local v9 = (v5 * v2 + v6 * v1) % v3
    v9 = (v9 * v3 + v8) % v4
    v5 = math.floor(v9 / v3)
    v6 = v9 - v5 * v3
    v7 = v7 + 1
    setupvalue(self.ShootFunction, 15, v1)
    setupvalue(self.ShootFunction, 13, v2)
    setupvalue(self.ShootFunction, 16, v3)
    setupvalue(self.ShootFunction, 17, v4)
    setupvalue(self.ShootFunction, 14, v5)
    setupvalue(self.ShootFunction, 12, v6)
    setupvalue(self.ShootFunction, 18, v7)
    return math.floor(v9 / v4 * 16777215), v7
end

-- Đánh thường với nhiều mục tiêu
function FastAttack:UseNormalClick(Character)
    local BladeHits = self:GetBladeHits(Character)
    if #BladeHits == 0 then return end
    RegisterAttack:FireServer(0.00001)
    local PrimaryTarget = BladeHits[1][2]
    if self.CombatFlags and self.HitFunction then
        pcall(function() self.HitFunction(PrimaryTarget, BladeHits) end)
    else
        pcall(function() RegisterHit:FireServer(PrimaryTarget, BladeHits) end)
    end
end

-- Trái ác quỷ M1
function FastAttack:UseFruitM1(Character, Equipped, Combo)
    local Targets = self:GetBladeHits(Character)
    if not Targets[1] then return end
    local Direction = (Targets[1][2].Position - Character:GetPivot().Position).Unit
    Equipped.LeftClickRemote:FireServer(Direction, Combo)
end

-- Hàm tấn công chính (được gọi nhiều lần mỗi frame nếu burst > 1)
function FastAttack:Attack()
    if not Config.Enabled then return end
    local Character = Player.Character
    if not Character or not self:IsEntityAlive(Character) then return end
    local Humanoid = Character:FindFirstChild("Humanoid")
    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end
    local ToolTip = Equipped.ToolTip
    if not table.find({"Melee", "Blox Fruit", "Sword", "Gun"}, ToolTip) then return end
    if not self:CheckStun(Character, Humanoid, ToolTip) then return end

    if ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(Character, Equipped, self:GetCombo())
    elseif ToolTip == "Gun" then
        local Targets = self:GetBladeHits(Character, Config.GunRange)
        for _, t in ipairs(Targets) do
            self:ShootInTarget(t[2].Position)
        end
    else
        self:UseNormalClick(Character)
    end
end

-- Khởi tạo instance
local AttackInstance = FastAttack.new()

-- Kết nối Heartbeat với Burst Mode
AttackInstance.Connections = {
    RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        for _ = 1, Config.BurstCount do
            AttackInstance:Attack()
            -- Nếu muốn cực nhanh, có thể bỏ qua task.wait, nhưng cẩn thận lag
            -- task.wait() -- bỏ comment nếu muốn giãn cách nhẹ
        end
    end)
}

--// GUI đơn giản (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.2
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 180, 0, 30)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.Text = "Auto Attack: ON"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
ToggleBtn.Parent = Frame
ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    ToggleBtn.Text = Config.Enabled and "Auto Attack: ON" or "Auto Attack: OFF"
    ToggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(0, 180, 0, 20)
SliderLabel.Position = UDim2.new(0, 10, 0, 45)
SliderLabel.Text = "Burst: 10"
SliderLabel.BackgroundTransparency = 1
SliderLabel.TextColor3 = Color3.new(1,1,1)
SliderLabel.Parent = Frame

local Slider = Instance.new("TextBox")
Slider.Size = UDim2.new(0, 180, 0, 25)
Slider.Position = UDim2.new(0, 10, 0, 65)
Slider.Text = "10"
Slider.PlaceholderText = "Số lần/frame"
Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Slider.TextColor3 = Color3.new(1,1,1)
Slider.Parent = Frame
Slider.FocusLost:Connect(function()
    local val = tonumber(Slider.Text)
    if val and val > 0 then
        Config.BurstCount = math.floor(val)
        SliderLabel.Text = "Burst: " .. Config.BurstCount
    else
        Slider.Text = tostring(Config.BurstCount)
    end
end)

print("🔥 FastAttack siêu tốc đã sẵn sàng! Burst mặc định: 10 lần/frame. Điều chỉnh qua GUI.")
