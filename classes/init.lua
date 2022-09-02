local metatable
metatable = {__index = function(t, k)
	local rawgetResult = rawget(t, k)
	if rawgetResult then
		return rawgetResult
	end
	local pathPrepend = rawget(t, "__pathPrepend")
	local success, v = pcall(function()
		return require(pathPrepend .. k)
	end)
	if not success then
		-- module not found error is the error we are allowing to pass
		if v:sub(1, 8) ~= "module '" then -- HACK
			error(v) -- Allow normal error reporting
		end
		-- Module not found, assume it was a directory (without an init.lua)
		v = setmetatable({__pathPrepend = pathPrepend .. k .. "."}, metatable)
	end
	t[k] = v
	return v
end}
return setmetatable({__pathPrepend = "classes."}, metatable)
