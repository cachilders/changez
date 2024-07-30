local Selector = include('changez/lib/selector')

local NumberSelector = {}

function NumberSelector:new(options)
  local instance = Selector:new(options or {})
  setmetatable(self, {__index = Selector})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function NumberSelector:init(n)
  local range = n or 128
  local values = {}

  for i = 1, range do
    values[i] = i - 1
  end

  self.values = values
end

return NumberSelector