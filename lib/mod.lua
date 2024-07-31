local mod = require 'core/mods'
local util = require 'util'
local MidiSelector = include('changez/lib/midi_selector')
local NumberSelector = include('changez/lib/number_selector')
local Selector = include('changez/lib/selector')
local utils = include('changez/lib/utils')

local INPUT_LABELS = {'Device', 'Channel', 'Program', 'CC#', 'CC Value'}

local changez = {}
local device_ids = {}
local device_names = {}
local initialized = false
local inputs = {}
local flags = {}
local menu = {}
local programs = {}
local public = {}
local selected_input = 1

-- SYSTEM HOOK CALLBACKS
mod.hook.register('system_post_startup', 'Changez post startup function', function() end)
-- system_post_startup - called after matron has fully started and system state has been restored but before any script is run
mod.hook.register('system_pre_shutdown', 'Changez pre shutdown function', function() end)
-- system_pre_shutdown - called when SYSTEM > SLEEP is selected from the menu
mod.hook.register('script_pre_init', 'Changez pre init function', function() end)
-- script_pre_init - called after a script has been loaded but before its engine has started, pmap settings restored, and init() function called
mod.hook.register('script_post_init', 'Changez post init function', function() end)
-- script_post_init - called after a script’s init() function has been called
mod.hook.register('script_post_cleanup', 'Changez post cleanup function', function() end)
-- script_post_cleanup - called after a script’s cleanup() function has been called, this normally occurs when switching between scripts

changez.init = function()
  -- connect midi and whatnot
end

changez.on_midi_message = function()
  -- process incoming message
end

menu.key = function(k, z)
  if k == 2 and z == 0 then
    mod.menu.exit()
  end
end

menu.enc = function(e, d)
  if e == 2 then
    menu.select_input(d)
  elseif e == 3 then
    inputs[selected_input]:adjust(d)
  end

  mod.menu.redraw()
end

menu.redraw = function()
  screen.clear()
  screen.move(1, 6)
  screen.text('CHANGEZ')
  menu.draw_inputs()
  screen.update()
end

menu.init = function()
  if not initialized then
    for i = 1, #midi.vports do
      if midi.vports[i].name ~= 'none' then
        local device = midi.vports[i]
        table.insert(device_ids, device.id)
        table.insert(device_names, utils.truncate(device.name, 17))
      end
    end

    inputs[1] = Selector:new({id = 1, label = INPUT_LABELS[1], values = device_names})
    inputs[2] = NumberSelector:new({id = 2, label = INPUT_LABELS[2]})
    inputs[2]:init(1, 16)

    for i = 3, 5 do
      inputs[i] = MidiSelector:new({id = i, label = INPUT_LABELS[i]})
      inputs[i]:init()
    end

    initialized = true
  end
end

menu.deinit = function()
  --do stuff when the menu is exited
end

menu.draw_inputs = function()
  local x, y = 1, 20
  for i = 1, #inputs do
    inputs[i]:redraw(x, y, selected_input == i)
    y = y + 10
  end
end

menu.select_input = function(d)
  selected_input = util.clamp(selected_input + d, 1, #inputs)
end

mod.menu.register(mod.this_name, menu)

-- EXTERNAL API
public.example = function(s)
  -- method that another script could use
  -- local example = require 'changez/lib/mod'
  -- example('Test api consumption')
  print(s)
end

return public