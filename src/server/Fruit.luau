--!strict
-- Spawns star-shaped fruit on the island and pays a player who touches one.
-- A fruit is a Model: an invisible ball "Hitbox" (the touch area) plus five neon arms and a core.
local Players = game:GetService("Players")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local Fruit = {}

local PINK = Color3.fromRGB(255, 70, 170)
local GOLD = Color3.fromRGB(255, 190, 20)

local rng = Random.new()
local folder: Folder
local active = false
local onCollect: (Player, number, boolean) -> () = function() end

local overlap = OverlapParams.new()
overlap.FilterType = Enum.RaycastFilterType.Exclude

-- A random point on the meadow that is not inside a rock or a palm trunk.
local function freeSpot(): Vector3
	local spot = Vector3.zero
	for _ = 1, 12 do
		local a = rng:NextNumber(0, 2 * math.pi)
		local d = math.sqrt(rng:NextNumber()) * (Config.ISLAND_RADIUS - 6)
		spot = Vector3.new(math.cos(a) * d, Config.FRUIT_HEIGHT, math.sin(a) * d)
		local blocked = false
		for _, hit in workspace:GetPartBoundsInRadius(spot, 2.5, overlap) do
			if hit.Name == "Rock" or hit.Name == "Trunk" then
				blocked = true
				break
			end
		end
		if not blocked then
			break
		end
	end
	return spot
end

local function piece(model: Model, class: string, size: Vector3, offset: CFrame, color: Color3): BasePart
	local p = Instance.new(class) :: BasePart
	p.Size = size
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	p.Color = color
	p:SetAttribute("Offset", offset)
	p.CFrame = offset
	p.Parent = model
	return p
end

-- Builds a five-pointed star standing upright (in the YZ plane) at the origin; place() moves it.
-- Each point is a triangle made of two mirrored wedges; a round disc fills the middle.
local STAR_INNER = 0.55 -- where the points start, from the centre
local POINT_LENGTH = 1.5
local POINT_BASE = 1.3
local THICKNESS = 0.6

local function buildStar(golden: boolean): Model
	local color = if golden then GOLD else PINK
	local model = Instance.new("Model")
	model.Name = if golden then "GoldenStarfruit" else "Starfruit"

	local hitbox = Instance.new("Part")
	hitbox.Name = "Hitbox"
	hitbox.Shape = Enum.PartType.Ball
	hitbox.Size = Vector3.new(4, 4, 4)
	hitbox.Transparency = 1
	hitbox.Anchored = true
	hitbox.CanCollide = false
	hitbox.Parent = model
	model.PrimaryPart = hitbox

	local disc = piece(model, "Part", Vector3.new(THICKNESS, 1.7, 1.7), CFrame.identity, color) :: Part
	disc.Shape = Enum.PartType.Cylinder -- a cylinder's axis is X, so the disc faces sideways like the star
	local half = Vector3.new(THICKNESS, POINT_LENGTH, POINT_BASE / 2)
	local y = STAR_INNER + POINT_LENGTH / 2
	for i = 0, 4 do
		local arm = CFrame.Angles(math.rad(i * 72), 0, 0)
		piece(model, "WedgePart", half, arm * CFrame.new(0, y, -POINT_BASE / 4), color)
		piece(model, "WedgePart", half, arm * CFrame.new(0, y, POINT_BASE / 4) * CFrame.Angles(0, math.pi, 0), color)
	end

	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = if golden then 14 else 9
	light.Brightness = if golden then 2 else 1
	light.Parent = hitbox

	if golden then
		local sparkle = Instance.new("Sparkles")
		sparkle.SparkleColor = color
		sparkle.Parent = hitbox
	end
	return model
end

-- Puts every part of the star at its offset from the given pivot.
local function place(model: Model, pivot: CFrame)
	for _, p in model:GetChildren() do
		if p:IsA("BasePart") then
			local offset = p:GetAttribute("Offset") :: CFrame?
			p.CFrame = if offset then pivot * offset else pivot
		end
	end
end

local function burst(position: Vector3, color: Color3)
	local a = Instance.new("Attachment")
	a.WorldPosition = position
	a.Parent = workspace.Terrain
	local fx = Instance.new("ParticleEmitter")
	fx.Color = ColorSequence.new(color)
	fx.LightEmission = 1
	fx.Size = NumberSequence.new(0.6, 0)
	fx.Speed = NumberRange.new(10, 16)
	fx.SpreadAngle = Vector2.new(180, 180)
	fx.Lifetime = NumberRange.new(0.4, 0.7)
	fx.Parent = a
	fx:Emit(24)
	task.delay(1, function()
		a:Destroy()
	end)
end

local function spawnOne()
	local golden = rng:NextNumber() < Config.GOLDEN_CHANCE
	local model = buildStar(golden)
	local spot = freeSpot()
	model:SetAttribute("Home", spot)
	model:SetAttribute("Phase", rng:NextNumber(0, 2 * math.pi))
	model:SetAttribute("Points", if golden then Config.GOLDEN_POINTS else Config.FRUIT_POINTS)
	place(model, CFrame.new(spot))

	local taken = false
	local hitbox = model.PrimaryPart :: BasePart
	hitbox.Touched:Connect(function(hit: BasePart)
		if taken or not active then
			return
		end
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then
			return
		end
		taken = true
		burst(hitbox.Position, if golden then GOLD else PINK)
		onCollect(player, model:GetAttribute("Points") :: number, golden)
		model:Destroy()
		task.delay(Config.RESPAWN_SECONDS, function()
			if folder.Parent then
				spawnOne()
			end
		end)
	end)
	model.Parent = folder
end

function Fruit.start(parent: Instance, collect: (Player, number, boolean) -> ())
	onCollect = collect
	folder = Instance.new("Folder")
	folder.Name = "Fruit"
	folder.Parent = parent
	overlap.FilterDescendantsInstances = { folder }
	for _ = 1, Config.FRUIT_COUNT do
		spawnOne()
	end
	-- Make the fruit bob and spin so it reads as a pickup.
	task.spawn(function()
		local t = 0
		while folder.Parent do
			t += task.wait(1 / 20)
			for _, m in folder:GetChildren() do
				local home = m:GetAttribute("Home") :: Vector3?
				if m:IsA("Model") and home then
					local phase = (m:GetAttribute("Phase") :: number?) or 0
					local bob = math.sin(t * 3 + phase) * 0.6
					place(m, CFrame.new(home + Vector3.new(0, bob, 0)) * CFrame.Angles(0, t * 2 + phase, 0))
				end
			end
		end
	end)
end

function Fruit.setActive(on: boolean)
	active = on
end

return Fruit
