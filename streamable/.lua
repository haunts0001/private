getgenv().haunts = {
    ['Keybind'] = "N"
    ['Fov_Size'] = 15.17 
    ['Fov_Visible'] = true
    ['Prediction'] = 0.12061
    ['Notifications'] = true
    ['Aimparts'] = getgenv().Configs.One
}
getgenv().Configs = {
    ['One'] = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso", "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm", "LeftFoot", "LeftLowerLeg",  "LeftUpperLeg", "RightLowerLeg", "RightFoot",  "RightUpperLeg"}
    ['Two'] = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightLowerLeg"}
    ['Three'] = {"Head", "HumanoidRootPart", "LowerTorso", "LeftHand", "RightUpperArm", "LeftFoot"}
}


--Silent FOV
local SilentFOV = Drawing.new("Circle")
SilentFOV.Visible = getgenv().haunts.Fov_Visible
SilentFOV.Thickness = 1
SilentFOV.NumSides = 100
SilentFOV.Radius = getgenv().haunts.Fov_Size * 3
SilentFOV.Color = Color3.fromRGB(50,76,110)
SilentFOV.Filled = false
SilentFOV.Transparency = 0.7

local function getnamecall()
    if game.PlaceId == 2788229376 then
        return "UpdateMousePos"
    elseif game.PlaceId == 5602055394 or game.PlaceId == 7951883376 then
        return "MousePos"
    elseif game.PlaceId == 9825515356 then
        return "GetMousePos"
    end
end

local namecalltype = getnamecall()

function MainEventLocate()
    for _,v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v.Name == "MainEvent" then
            return v
        end
    end
end

local mainevent = MainEventLocate()

--Optimization
local vect3 = Vector3.new
local vect2 = Vector2.new
local cnew = CFrame.new

--Libraries
local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()

--Services
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local plrs = game:GetService("Players")
local ws = game:GetService("Workspace")

--Script Variables
local Toggled = false
local lplr = plrs.LocalPlayer
local target = nil
local Hitpart = nil

--Client Variables
local m = lplr:GetMouse()
local c = ws.CurrentCamera

-- // Notification Function
local function SendNotification(text, time)
    Notification:Notify(
        {Title = "haunts streamable", Description = text},
        {OutlineColor = Color3.fromRGB(40,40,40),Time = time, Type = "image"},
        {Image = "12491873313", ImageColor = Color3.fromRGB(50,76,110)}
    )
end 

-- // Call Functions
SendNotification("haunts#0001 - injecting haunts streamable", 3)
wait(1.5)
SendNotification("haunts#0001 - fov is "..getgenv().haunts.Fov_Size, 5)
wait(2)
SendNotification("haunts#0001 - "..getgenv().haunts.Keybind.." to toggle Silent Aim.", 5)

--Find the nearest player function
local function FindTarget()
    local dist, targ = math.huge, nil
    for  _,p in pairs(plrs:GetPlayers()) do
        local _,os = c:WorldToViewportPoint(p.Character.PrimaryPart.Position)
        if p ~= lplr and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health ~= 0 and p.Character:FindFirstChild("HumanoidRootPart") and os then
            local pos = c:WorldToViewportPoint(p.Character.PrimaryPart.Position)
            local magnitude = (vect2(pos.X, pos.Y) - vect2(m.X, m.Y)).magnitude
            if magnitude < dist then
                targ = p
                dist = magnitude
            end
        end
    end
    target = targ
end

--Find nearest part
local function FindNearestPart()
    local dist, part = math.huge, nil
    if target then
        for _,v in pairs(target.Character:GetChildren()) do
            if table.find(getgenv().haunts.Aimparts, v.Name) then
                local pos = c:WorldToViewportPoint(v.Position)
                local Magn = (vect2(m.X, m.Y + 36) - vect2(pos.X, pos.Y)).Magnitude
                if Magn < dist then
                    dist = Magn
                    part = v
                end
            end
        end
        Hitpart = part.Name
    end
