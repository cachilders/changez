local utils = {}

function utils.truncate(s, l)
  local whole = string.len(s) 
  local half = math.floor(l / 2)

  if string.len(s) > l then
    s = ''..string.sub(s, 1, half)..'...'..string.sub(s, whole - half, whole)
  end

  return s
end

return utils
