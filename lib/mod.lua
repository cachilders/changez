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
local input_count = 3
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
    inputs[3] = MidiSelector:new({
      action = function(p) menu.init_program(p) end,
      id = 3,
      label = INPUT_LABELS[3]
    })
    inputs[3]:init()

    initialized = true
  end
end

menu.deinit = function()
  --do stuff when the menu is exited
end

menu.draw_inputs = function()
  local x, y = 1, 20
  local selected_program = inputs[3]:get('selected')

  for i = 1, 3 do
    inputs[i]:redraw(x, y, selected_input == i)
    y = y + 10
  end

  if selected_program then
    local selected_program_control_number_selector = programs[selected_program].input
    local selected_controller_number = selected_program_control_number_selector:get('selected')
    inputs[4] = selected_program_control_number_selector
    input_count = 4

    selected_program_control_number_selector:redraw(x, y, selected_input == 4)

    if selected_controller_number then
      local selected_controller_value_input = programs[selected_program].controllers[selected_controller_number]
      inputs[5] = selected_controller_value_input
      input_count = 5
      y = y + 10

      selected_controller_value_input:redraw(x, y, selected_input == 5)
    else
      inputs[5] = nil
      input_count = 4
    end
  else
    inputs[4] = nil
    input_count = 3
  end
end

menu.init_controller = function(p, c)
  if not programs[p].controllers[c] then
    programs[p].controllers[c] = MidiSelector:new({id = p * c, label = INPUT_LABELS[5]})
    programs[p].controllers[c]:init()
  end
end

menu.init_program = function(p)
  if not programs[p] then
    programs[p] = {
      controllers = {},
      input = MidiSelector:new({
        action = function(c) menu.init_controller(p, c) end,
        id = 3 + p,
        label = INPUT_LABELS[4]
      })
    }

    programs[p].input:init()
  end
end

menu.select_input = function(d)
  selected_input = util.clamp(selected_input + d, 1, input_count)
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