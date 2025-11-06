local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Shdsyyyy/1nig1htmare1234-OrionLib-with-Black-CheckMarks/refs/heads/main/Orion.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local LocalPlayer = player

local Window = OrionLib:MakeWindow({
    Name = "Heavenly Hub | Arsenal", 
	IntroText = "Heavenly on Top",
    HidePremium = true, 
    SaveConfig = true, 
    ConfigFolder = "HeavenlyArsW"
})

-- ====================== CREDITS TAB ======================
local TabCredits = Window:MakeTab({
    Name = "Credits",
    Icon = "rbxassetid://4483345998"
})
 
TabCredits:AddParagraph("© 2025   Heavenly", " Made by Kitna")

TabCredits:AddButton({
    Name = "Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/xDuTWhT9AJ")
        OrionLib:MakeNotification({
            Name = "Discord",
            Content = "Link Copied",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end    
})

-- ====================== SILENT AIM TAB ======================
local SilentAimEnabled = false
local TabSilentAim = Window:MakeTab({
    Name = "Silent Aim", 
    Icon = "rbxassetid://4483345998", 
    PremiumOnly = false
})

TabSilentAim:AddToggle({
    Name = "Silent Aim",
	Color = Color3.fromRGB(255,255,255),
    Default = false,
    Callback = function(Value)
        SilentAimEnabled = Value
    end
})

TabSilentAim:AddBind({
    Name = "Bind",
    Default = Enum.KeyCode.X,
    Hold = false,
    Callback = function()
        SilentAimEnabled = not SilentAimEnabled
    end    
})

-- Silent Aim Function
local function applySilentAim()
    if not SilentAimEnabled then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            for _, partName in pairs({"RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart"}) do
                local part = char:FindFirstChild(partName)
                if part then
                    part.CanCollide = false
                    part.Transparency = 10
                    part.Size = Vector3.new(13, 13, 13)
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(applySilentAim)

-- ====================== AIMBOT TAB ======================
local TabAimbot = Window:MakeTab({
	Name = "Aimbot",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

TabAimbot:AddLabel("WALL- And Teamcheck broken! - do not turn on")

local AimFOV = 200
local fovColor = Color3.fromRGB(255,0,0)
local fovCircleEnabled = true
local maxTargetDistance = 2500
local aimbotEnabled = false
local lockPart = "Head"
local IGNORE_TEAM = true
local WALLCHECK = false

-- FOV Circle
local DrawingAvailable = (typeof(Drawing) ~= "nil")
local FOVring
if DrawingAvailable then
	pcall(function()
		FOVring = Drawing.new("Circle")
		FOVring.Thickness = 1
		FOVring.Radius = AimFOV
		FOVring.Transparency = 1
		FOVring.Color = fovColor
		FOVring.Filled = false
		FOVring.Position = Camera.ViewportSize / 2
		FOVring.Visible = false
	end)
end

local function updateFOVRing()
	if not DrawingAvailable or not FOVring then return end
	FOVring.Radius = AimFOV
	FOVring.Color = fovColor
	FOVring.Position = Camera.ViewportSize / 2
	FOVring.Visible = aimbotEnabled and fovCircleEnabled
end

-- UI Controls
TabAimbot:AddToggle({
	Name = "Aimbot",
	Color = Color3.fromRGB(255,255,255),
	Default = false,
	Callback = function(v)
		aimbotEnabled = v
		updateFOVRing()
	end
})

TabAimbot:AddBind({
	Name = "Toggle Bind",
	Default = Enum.KeyCode.E,
	Hold = false,
	Callback = function()
		aimbotEnabled = not aimbotEnabled
		updateFOVRing()
	end
})

TabAimbot:AddSlider({
	Name = "Aim FOV",
	Min = 50,
	Max = 800,
	Default = AimFOV,
	Increment = 1,
	Callback = function(v)
		AimFOV = v
		updateFOVRing()
	end
})

TabAimbot:AddToggle({
	Color = Color3.fromRGB(255,255,255),
	Name = "Ignore Teammates",
	Default = false,
	Callback = function(v)
		IGNORE_TEAM = v
	end
})

TabAimbot:AddToggle({
	Color = Color3.fromRGB(255,255,255),
	Name = "WallCheck",
	Default = false,
	Callback = function(v)
		WALLCHECK = v
	end
})

TabAimbot:AddLabel("WALL- And Teamcheck broken! - do not turn on")

-- Helper Functions
local function isVisible(target)
	if not WALLCHECK then return true end
	if not target or not target.Character then return false end
	local head = target.Character:FindFirstChild(lockPart)
	if not head then return false end
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	local ray = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position), rayParams)
	return ray == nil
end

local function isValidTarget(plr)
	if not plr or plr == LocalPlayer then return false end
	if IGNORE_TEAM and LocalPlayer and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
		return false
	end
	local char = plr.Character
	if not char then return false end
	local part = char:FindFirstChild(lockPart)
	if not part then return false end
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp and (hrp.Position - Camera.CFrame.Position).Magnitude > maxTargetDistance then return false end
	if not isVisible(plr) then return false end
	return true
end

local function getClosest()
	local target = nil
	local shortest = math.huge
	local center = Camera.ViewportSize / 2
	for _, v in pairs(Players:GetPlayers()) do
		if isValidTarget(v) then
			local part = v.Character and v.Character:FindFirstChild(lockPart)
			if part then
				local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
					if dist <= AimFOV and dist < shortest then
						shortest = dist
						target = v
					end
				end
			end
		end
	end
	return target
end

RunService.RenderStepped:Connect(function()
	if FOVring then FOVring.Position = Camera.ViewportSize / 2 end
	if aimbotEnabled then
		if FOVring then FOVring.Visible = fovCircleEnabled end
		local target = getClosest()
		if target and target.Character and target.Character:FindFirstChild(lockPart) then
			local head = target.Character[lockPart]
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
		end
	else
		if FOVring then FOVring.Visible = false end
	end
end)

updateFOVRing()

-- ====================== ESP TAB ======================
local TabESP = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- World to Screen Helper
local function worldToScreen(pos)
    local screen, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screen.X, screen.Y), onScreen
