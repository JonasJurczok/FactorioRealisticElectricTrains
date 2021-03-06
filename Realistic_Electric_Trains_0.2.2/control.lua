--control.lua

require("config")
require("logic.overhead_line")

--[[
Summary of global variables:

`global` table:
  * wire_for_pole: Maps a unit number of a pole to the corresponding wire entity
  * power_for_pole: Maps a pole's unit number to the power consumer entity
  * graphic_for_pole: Maps a pole's unit number to the wire holder entity
  * power_for_rail: Maps a rail's unit number to a power consumer powering it.
      The consumer might not be valid anymore, you need to check that!
  * electric_locos: An array of electric locomotives

Other global variables:
  * config: A table of static configuration values. Never changed at runtime.
  * ticks_per_update, enable_connect_particles, enable_failure_text,
      enable_zigzag_wire, enable_zigzag_vertical_only, enable_circuit_wire,
      enable_rewire_neighbours, max_pole_search_distance: Cached values of the
      mod settings. Will be automatically updated when the settings change.
--]]


--==============================================================================
-- Setup and settings

-- Initialization
script.on_init(
	function(e)
		-- init lookup tables
		global.wire_for_pole = {}   -- Pole ID -> Wire Entity
		global.power_for_pole = {}  -- Pole ID -> Power Entity
		global.graphic_for_pole = {}-- Pole ID -> Graphic Entity
		global.power_for_rail = {}  -- Rail ID -> Power Entity
		global.electric_locos = {}  -- Array of Loco Entity

		on_startup()
	end
)

script.on_load(
	function(e)
		on_startup()
	end
)

function on_startup()
	-- Exclude the energy consumer and wire holder from creative mode's instant blueprints
	if remote.interfaces["creative-mode"] then
		remote.call("creative-mode", "exclude_from_instant_blueprint", "ret-pole-energy-straight")
		remote.call("creative-mode", "exclude_from_instant_blueprint", "ret-pole-energy-diagonal")
		remote.call("creative-mode", "exclude_from_instant_blueprint", "ret-pole-holder-straight")
		remote.call("creative-mode", "exclude_from_instant_blueprint", "ret-pole-holder-diagonal")
	end
end

-- Settings and configuration changes

require("logic.events.on_setup_changed")
on_settings_changed() -- initial caching

script.on_event(defines.events.on_runtime_mod_setting_changed, 
	on_settings_changed
)

script.on_configuration_changed(
	on_configuration_changed
)

--==============================================================================

-- On built events

script.on_event({
		defines.events.on_built_entity,
		defines.events.on_robot_built_entity
	},
	require("logic.events.on_built")
)

--==============================================================================

-- On remove events

script.on_event({
		defines.events.on_entity_died,
		defines.events.on_pre_player_mined_item,
		defines.events.on_robot_pre_mined
	},
	require("logic.events.on_remove")
)

--==============================================================================

-- Tick handler

script.on_event(defines.events.on_tick, 
	require("logic.events.on_tick")
)

--==============================================================================

-- Selection script for the debugger

script.on_event(defines.events.on_player_selected_area,
	require("logic.events.on_selected_area")
)

--==============================================================================

-- Commands

commands.add_command("print_electric_train_count", 
	"Prints how many electric trains are currently registered in the Realistic Electric Trains mod.",
	function()
		local count = 0
		for _, _ in pairs(global.electric_locos) do
			count = count + 1
		end
		game.print(string.format("Total Trains: %d", count))
	end
)
