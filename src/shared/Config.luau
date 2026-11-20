--!strict
-- Tuning values shared by the server and the client.
local Config = {
	ROUND_SECONDS = 90, -- one sprint
	INTERMISSION_SECONDS = 8, -- pause between sprints
	FRUIT_COUNT = 24, -- starfruit on the island at once
	ISLAND_RADIUS = 70, -- studs
	GOLDEN_CHANCE = 0.12, -- chance that a new fruit is golden
	FRUIT_POINTS = 1,
	GOLDEN_POINTS = 5,
	RESPAWN_SECONDS = 3,
}

return Config