end

-- ===== BOX ESP =====
local BOX = { Enabled = false, TeamCheck = false, BoxColor = Color3.fromRGB(255,0,0), Thickness = 2, MaxDistance = 1500 }
local boxes = {}
local boxConnection

local function newBox()
    local b = Drawing.new("Square")
    b.Visible = false
    b.Color = BOX.BoxColor
    b.Thickness = BOX.Thickness
    b.Filled = false
    b.Transparency = 1
    return b
end

local function updateBox(plr, box)
    if plr == LocalPlayer then box.Visible = false; return end
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then box.Visible = false; return end
    if BOX.TeamCheck and plr.Team == LocalPlayer.Team then box.Visible = false; return end

    local root = char.HumanoidRootPart
    local dist = (root.Position - Camera.CFrame.Position).Magnitude
    if dist > BOX.MaxDistance then box.Visible = false; return end

    local head = char:FindFirstChild("Head")
    if not head then box.Visible = false; return end

    local pos, onScreen = worldToScreen(head.Position + Vector3.new(0,0.5,0))
    if onScreen then
        local size = math.clamp(1000 / dist, 20, 150)
        box.Size = Vector2.new(size, size * 2)
        box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2)
        box.Visible = true
    else
        box.Visible = false
    end
end

local function startBoxESP()
    if boxConnection then return end
    boxConnection = RunService.RenderStepped:Connect(function()
        if not BOX.Enabled then return end
        for plr, box in pairs(boxes) do updateBox(plr, box) end
    end)
end

local function stopBoxESP()
    if boxConnection then boxConnection:Disconnect(); boxConnection = nil end
    for _, b in pairs(boxes) do b.Visible = false end
end

