--!strict
-- Spawns starfruit on the island and pays a player who touches one.
local Players = game:GetService("Players")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local Fruit = {}

local rng = Random.new()
local folder: Folder
local active = false
local onCollect: (Player, number) -> () = function() end

local function randomSpot(): Vector3
	local a = rng:NextNumber(0, 2 * math.pi)
	local d = math.sqrt(rng:NextNumber()) * (Config.ISLAND_RADIUS - 6)
	return Vector3.new(math.cos(a) * d, 4.5, math.sin(a) * d)
end

local function spawnOne()
	local golden = rng:NextNumber() < Config.GOLDEN_CHANCE
	local fruit = Instance.new("Part")
	fruit.Name = if golden then "GoldenStarfruit" else "Starfruit"
	fruit.Shape = Enum.PartType.Ball
	fruit.Size = Vector3.new(2.5, 2.5, 2.5)
	fruit.Anchored = true
	fruit.CanCollide = false
	fruit.Material = Enum.Material.Neon
	fruit.Color = if golden then Color3.fromRGB(255, 215, 0) else Color3.fromRGB(255, 120, 200)
	fruit.Position = randomSpot()
	fruit:SetAttribute("Points", if golden then Config.GOLDEN_POINTS else Config.FRUIT_POINTS)

	local light = Instance.new("PointLight")
	light.Color = fruit.Color
	light.Range = 10
	light.Parent = fruit

	local sparkle = Instance.new("Sparkles")
	sparkle.SparkleColor = fruit.Color
	sparkle.Enabled = golden
	sparkle.Parent = fruit

	local taken = false
	fruit.Touched:Connect(function(hit: BasePart)
		if taken or not active then
			return
		end
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then
			return
		end
		taken = true
		onCollect(player, fruit:GetAttribute("Points") :: number)
		fruit:Destroy()
		task.delay(Config.RESPAWN_SECONDS, function()
			if folder.Parent then
				spawnOne()
			end
		end)
	end)
	fruit.Parent = folder
end

function Fruit.start(parent: Instance, collect: (Player, number) -> ())
	onCollect = collect
	folder = Instance.new("Folder")
	folder.Name = "Fruit"
	folder.Parent = parent
	for _ = 1, Config.FRUIT_COUNT do
		spawnOne()
	end
	-- Make the fruit bob and spin so it reads as a pickup.
	task.spawn(function()
		local t = 0
		while folder.Parent do
			t += task.wait(0.05)
			for _, f in folder:GetChildren() do
				if f:IsA("BasePart") then
					f.CFrame = CFrame.new(f.Position.X, 4.5 + math.sin(t * 3 + f.Position.X) * 0.6, f.Position.Z)
						* CFrame.Angles(0, t * 2, 0)
				end
			end
		end
	end)
end

function Fruit.setActive(on: boolean)
	active = on
end

return Fruit
