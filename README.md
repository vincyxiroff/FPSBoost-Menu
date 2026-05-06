# FPS Boost Menu for FiveM
FPS BOOST OFF:
![image](https://github.com/user-attachments/assets/949dcc2d-b3dd-404a-b0b2-e503aa1fa67d)

FPS BOOST ON (+47 FPS):
![image](https://github.com/user-attachments/assets/971d0f32-9417-48c6-9a29-514a1ed8002f)

## Overview
This script provides an advanced **FPS Boost menu** for FiveM, allowing players to optimize their game performance dynamically. The menu offers different levels of optimization, from **Ultra Low to High FPS Boost**, and also includes an **Ultra Graphics** mode to restore high-quality settings.

## Features
✅ **Multiple FPS Boost Levels**: Choose from Ultra Low, Medium, and High optimizations.  
✅ **Ultra Graphics Mode**: Restore the best possible graphics settings.  
✅ **Reset Option**: Easily revert to default settings.  
✅ **Entity Optimization**: Removes unnecessary entities at a distance for better performance.  
✅ **Culling batching**: Processes entities in batches to reduce FPS spikes while applying profiles.  
✅ **Profile persistence (KVP)**: Automatically restores the last selected profile on resource start (configurable).  
✅ **Premium NUI**: Modern in-game UI (HTML) with tabs and search for timecycles.  
✅ **IT/EN UI**: Built-in translations for both NUI and ox_lib menu (configurable).  
✅ **Config-driven**: UI mode, command, keybind, locale, culling presets and batching are controlled via `config.lua`.


## Installation
1. **Download from the relases & Extract** the resource into your `resources` folder.
2. **Ensure Dependencies**:
   - `ox_lib` (Required) → [Download Here](https://github.com/overextended/ox_lib)
3. **Add to `server.cfg`**:
`ensure Fpsboost-Menu`
4. **Start FiveM and use your configured command (default: `/fps`) to open the menu.**

## Commands
- `/<Config.CommandName>` (default: `/fps`) → Opens the FPS Boost Menu (NUI/ox/both depending on config)
- `fpsboost:openMenu` (Event) → Opens the menu programmatically

## Configuration
Edit `config.lua`:

- `Config.UiMode`: `nui` / `ox` / `both`
- `Config.Locale`: `it` / `en` / `auto` (uses convar `locale`, with optional saved override from the NUI)
- `Config.CommandName`: command to open the menu (default: `fps`)
- `Config.EnableKeybind` + `Config.Keybind`: optional key mapping (default key: `F7`)
- `Config.SaveProfileKvp` + `Config.ProfileKvpKey`: save/restore last profile
- `Config.Culling.enabled` + `Config.Culling.aggressive`: enable/disable and aggressiveness of entity handling
- `Config.CullingProfiles`: per-profile distances/alpha (ultra_low / medium / high)
- `Config.CullingBatch`: batching settings (`maxPerTick`, `tickWaitMs`)

## Notes
- Aggressive culling may cause side effects on some servers/maps depending on entity usage. If you notice issues, set `Config.Culling.aggressive = false` or disable culling entirely.

## Dependencies
- [ox_lib](https://github.com/overextended/ox_lib)