-- ===== SKELETON ESP =====
local SKELETON = { Enabled = false, TeamCheck = false, Color = Color3.fromRGB(0,255,0), Thickness = 2, MaxDistance = 1500 }
local skeletonLines = {}
local skeletonConnection

local function newLine()
    local l = Drawing.new("Line")
    l.Visible = false
    l.Color = SKELETON.Color
    l.Thickness = SKELETON.Thickness
    l.Transparency = 1
    return l
end

local bonePairs = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}

local function drawSkeleton(plr)
    if plr == LocalPlayer then for _, l in pairs(skeletonLines[plr] or {}) do l.Visible = false end; return end
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then for _, l in pairs(skeletonLines[plr] or {}) do l.Visible = false end; return end
    if SKELETON.TeamCheck and plr.Team == LocalPlayer.Team then for _, l in pairs(skeletonLines[plr] or {}) do l.Visible = false end; return end

    local root = char.HumanoidRootPart
    local dist = (root.Position - Camera.CFrame.Position).Magnitude
    if dist > SKELETON.MaxDistance then for _, l in pairs(skeletonLines[plr] or {}) do l.Visible = false end; return end

    local lines = skeletonLines[plr]
    if not lines then lines = {}; for i = 1, #bonePairs do table.insert(lines, newLine()) end; skeletonLines[plr] = lines end

    for i, pair in ipairs(bonePairs) do
        local p1, p2 = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
        local line = lines[i]
        if p1 and p2 then
            local pos1, on1 = worldToScreen(p1.Position)
            local pos2, on2 = worldToScreen(p2.Position)
            line.Visible = on1 and on2
            if line.Visible then line.From = pos1; line.To = pos2 end
        else
            line.Visible = false
        end
    end
end

local function startSkeletonESP()
    if skeletonConnection then return end
    skeletonConnection = RunService.RenderStepped:Connect(function()
        if not SKELETON.Enabled then return end
        for plr, _ in pairs(skeletonLines) do drawSkeleton(plr) end
    end)
end

local function stopSkeletonESP()
    if skeletonConnection then skeletonConnection:Disconnect(); skeletonConnection = nil end
    for _, lines in pairs(skeletonLines) do for _, l in pairs(lines) do l.Visible = false end end
end

-- ===== HEALTH ESP =====
local HEALTH = { Enabled = false, MaxDistance = 1500 }
local healthBars = {}
local healthConnection

local function newHealthBar()
    local bg = Drawing.new("Square"); bg.Visible = false; bg.Color = Color3.fromRGB(0,0,0); bg.Thickness = 1; bg.Filled = true; bg.Transparency = 0.7
    local bar = Drawing.new("Square"); bar.Visible = false; bar.Color = Color3.fromRGB(0,255,0); bar.Thickness = 1; bar.Filled = true; bar.Transparency = 1
    local text = Drawing.new("Text"); text.Visible = false; text.Color = Color3.fromRGB(255,255,255); text.Size = 12; text.Center = true; text.Outline = true; text.Font = 2
    return {bg=bg, bar=bar, text=text}
end

local function updateHealth(plr, data)
    if plr == LocalPlayer then for _, d in pairs(data) do d.Visible = false end; return end
    local char = plr.Character
    if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then
        for _, d in pairs(data) do d.Visible = false end
        return
    end
    local hum = char.Humanoid
    local root = char.HumanoidRootPart
    local dist = (root.Position - Camera.CFrame.Position).Magnitude
    if dist > HEALTH.MaxDistance then for _, d in pairs(data) do d.Visible = false end; return end
    local headPos, onScreen = worldToScreen(char.Head.Position + Vector3.new(0,1.5,0))
    if not onScreen then for _, d in pairs(data) do d.Visible = false end; return end

    local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
    local color = Color3.fromRGB(255*(1-hp), 255*hp, 0)
    local h = 25
    data.bg.Position = Vector2.new(headPos.X-2, headPos.Y-40)
    data.bg.Size = Vector2.new(5,h)
    data.bg.Visible = true

    data.bar.Position = Vector2.new(headPos.X-2, headPos.Y-40 + h*(1-hp))
    data.bar.Size = Vector2.new(5, h*hp)
    data.bar.Color = color
    data.bar.Visible = true

    data.text.Position = Vector2.new(headPos.X, headPos.Y-50)
    data.text.Text = math.floor(hum.Health).." HP"
    data.text.Visible = true
