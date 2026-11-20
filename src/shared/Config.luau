--!strict
-- Tuning values shared by the server and the client.
local Config = {
	ROUND_SECONDS = 90, -- one sprint
	INTERMISSION_SECONDS = 10, -- pause between sprints (the result shows here)
	FRUIT_COUNT = 40, -- starfruit on the island at once
	ISLAND_RADIUS = 70, -- studs
	GOLDEN_CHANCE = 0.15, -- chance that a new fruit is golden
	FRUIT_POINTS = 1,
	GOLDEN_POINTS = 5,
	RESPAWN_SECONDS = 3,
	FRUIT_HEIGHT = 4.5, -- centre height of a fruit above the meadow base
	WALK_SPEED = 16, -- normal Roblox speed
	BOOST_SPEED = 26, -- after a golden starfruit
	BOOST_SECONDS = 4,
}

return Config
