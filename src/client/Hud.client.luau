--!strict
-- The on-screen banner: phase, time left, your fruit and the leader.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local state = ReplicatedStorage:WaitForChild("SprintState")

local gui = Instance.new("ScreenGui")
gui.Name = "SprintHud"
gui.ResetOnSpawn = false

local banner = Instance.new("TextLabel")
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Position = UDim2.new(0.5, 0, 0, 12)
banner.Size = UDim2.new(0, 460, 0, 56)
banner.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
banner.BackgroundTransparency = 0.25
banner.TextColor3 = Color3.fromRGB(255, 240, 200)
banner.Font = Enum.Font.FredokaOne
banner.TextScaled = true
banner.Parent = gui
Instance.new("UICorner").Parent = banner

local sub = Instance.new("TextLabel")
sub.AnchorPoint = Vector2.new(0.5, 0)
sub.Position = UDim2.new(0.5, 0, 0, 72)
sub.Size = UDim2.new(0, 460, 0, 30)
sub.BackgroundTransparency = 1
sub.TextColor3 = Color3.fromRGB(255, 255, 255)
sub.TextStrokeTransparency = 0.4
sub.Font = Enum.Font.FredokaOne
sub.TextScaled = true
sub.Parent = gui

gui.Parent = player:WaitForChild("PlayerGui")

local function myFruit(): number
	local stats = player:FindFirstChild("leaderstats")
	local fruit = stats and stats:FindFirstChild("Fruit") :: IntValue?
	return if fruit then fruit.Value else 0
end

local function refresh()
	local phase = state:GetAttribute("Phase")
	local t = state:GetAttribute("TimeLeft") or 0
	if phase == "Sprint" then
		banner.Text = string.format("SPRINT!  %ds   |   Starfruit: %d", t, myFruit())
	else
		banner.Text = string.format("Next sprint in %ds", t)
	end
	local lead = state:GetAttribute("Leader")
	sub.Text = if lead and lead ~= "" then "Leader: " .. lead else "Pink = 1, Gold = 5. Go!"
end

state:GetAttributeChangedSignal("TimeLeft"):Connect(refresh)
state:GetAttributeChangedSignal("Phase"):Connect(refresh)
task.spawn(function()
	while true do
		refresh()
		task.wait(0.25)
	end
end)