end

local function startHealthESP()
    if healthConnection then return end
    healthConnection = RunService.RenderStepped:Connect(function()
        if not HEALTH.Enabled then return end
        for plr, data in pairs(healthBars) do updateHealth(plr, data) end
    end)
end

local function stopHealthESP()
    if healthConnection then healthConnection:Disconnect(); healthConnection=nil end
    for _, data in pairs(healthBars) do for _, d in pairs(data) do d.Visible=false; d:Remove() end end
    healthBars = {}
end

-- ===== TRACER ESP =====
local TRACER = { Enabled = false, Color = Color3.fromRGB(255,0,255), Thickness = 2, MaxDistance = 3000, FromBottom = true }
local tracers = {}
local tracerConnection

local function newTracer()
    local l = Drawing.new("Line")
    l.Visible = false; l.Color = TRACER.Color; l.Thickness = TRACER.Thickness; l.Transparency = 1
    return l
end

local function updateTracer(plr, line)
    if plr == LocalPlayer then line.Visible=false; return end
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then line.Visible=false; return end
    local root = char.HumanoidRootPart
    local dist = (root.Position - Camera.CFrame.Position).Magnitude
    if dist > TRACER.MaxDistance then line.Visible=false; return end

    local foot, onScreen = worldToScreen(root.Position - Vector3.new(0,3,0))
    if not onScreen then line.Visible=false; return end

    local start = TRACER.FromBottom and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y-50)
                                   or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    line.From = start
    line.To = foot
    line.Visible = true
end

local function startTracerESP()
    if tracerConnection then return end
    tracerConnection = RunService.RenderStepped:Connect(function()
        if not TRACER.Enabled then return end
        for plr, line in pairs(tracers) do updateTracer(plr, line) end
    end)
end

local function stopTracerESP()
    if tracerConnection then tracerConnection:Disconnect(); tracerConnection=nil end
    for _, l in pairs(tracers) do l.Visible=false; l:Remove() end
    tracers = {}
end

-- ===== NAME ESP =====
local NAME_ESP = { Enabled = false, ShowDisplayName = false, MaxDistance = 2000 }
local nameTags = {}
local nameConnection

local function newNameTag()
    local t = Drawing.new("Text")
    t.Visible=false; t.Size=14; t.Center=true; t.Outline=true; t.Font=2; t.Color=Color3.fromRGB(255,255,255)
    return t
end

local function updateName(plr, text)
    if plr == LocalPlayer then text.Visible=false; return end
    local char = plr.Character
    if not char or not char:FindFirstChild("Head") then text.Visible=false; return end
    local dist = (char.Head.Position - Camera.CFrame.Position).Magnitude
    if dist > NAME_ESP.MaxDistance then text.Visible=false; return end
    local headPos, onScreen = worldToScreen(char.Head.Position + Vector3.new(0,1.5,0))
    if not onScreen then text.Visible=false; return end
    text.Text = NAME_ESP.ShowDisplayName and plr.DisplayName or plr.Name
    text.Position = headPos
    text.Visible = true
end

local function startNameESP()
    if nameConnection then return end
    nameConnection = RunService.RenderStepped:Connect(function()
        if not NAME_ESP.Enabled then return end
        for plr, t in pairs(nameTags) do updateName(plr, t) end
    end)
end

local function stopNameESP()
    if nameConnection then nameConnection:Disconnect(); nameConnection=nil end
    for _, t in pairs(nameTags) do t.Visible=false; t:Remove() end
    nameTags = {}
end

