local util = require('util')
local OFFSET = 3

local Selector = {
  action = function() end,
  active = false,
  id = '',
  selected = nil,
  values = nil
}

function Selector:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Selector:init(options)
  local values = {}

  for i = 1, #options do
    values[i] = options[i]
  end

  self.values = values
end

function Selector:get(k)
  return self[k]
end

function Selector:set(k, v)
  self[k] = v
end

function Selector:adjust(d)
  self.selected = util.clamp(self.selected + d, 1, #self.values)
  self.action(self.selected)
end

function Selector:redraw(x, y)
  local value = self.options[self.selected] or '<SELECT>'

  if self.active then
    screen.level(5)
    screen.move(x, y + OFFSET)
    screen.line_rel(x + screen.text_extents(value), y + OFFSET)
    screen.stroke()
    screen.level(15)
  else
    screen.level(5)
  end

  screen.move(x, y)
  screen.text(value)
end

return Selector