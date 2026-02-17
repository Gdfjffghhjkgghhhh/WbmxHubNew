--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

--// Cấu hình (chỉnh qua GUI)
local Config = {
    Enabled = true,
    AttackDistance = 70,
    AttackMobs = true,
    AttackPlayers = true,
    MaxTargets = 2,        -- Số mục tiêu tối đa mỗi đòn
    BurstCount = 20,        -- Số lần tấn công mỗi frame (càng cao càng nhanh)
}

--// FastAttack Class (chỉ cận chiến)
local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        ComboDebounce = 0,
        M1Combo = 0,
        Connections = {},
    }, FastAttack)

    -- Lấy hàm hit từ game (nếu có)
    pcall(function()
        self.CombatFlags = require(Modules.Flags).COMBAT_REMOTE_THREAD
        local LocalScript = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if LocalScript and getsenv then
            self.HitFunction = getsenv(LocalScript)._G.SendHitsToServer
        end
    end)
    return self
end

-- Kiểm tra entity sống
function FastAttack:IsEntityAlive(entity)
    local humanoid = entity and entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- Kiểm tra trạng thái stun/busy
function FastAttack:CheckStun(Character, Humanoid)
    local Stun = Character:FindFirstChild("Stun")
    local Busy = Character:FindFirstChild("Busy")
    if Humanoid.Sit then return false end
    if Stun and Stun.Value > 0 then return false end
    if Busy and Busy.Value then return false end
    return true
end

-- Lấy danh sách mục tiêu trong phạm vi
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

-- Tính combo (dùng cho fruit M1)
function FastAttack:GetCombo()
    local Combo = (tick() - self.ComboDebounce) <= 0.025 and self.M1Combo or 0
    Combo = Combo + 1
    self.ComboDebounce = tick()
    self.M1Combo = Combo
    return Combo
end

-- Đánh thường (melee, sword)
function FastAttack:UseNormalClick(Character)
    local BladeHits = self:GetBladeHits(Character)
    if #BladeHits == 0 then return end
    RegisterAttack:FireServer(0.00001)  -- Cooldạn gần như 0
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

-- Hàm tấn công chính (chỉ melee, sword, fruit)
function FastAttack:Attack()
    if not Config.Enabled then return end
    local Character = Player.Character
    if not Character or not self:IsEntityAlive(Character) then return end
    local Humanoid = Character:FindFirstChild("Humanoid")
    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped then return end
    local ToolTip = Equipped.ToolTip
    -- Chỉ xử lý melee, sword, blox fruit
    if not (ToolTip == "Melee" or ToolTip == "Sword" or ToolTip == "Blox Fruit") then return end
    if not self:CheckStun(Character, Humanoid) then return end

    if ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(Character, Equipped, self:GetCombo())
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
            -- Không có task.wait để đạt tốc độ tối đa
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
ToggleBtn.Text = "Auto Melee: ON"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
ToggleBtn.Parent = Frame
ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    ToggleBtn.Text = Config.Enabled and "Auto Melee: ON" or "Auto Melee: OFF"
    ToggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(0, 180, 0, 20)
SliderLabel.Position = UDim2.new(0, 10, 0, 45)
SliderLabel.Text = "Burst: 20"
SliderLabel.BackgroundTransparency = 1
SliderLabel.TextColor3 = Color3.new(1,1,1)
SliderLabel.Parent = Frame

local Slider = Instance.new("TextBox")
Slider.Size = UDim2.new(0, 180, 0, 25)
Slider.Position = UDim2.new(0, 10, 0, 65)
Slider.Text = "20"
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

print("🔥 Fast Melee siêu tốc đã sẵn sàng! Burst mặc định: 20 lần/frame.")
