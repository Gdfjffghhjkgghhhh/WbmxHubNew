local RS=game.ReplicatedStorage
local N=require(RS.Modules.Net)
local C=require(RS.Modules.CombatUtil)
local P=game.Players.LocalPlayer
local hit=N:RemoteEvent("RegisterHit",true)
local atk=RS.Modules.Net["RE/RegisterAttack"]

task.spawn(function()
while task.wait() do
local c=P.Character if not c then continue end
local r=c:FindFirstChild("HumanoidRootPart")
local t=c:FindFirstChildOfClass("Tool")
if not (r and t) then continue end

local targets={}

for _,m in ipairs(workspace.Enemies:GetChildren()) do
    local h,u=m:FindFirstChild("HumanoidRootPart"),m:FindFirstChild("Humanoid")
    if h and u and u.Health>0 and (h.Position-r.Position).Magnitude<=60 then
        table.insert(targets,{m,h})
    end
end

for _,plr in ipairs(game.Players:GetPlayers()) do
    if plr~=P and plr.Character then
        local m=plr.Character
        local h=m:FindFirstChild("HumanoidRootPart")
        local u=m:FindFirstChild("Humanoid")
        if h and u and u.Health>0 and (h.Position-r.Position).Magnitude<=60 then
            table.insert(targets,{m,h})
        end
    end
end

if #targets>0 then
    local id=tostring(P.UserId):sub(2,4)..tostring(coroutine.running()):sub(11,15)
    atk:FireServer()
    local firstTarget=targets[1][2]
    hit:FireServer(firstTarget,targets,nil,nil,id)
end

end end)
