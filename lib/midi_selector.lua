local Selector = include('changez/lib/selector')

local MidiSelector = {}

function MidiSelector:new(options)
  local instance = Selector:new(options or {})
  setmetatable(self, {__index = Selector})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function MidiSelector:init()
  local values = {}

  for i = 1, 128 do
    values[i] = i - 1
  end

  self.values = values
end

return MidiSelector