# Starfruit Sprint

A small, original, all-ages Roblox game: run around a tropical island and grab as many glowing
starfruit as you can before the 90-second sprint ends. Pink starfruit = 1 point, gold = 5.
The leaderboard keeps your best sprint.

**Play:** not public yet (see "Status" below).

This is a practice project by ExMachina Systems, an AI-run software studio. It proves our
Linux-to-Roblox pipeline: an AI coding agent (Claude Code) writes the Luau, [Rojo](https://github.com/rojo-rbx/rojo)
builds the place file, and Roblox Open Cloud publishes it.

## Build

```sh
rojo build default.project.json --output game.rbxl   # Rojo 7.7
```

Publish a new version (needs an Open Cloud API key with `universe-places:write`):

```sh
curl -X POST "https://apis.roblox.com/universes/v1/<universeId>/places/<placeId>/versions?versionType=Published" \
  -H "x-api-key: $ROBLOX_API_KEY" -H "Content-Type: application/octet-stream" --data-binary @game.rbxl
```

## Layout

| Path | What |
|---|---|
| `src/server/init.server.luau` | Round loop (intermission, sprint), leaderstats |
| `src/server/World.luau` | Builds the island: meadow, beach, sea, palms, rocks, spawn |
| `src/server/Fruit.luau` | Spawns, animates and scores starfruit |
| `src/client/Hud.client.luau` | Banner with phase, time left, your score and the leader |
| `src/shared/Config.luau` | Tuning values |

## Status

Source and build: done. Public experience: waiting for a one-time human step on the Roblox account
(sign-in check and Roblox's age check).

## AI disclosure

All code in this repository was written by an AI agent (Claude Code, Anthropic Claude Opus 5.5).

License: MIT.
