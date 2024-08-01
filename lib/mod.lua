local mod = require 'core/mods'
local tab = require 'tabutil'
local util = require 'util'
local MidiSelector = include('changez/lib/midi_selector')
local NumberSelector = include('changez/lib/number_selector')
local Selector = include('changez/lib/selector')
local utils = include('changez/lib/utils')

local INPUT_LABELS = {'Input', 'Output', 'Program', 'CC#', 'CC Value'}

local changez = {}
local connections = nil
local device_ids = {}
local device_names = {}
local filepath = norns.state.data..'changez.autosave'
local initialized_menu = false
local initialized_params = false
local input_count = 3
local inputs = {}
local menu = {}
local programs = nil
local public = {}
local selected_input = 1

changez.autoload = function()
  local saved_programs = tab.load(filepath)
  if saved_programs then
    for i, program in pairs(saved_programs) do
      if program then
        local saved_controllers = program.controllers
        changez.init_program(i, program.input)
        if saved_controllers then
          for j, controller in pairs(saved_controllers) do
            if controller then
              changez.init_controller(i, j, controller)
            end
          end
        end
      end
    end
  end
end

changez.autosave = function()
  tab.save(programs, filepath)
end

changez.init = function()
  connections = {nil, nil}
  programs = {}
  changez.autoload()
end

changez.init_controller = function(p, c)
  if not programs[p].controllers[c] then
    programs[p].controllers[c] = MidiSelector:new({
      id = p * c,
      label = INPUT_LABELS[5],
      selected = options and options.selected or nil
    })
    programs[p].controllers[c]:init()
  end
end

changez.init_device = function(id, connection)
  connections[connection] = midi.connect(id)

  if connection == 1 then
    connections[1].event = function(data) changez.on_midi_event(data) end
  end
end

changez.init_program = function(p, options)
  if not programs[p] then
    programs[p] = {
      controllers = {},
      input = MidiSelector:new({
        action = function(c) changez.init_controller(p, c) end,
        id = 3 + p,
        label = INPUT_LABELS[4],
        selected = options and options.selected or nil
      })
    }

    programs[p].input:init()
  end
end

changez.reset = function()
  initialized_menu = false
  select_input = 1
  programs = {}
  changez.autosave()
end

changez.init_params = function()
  params:add_group('changez_params', 'CHANGEZ', 3)
  params:add_number('changez_input_ch', 'Input Channel', 1, 16, 1)
  params:add_number('changez_output_ch', 'Output Channel', 1, 16, 1)
  params:add_trigger('changez_reset', 'Reset Programs')
  params:set_action('changez_reset', changez.reset)
  initialized_params = true
end

changez.send_midi = function(p)
  local ch = initialized_params and params:get('changez_output_ch') or 1
  local program = programs[p]
  if program and connections[2] then
    controllers = program.controllers
    if controllers then
      for i = 1, #controllers do
        local controller = controllers[i]
        if controller then
          local cc = i - 1
          local v = controller:get('values')[controller:get('selected')]
          if v then
            print('Program '..p..' selected. Sending: cc# '..cc..': '..v..' on ch '..ch)
            connections[2]:cc(cc, v, ch)
          end
        end
      end
    end
  end
end 

changez.on_midi_event = function(data)
  local ch = initialized_params and params:get('changez_input_ch') or 1
  local msg = midi.to_msg(data)

  if msg.type == 'program_change' and msg.ch == ch then
    changez.send_midi(msg.val)
  end
end

menu.key = function(k, z)
  if k == 2 and z == 0 then
    changez.autosave()
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
  if not initialized_menu then
    for i = 1, #midi.vports do
      if midi.vports[i].name ~= 'none' then
        local device = midi.vports[i]
        table.insert(device_ids, i)
        table.insert(device_names, utils.truncate(device.name, 17))
      end
    end

    inputs[1] = Selector:new({
      action = function(id) changez.init_device(device_ids[id], 1) end,
      id = 1,
      label = INPUT_LABELS[1],
      values = device_names
    })
    inputs[2] = Selector:new({
      action = function(id) changez.init_device(device_ids[id], 2) end,
      id = 1,
      label = INPUT_LABELS[2],
      values = device_names
    })
    inputs[3] = MidiSelector:new({
      action = function(p) changez.init_program(p) end,
      id = 3,
      label = INPUT_LABELS[3]
    })
    inputs[3]:init()

    initialized_menu = true
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

menu.select_input = function(d)
  selected_input = util.clamp(selected_input + d, 1, input_count)
end

mod.menu.register(mod.this_name, menu)

-- SYSTEM HOOK CALLBACKS
mod.hook.register('system_post_startup', 'Changez post startup function', changez.init)
-- system_post_startup - called after matron has fully started and system state has been restored but before any script is run
mod.hook.register('system_pre_shutdown', 'Changez pre shutdown function', function() end)
-- system_pre_shutdown - called when SYSTEM > SLEEP is selected from the menu
mod.hook.register('script_pre_init', 'Changez pre init function', changez.init_params)
-- script_pre_init - called after a script has been loaded but before its engine has started, pmap settings restored, and init() function called
mod.hook.register('script_post_init', 'Changez post init function', function() end)
-- script_post_init - called after a script’s init() function has been called
mod.hook.register('script_post_cleanup', 'Changez post cleanup function', function() end)
-- script_post_cleanup - called after a script’s cleanup() function has been called, this normally occurs when switching between scripts

-- EXTERNAL API
public.example = function(s)
  -- method that another script could use
  -- local example = require 'changez/lib/mod'
  -- example('Test api consumption')
  print(s)
end

return public