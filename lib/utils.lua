local utils = {}

function utils.truncate(s, l)
  if string.len(s) > l then
    s = ''..string.sub(s, 1, l)..' ... '
  end

  return s
end

return utils