-- ===== PLAYER ADDED/REMOVED HANDLER =====
Players.PlayerAdded:Connect(function(p)
    if p == LocalPlayer then return end
    if HEALTH.Enabled then healthBars[p] = newHealthBar() end
    if TRACER.Enabled then tracers[p] = newTracer() end
    if NAME_ESP.Enabled then nameTags[p] = newNameTag() end
end)

Players.PlayerRemoving:Connect(function(p)
    if healthBars[p] then for _, d in pairs(healthBars[p]) do d.Visible=false; d:Remove() end; healthBars[p]=nil end
    if tracers[p] then tracers[p].Visible=false; tracers[p]:Remove(); tracers[p]=nil end
    if nameTags[p] then nameTags[p].Visible=false; nameTags[p]:Remove(); nameTags[p]=nil end
end)

-- ===== PLAYER ADDED / REMOVED HANDLER =====
Players.PlayerAdded:Connect(function(p)
    if p == LocalPlayer then return end
    if BOX.Enabled then boxes[p] = newBox() end
    if SKELETON.Enabled then
        skeletonLines[p] = {}
        for i = 1, #bonePairs do table.insert(skeletonLines[p], newLine()) end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if boxes[p] then boxes[p].Visible = false boxes[p] = nil end
    if skeletonLines[p] then
        for _, l in pairs(skeletonLines[p]) do l.Visible = false end
        skeletonLines[p] = nil
    end
end)

-- ===== UI CONTROLS =====
TabESP:AddToggle({
    Name = "Box ESP",
    Default = false,
    Color = Color3.fromRGB(255,255,255),
    Callback = function(v)
        BOX.Enabled = v
        if v then
            for _, p in Players:GetPlayers() do if p ~= LocalPlayer then boxes[p] = boxes[p] or newBox() end end
            startBoxESP()
        else
            stopBoxESP()
        end
    end
})

TabESP:AddToggle({
    Name = "Skeleton ESP",
    Default = false,
    Color = Color3.fromRGB(255,255,255),
    Callback = function(v)
        SKELETON.Enabled = v
        if v then
            for _, p in Players:GetPlayers() do
                if p ~= LocalPlayer then
                    skeletonLines[p] = skeletonLines[p] or {}
                    for i = 1, #bonePairs do table.insert(skeletonLines[p], newLine()) end
                end
            end
            startSkeletonESP()
        else
            stopSkeletonESP()
        end
    end
})

TabESP:AddToggle({
    Name = "Health ESP",
    Default = false,
    Color = Color3.fromRGB(255,255,255),
    Callback = function(v)
        HEALTH.Enabled = v
        if v then
            -- Create health bars for all existing players
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    healthBars[p] = healthBars[p] or newHealthBar()
                end
            end
            startHealthESP()
        else
            stopHealthESP()
        end
    end
})

-- Tracer ESP Toggle
TabESP:AddToggle({
    Name = "Tracer ESP",
    Default = false,
    Color = Color3.fromRGB(255,255,255),
    Callback = function(v)
        TRACER.Enabled = v
        if v then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    tracers[p] = tracers[p] or newTracer()
                end
            end
            startTracerESP()
        else
            stopTracerESP()
        end
    end
})

-- Name ESP Toggle
TabESP:AddToggle({
    Name = "Name ESP",
    Default = false,
    Color = Color3.fromRGB(255,255,255),
    Callback = function(v)
        NAME_ESP.Enabled = v
        if v then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    nameTags[p] = nameTags[p] or newNameTag()
                end
            end
            startNameESP()
        else
            stopNameESP()
        end
    end
})

-- Optional: Show DisplayName Toggle
TabESP:AddToggle({
    Name = "Use DisplayName Instead",
    Default = false,
    Color = Color3.fromRGB(255,255,255),
    Callback = function(v)
        NAME_ESP.ShowDisplayName = v
    end
})

TabESP:AddToggle({
    Name = "TeamCheck",
    Default = false,
    Color = Color3.fromRGB(255,255,255),
    Callback = function(v)
        BOX.TeamCheck = v
        SKELETON.TeamCheck = v
    end
})