end

--Check if player is on screen
local function CheckIfVisible(target)
    local obscuringParts = c:GetPartsObscuringTarget({c.CFrame.Position, target.Character.UpperTorso.Position}, {lplr.Character, target.Character.UpperTorso.Parent})
    if #obscuringParts > 0 then
        for i,v in pairs(obscuringParts) do
            if not v:IsDescendantOf(lplr.Character) then
                return false
            end
        end
    end
    return true
end

--Anti-aim detection
local function CheckForAnti(targ)
    if (targ.Character.HumanoidRootPart.Velocity.Y < -5 and targ.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall) or targ.Character.HumanoidRootPart.Velocity.Y < -50 then
        return true
    elseif targ and (targ.Character.HumanoidRootPart.Velocity.X > 35 or targ.Character.HumanoidRootPart.Velocity.X < -35) then
        return true
    elseif targ and targ.Character.HumanoidRootPart.Velocity.Y > 60 then
        return true
    elseif targ and (targ.Character.HumanoidRootPart.Velocity.Z > 35 or targ.Character.HumanoidRootPart.Velocity.Z < -35) then
        return true
    else
        return false
    end
end

--Check if player is in fov
local function InRadius()
    if target and Hitpart then
        local pos = nil
        if CheckForAnti(target) then
            pos = c:WorldToViewportPoint(target.Character[Hitpart].Position + target.Character[Hitpart].Velocity * getgenv().haunts.Prediction)
        else
            pos = c:WorldToViewportPoint(target.Character[Hitpart].Position + ((target.Character.Humanoid.MoveDirection * target.Character.Humanoid.WalkSpeed) * getgenv().haunts.Prediction))
        end
        local mag = (vect2(m.X, m.Y + 36) - vect2(pos.X, pos.Y)).Magnitude
        if mag < getgenv().haunts.Fov_Size * 3 then
            return true
        else
            return false
        end
    end
end

--Silent function
local function Silent()
    if target then
        if Hitpart and InRadius() then
            if not CheckForAnti(target) and CheckIfVisible(target) and not target.Character:WaitForChild("BodyEffects")["K.O"] then
                mainevent:FireServer(namecalltype, target.Character[Hitpart].Position + (target.Character[Hitpart].Velocity * getgenv().haunts.Prediction))
            else
                mainevent:FireServer(namecalltype, (target.Character[Hitpart].Position + ((target.Character.Humanoid.MoveDirection * target.Character.Humanoid.WalkSpeed) * getgenv().haunts.Prediction)))
            end
        end
    end
end

rs.Heartbeat:Connect(function()
    SilentFOV.Position = vect2(m.X, m.Y + 36)
end)

m.KeyDown:Connect(function(k, t)
    if k == getgenv().haunts.Keybind:lower() then
        if Toggled then
            Toggled = false
            if getgenv().haunts.Notifications then
                SendNotification("Silent disabled.", 2)
            end
        else
            Toggled = true
            if getgenv().haunts.Notifications then
                SendNotification("Silent enabled.", 2)
            end
        end
    end
end)

--When gun shoots
lplr.Character.ChildAdded:Connect(function(tool)
    if tool:IsA("Tool") then
        tool.Activated:connect(function()
            if Toggled then
                FindTarget()
                FindNearestPart()
                Silent()
            end
        end)
    end
end)

lplr.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(tool)
        if tool:IsA("Tool") then
            tool.Activated:connect(function()
                if Toggled then
                    FindTarget()
                    FindNearestPart()
                    Silent()
                end
            end)
        end
    end)
end)

--NoGroundShots

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

while true do
    wait(0.1)
    local velocity = humanoid.Velocity
    local speed = velocity.magnitude
    if speed < 0 then
        velocity = Vector3.new(0, 0, 0)
        humanoid.Velocity = velocity
    end
end
