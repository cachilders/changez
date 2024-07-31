local util = require 'util'
local OFFSET = 3

local Selector = {
  action = function() end,
  id = nil,
  label = nil,
  selected = nil,
  values = nil
}

function Selector:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Selector:init()
end

function Selector:get(k)
  return self[k]
end

function Selector:get_value()
  return self.values[self.selected]
end

function Selector:set(k, v)
  self[k] = v
end

function Selector:adjust(d)
  if self.selected then
    self.selected = util.clamp(self.selected + d, 1, #self.values)
  else
    self.selected = 1
  end

  self.action(self.selected)
end

function Selector:redraw(x, y, active)
  local ARROW = '→'
  local extents = screen.text_extents(self.label..' '..ARROW)
  local value = self.values[self.selected] or '<SELECT>'

  if active then
    screen.level(5)
    screen.move(extents + 4, y + OFFSET)
    screen.line_rel(screen.text_extents(value) + 2, 0)
    screen.stroke()
    screen.level(15)
  else
    screen.level(5)
  end

  screen.move(x, y)
  screen.text(self.label..' '..ARROW)
  screen.move(extents + 5, y)
  screen.text(value)
  screen.level(5)
end

return Selector