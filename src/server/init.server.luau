--!strict
-- Starfruit Sprint: run around the island and grab as many starfruit as you can before the sprint ends.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local World = require(script:WaitForChild("World"))
local Fruit = require(script:WaitForChild("Fruit"))

local state = Instance.new("Folder")
state.Name = "SprintState"
state:SetAttribute("Phase", "Intermission")
state:SetAttribute("TimeLeft", Config.INTERMISSION_SECONDS)
state:SetAttribute("Leader", "")
state.Parent = ReplicatedStorage

local function setupPlayer(player: Player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local fruit = Instance.new("IntValue")
	fruit.Name = "Fruit"
	fruit.Parent = stats
	local best = Instance.new("IntValue")
	best.Name = "Best"
	best.Parent = stats
	stats.Parent = player
end

local function collect(player: Player, points: number)
	local stats = player:FindFirstChild("leaderstats")
	if not stats then
		return
	end
	local fruit = stats:FindFirstChild("Fruit") :: IntValue
	fruit.Value += points
end

local function leader(): (string, number)
	local name, top = "", 0
	for _, p in Players:GetPlayers() do
		local stats = p:FindFirstChild("leaderstats")
		local fruit = stats and stats:FindFirstChild("Fruit") :: IntValue?
		if fruit and fruit.Value > top then
			name, top = p.DisplayName, fruit.Value
		end
	end
	return name, top
end

local function countdown(phase: string, seconds: number)
	state:SetAttribute("Phase", phase)
	for t = seconds, 1, -1 do
		state:SetAttribute("TimeLeft", t)
		local name, top = leader()
		state:SetAttribute("Leader", if top > 0 then string.format("%s (%d)", name, top) else "")
		task.wait(1)
	end
end

Players.PlayerAdded:Connect(setupPlayer)
for _, p in Players:GetPlayers() do
	setupPlayer(p)
end

local island = World.build()
Fruit.start(island, collect)

while true do
	Fruit.setActive(false)
	countdown("Intermission", Config.INTERMISSION_SECONDS)
	for _, p in Players:GetPlayers() do
		local stats = p:FindFirstChild("leaderstats")
		if stats then
			(stats:FindFirstChild("Fruit") :: IntValue).Value = 0
		end
	end
	Fruit.setActive(true)
	countdown("Sprint", Config.ROUND_SECONDS)
	for _, p in Players:GetPlayers() do
		local stats = p:FindFirstChild("leaderstats")
		if stats then
			local fruit = stats:FindFirstChild("Fruit") :: IntValue
			local best = stats:FindFirstChild("Best") :: IntValue
			best.Value = math.max(best.Value, fruit.Value)
		end
	end
end
