--!strict
-- Builds the island: a grass disc, a sand ring, water, rocks and palm trees.
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local World = {}

local function part(props: { [string]: any }, parent: Instance): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in props do
		(p :: any)[k] = v
	end
	p.Parent = parent
	return p
end

local function cylinder(radius: number, height: number, y: number, color: Color3, material: Enum.Material, name: string, parent: Instance): Part
	-- A Roblox cylinder lies along X, so turn it upright.
	return part({
		Name = name,
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(height, radius * 2, radius * 2),
		CFrame = CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.rad(90)),
		Color = color,
		Material = material,
	}, parent)
end

local function palm(position: Vector3, parent: Instance)
	local model = Instance.new("Model")
	model.Name = "Palm"
	local trunk = part({
		Name = "Trunk",
		Size = Vector3.new(1.6, 14, 1.6),
		CFrame = CFrame.new(position + Vector3.new(0, 7, 0)) * CFrame.Angles(0, 0, math.rad(6)),
		Color = Color3.fromRGB(140, 98, 57),
		Material = Enum.Material.Wood,
	}, model)
	for i = 0, 4 do
		local angle = i * (2 * math.pi / 5)
		part({
			Name = "Leaf",
			Size = Vector3.new(8, 0.4, 2.4),
			CFrame = trunk.CFrame * CFrame.new(0, 7, 0) * CFrame.Angles(0, angle, math.rad(-20)) * CFrame.new(4, 0, 0),
			Color = Color3.fromRGB(46, 160, 67),
			Material = Enum.Material.Grass,
			CanCollide = false,
		}, model)
	end
	model.Parent = parent
end

function World.build(): Folder
	local folder = Instance.new("Folder")
	folder.Name = "Island"
	local r = Config.ISLAND_RADIUS

	cylinder(r + 400, 2, -3, Color3.fromRGB(40, 140, 220), Enum.Material.Glass, "Sea", folder).Transparency = 0.2
	cylinder(r + 14, 4, -1, Color3.fromRGB(238, 214, 160), Enum.Material.Sand, "Beach", folder)
	cylinder(r, 4, 0, Color3.fromRGB(90, 180, 80), Enum.Material.Grass, "Meadow", folder)

	local rng = Random.new(7)
	for _ = 1, 10 do
		local a = rng:NextNumber(0, 2 * math.pi)
		local d = rng:NextNumber(15, r - 8)
		palm(Vector3.new(math.cos(a) * d, 2, math.sin(a) * d), folder)
	end
	for _ = 1, 8 do
		local a = rng:NextNumber(0, 2 * math.pi)
		local d = rng:NextNumber(10, r - 5)
		local s = rng:NextNumber(3, 7)
		part({
			Name = "Rock",
			Size = Vector3.new(s, s * 0.7, s),
			CFrame = CFrame.new(math.cos(a) * d, 2 + s * 0.3, math.sin(a) * d) * CFrame.Angles(0, a, 0.2),
			Color = Color3.fromRGB(120, 120, 128),
			Material = Enum.Material.Slate,
		}, folder)
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Anchored = true
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.Position = Vector3.new(0, 2.5, 0)
	spawn.Color = Color3.fromRGB(255, 200, 60)
	spawn.Material = Enum.Material.Neon
	spawn.Neutral = true
	spawn.Parent = folder

	folder.Parent = workspace
	return folder
end

return World