-- ====================== PLAYER TAB ======================
local TabPlayer = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ====================== WEAPONS TAB ======================
local REFRTab = Window:MakeTab({
	Name = "Weapons",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Toggle states
local AutoEnabled = false
local RecoilEnabled = false
local MaxSpreadEnabled = false
local FastFireEnabled = false
local NoReloadEnabled = false
local UnlimitedAmmoEnabled = false

-- Function to apply weapon modifications
local function applyWeaponMods()
	for _, v in pairs(ReplicatedStorage.Weapons:GetDescendants()) do
		if v:IsA("NumberValue") then
			if v.Name == "Auto" then
				v.Value = AutoEnabled and true or v.Value
			end
			if v.Name == "RecoilControl" then
				v.Value = RecoilEnabled and 0 or 1
			end
			if v.Name == "MaxSpread" then
				v.Value = MaxSpreadEnabled and 0 or 1
			end
			if v.Name == "ReloadTime" then
				v.Value = NoReloadEnabled and 0.1 or 1
			end
			if v.Name == "FireRate" then
				v.Value = FastFireEnabled and 0.05 or 1
			end
		end
	end
end

-- Auto toggle
REFRTab:AddToggle({
	Name = "Auto On",
	Default = false,
	Callback = function(state)
		AutoEnabled = state
		applyWeaponMods()
	end
})

-- Recoil toggle
REFRTab:AddToggle({
	Name = "No Recoil",
	Default = false,
	Callback = function(state)
		RecoilEnabled = state
		applyWeaponMods()
	end
})

-- MaxSpread toggle
REFRTab:AddToggle({
	Name = "No Spread",
	Default = false,
	Callback = function(state)
		MaxSpreadEnabled = state
		applyWeaponMods()
	end
})

-- ReloadTime toggle
REFRTab:AddToggle({
	Name = "No Reload",
	Default = false,
	Callback = function(state)
		NoReloadEnabled = state
		applyWeaponMods()
	end
})

-- FireRate toggle
REFRTab:AddToggle({
	Name = "Fast FireRate",
	Default = false,
	Callback = function(state)
		FastFireEnabled = state
		applyWeaponMods()
	end
})



-- Automatically apply settings to new weapons
ReplicatedStorage.Weapons.ChildAdded:Connect(function(weapon)
	applyWeaponMods()
end)



-- PLAYER FLY SCRIPT
local UserCharacter = nil
local UserRootPart = nil
local Flying = false
local FlightSpeed = 50
local FlightAcceleration = 6
local CurrentVelocity = Vector3.zero
local SpeedKey = Enum.KeyCode.LeftControl
local SpeedKeyMultiplier = 2
local FlightConnection = nil

local function setCharacter(character)
    UserCharacter = character
    UserRootPart = character:WaitForChild("HumanoidRootPart")
    ToggleFlight(false)

    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Seated:Connect(function(isSeated)
        if isSeated then ToggleFlight(false) end
    end)
end

local function IsInVehicle()
    if not UserCharacter then return false end
    local humanoid = UserCharacter:FindFirstChildWhichIsA("Humanoid")
    return humanoid and humanoid.SeatPart
end

local function Flight(delta)
    local BaseVelocity = Vector3.zero
    if not UserInputService:GetFocusedTextBox() then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then BaseVelocity += Camera.CFrame.LookVector * FlightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then BaseVelocity -= Camera.CFrame.LookVector * FlightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then BaseVelocity -= Camera.CFrame.RightVector * FlightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then BaseVelocity += Camera.CFrame.RightVector * FlightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then BaseVelocity += Vector3.yAxis * FlightSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then BaseVelocity -= Vector3.yAxis * FlightSpeed end
        if UserInputService:IsKeyDown(SpeedKey) then BaseVelocity *= SpeedKeyMultiplier end
    end

    if UserRootPart and not UserRootPart.Anchored then
        CurrentVelocity = CurrentVelocity:Lerp(BaseVelocity, math.clamp(delta * FlightAcceleration, 0, 1))
        UserRootPart.Velocity = CurrentVelocity + Vector3.new(0, 2, 0)
        UserRootPart.CFrame = CFrame.lookAt(UserRootPart.Position, UserRootPart.Position + Camera.CFrame.LookVector)
    end
end

function ToggleFlight(enable)
    if IsInVehicle() then
        warn("Fliegen deaktiviert: Im Fahrzeug!")
        if FlightConnection then FlightConnection:Disconnect() FlightConnection = nil end
        Flying = false
        return false
    end

    if enable and not Flying then
        Flying = true
        FlightConnection = RunService.RenderStepped:Connect(Flight)
    elseif not enable and Flying then
        Flying = false
        if FlightConnection then FlightConnection:Disconnect() FlightConnection = nil end
    end
    return true
end

TabPlayer:AddToggle({
    Name = "Player Fly",
    Default = false,
    Color = Color3.fromRGB(255,255,255),
    Callback = function(Value)
        ToggleFlight(Value)
    end
})

TabPlayer:AddLabel("HOLD CTRL / STRG TO FLY FASTER")

TabPlayer:AddBind({
    Name = "Bind",
    Default = Enum.KeyCode.LeftAlt,
    Hold = false,
    Callback = function()
        ToggleFlight(not Flying)
    end    
})

player.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    setCharacter(char)
end)

if player.Character then
    setCharacter(player.Character)
end

player.CharacterRemoving:Connect(function()
    ToggleFlight(false)
end)


-- Speed
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Store the desired walkspeed and toggle state
local desiredWalkSpeed = humanoid.WalkSpeed
local originalWalkSpeed = humanoid.WalkSpeed
local speedEnabled = false

-- Create the connection ONCE, outside the callback
humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
	if speedEnabled and humanoid.WalkSpeed ~= desiredWalkSpeed then
		humanoid.WalkSpeed = desiredWalkSpeed
	end
end)

