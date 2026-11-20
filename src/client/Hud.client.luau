--!strict
-- The on-screen HUD: a timer pill at the top, the leader under it, your starfruit count at the bottom,
-- "+N" pop-ups when you grab a fruit, a boost bar after a golden one, and the round result between sprints.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local state = ReplicatedStorage:WaitForChild("SprintState")

local CREAM = Color3.fromRGB(255, 244, 214)
local NAVY = Color3.fromRGB(28, 30, 54)
local PINK = Color3.fromRGB(255, 110, 190)
local GOLD = Color3.fromRGB(255, 205, 40)

local gui = Instance.new("ScreenGui")
gui.Name = "SprintHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false

local function label(name: string, size: UDim2, position: UDim2, anchor: Vector2): TextLabel
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Size = size
	l.Position = position
	l.AnchorPoint = anchor
	l.BackgroundTransparency = 1
	l.TextColor3 = CREAM
	l.Font = Enum.Font.FredokaOne
	l.TextScaled = true
	l.TextStrokeTransparency = 0.35
	l.Parent = gui
	return l
end

local function pill(l: TextLabel, color: Color3)
	l.BackgroundColor3 = color
	l.BackgroundTransparency = 0.15
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = l
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0.12, 0)
	pad.PaddingBottom = UDim.new(0.12, 0)
	pad.PaddingLeft = UDim.new(0, 18)
	pad.PaddingRight = UDim.new(0, 18)
	pad.Parent = l
	local stroke = Instance.new("UIStroke")
	stroke.Color = CREAM
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = l
end

local timer = label("Timer", UDim2.new(0, 280, 0, 50), UDim2.new(0.5, 0, 0, 8), Vector2.new(0.5, 0))
pill(timer, NAVY)
local leaderLine = label("Leader", UDim2.new(0, 280, 0, 26), UDim2.new(0.5, 0, 0, 64), Vector2.new(0.5, 0))

local score = label("Score", UDim2.new(0, 300, 0, 64), UDim2.new(0.5, 0, 1, -24), Vector2.new(0.5, 1))
pill(score, PINK)
score.TextColor3 = Color3.new(1, 1, 1)

local banner = label("Result", UDim2.new(0.7, 0, 0, 80), UDim2.new(0.5, 0, 0.32, 0), Vector2.new(0.5, 0.5))
banner.TextColor3 = GOLD
banner.TextStrokeTransparency = 0
banner.Visible = false

local boostBack = Instance.new("Frame")
boostBack.Name = "Boost"
boostBack.AnchorPoint = Vector2.new(0.5, 1)
boostBack.Position = UDim2.new(0.5, 0, 1, -96)
boostBack.Size = UDim2.new(0, 220, 0, 12)
boostBack.BackgroundColor3 = NAVY
boostBack.BackgroundTransparency = 0.3
boostBack.Visible = false
boostBack.Parent = gui
Instance.new("UICorner").Parent = boostBack
local boostFill = Instance.new("Frame")
boostFill.Size = UDim2.fromScale(1, 1)
boostFill.BackgroundColor3 = GOLD
boostFill.Parent = boostBack
Instance.new("UICorner").Parent = boostFill
local boostText = label("BoostText", UDim2.new(0, 220, 0, 22), UDim2.new(0.5, 0, 1, -110), Vector2.new(0.5, 1))
boostText.Text = "SPEED BOOST!"
boostText.TextColor3 = GOLD
boostText.Visible = false

gui.Parent = player:WaitForChild("PlayerGui")

local function myFruit(): number
	local stats = player:FindFirstChild("leaderstats")
	local fruit = stats and stats:FindFirstChild("Fruit") :: IntValue?
	return if fruit then fruit.Value else 0
end

local function refresh()
	local phase = state:GetAttribute("Phase")
	local t = (state:GetAttribute("TimeLeft") :: number?) or 0
	local result = (state:GetAttribute("LastResult") :: string?) or ""
	if phase == "Sprint" then
		timer.Text = string.format("SPRINT  %d:%02d", t // 60, t % 60)
		timer.BackgroundColor3 = if t <= 10 then Color3.fromRGB(200, 50, 70) else NAVY
		banner.Visible = false
	else
		timer.Text = string.format("Next sprint in %d", t)
		timer.BackgroundColor3 = NAVY
		banner.Text = if result ~= "" then result else "Get ready! Pink = 1, Gold = 5 + speed"
		banner.Visible = true
	end
	score.Text = string.format("★ %d starfruit", myFruit())
	local lead = state:GetAttribute("Leader")
	leaderLine.Text = if lead and lead ~= "" then "Leader: " .. lead else "Pink = 1   Gold = 5 + speed"
end

-- "+N" floats up from the score pill and fades.
local function popup(points: number)
	local p = label("Plus", UDim2.new(0, 120, 0, 44), UDim2.new(0.5, 0, 1, -96), Vector2.new(0.5, 1))
	p.Text = "+" .. points
	p.TextColor3 = if points > 1 then GOLD else PINK
	p.TextStrokeTransparency = 0
	local info = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(p, info, { Position = UDim2.new(0.5, 0, 1, -170), TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	task.delay(0.9, function()
		p:Destroy()
	end)
	local grow = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true)
	TweenService:Create(score, grow, { Size = UDim2.new(0, 330, 0, 70) }):Play()
end

local function watchScore()
	local stats = player:WaitForChild("leaderstats")
	local fruit = stats:WaitForChild("Fruit") :: IntValue
	local last = fruit.Value
	fruit.Changed:Connect(function()
		local gained = fruit.Value - last
		last = fruit.Value
		if gained > 0 then
			popup(gained)
		end
		refresh()
	end)
end

local function refreshBoost()
	local untilTime = (player:GetAttribute("BoostUntil") :: number?) or 0
	local left = untilTime - workspace:GetServerTimeNow()
	local on = left > 0
	boostBack.Visible = on
	boostText.Visible = on
	if on then
		boostFill.Size = UDim2.fromScale(math.clamp(left / 4, 0, 1), 1)
	end
end

state.AttributeChanged:Connect(refresh)
task.spawn(watchScore)
task.spawn(function()
	while true do
		refresh()
		for _ = 1, 10 do
			refreshBoost()
			task.wait(0.05)
		end
	end
end)
