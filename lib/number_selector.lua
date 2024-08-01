local Selector = include('changez/lib/selector')

local NumberSelector = {}

function NumberSelector:new(options)
  local instance = Selector:new(options or {})
  setmetatable(self, {__index = Selector})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function NumberSelector:init(n, m)
  local values = {}

  for i = n, m do
    values[i] = i
  end

  self.values = values
end

return NumberSelector