-- Toggle for enabling/disabling speed modification
TabPlayer:AddToggle({
	Name = "Enable Speed",
	Default = false,
    Color = Color3.fromRGB(255,255,255),
	Callback = function(Value)
		speedEnabled = Value
		if speedEnabled then
			humanoid.WalkSpeed = desiredWalkSpeed
		else
			humanoid.WalkSpeed = originalWalkSpeed
		end
	end    
})


TabPlayer:AddBind({
	Name = "Bind",
	Default = Enum.KeyCode.C,
	Hold = false,
	Callback = function()
		speedEnabled = not speedEnabled
        if speedEnabled then
            humanoid.WalkSpeed = desiredWalkSpeed
        else
            humanoid.WalkSpeed = originalWalkSpeed
        end
	end    
})

-- Tab1 Slider für WalkSpeed
TabPlayer:AddSlider({
	Name = "Speed",
	Min = 0,
	Max = 500,
	Default = humanoid.WalkSpeed,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "WalkSpeed",
	Callback = function(Value)
		-- Update the desired walkspeed variable
		desiredWalkSpeed = Value
		if speedEnabled then
			humanoid.WalkSpeed = Value
		end
	end    
})




-- ====================== INVISIBILITY TAB ======================
local TabInvis = Window:MakeTab({
    Name = "Invisibility",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
local Section = TabInvis:AddSection({
    Name = "Make Invisible"
})

TabInvis:AddButton({
    Name = "Invisibility Glitch",
    Callback = function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
})

TabInvis:AddLabel("THIS WONT RESPAWN YOU!")
TabInvis:AddLabel("THIS IS STATIC - ONE TIME USE")
TabInvis:AddLabel("THIS IS INVISIBILITY")
TabInvis:AddLabel("OTHERS WONT SEE YOU. YOURE NOT ABLE TO MOVE THO")
TabInvis:AddLabel("CLICK AGAIN AFTER EACH RESPAWN IF NEEDED")



-- ====================== INIT ======================
OrionLib:Init()
