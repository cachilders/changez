local mod = require 'core/mods'
local NumberSelector = include('changez/lib/number_selector')
local Selector = include('changez/lib/selector')

local changez = {}
local flags = {}
local menu = {}
local programs = {}
local public = {}

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
  mod.menu.redraw()
end

menu.redraw = function()
  screen.clear()
  screen.move(1, 6)
  screen.text('Changez')
  screen.update()
end

menu.init = function()
  --do stuff when the menu is entered
end

menu.deinit = function()
  --do stuff when the menu is exited
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