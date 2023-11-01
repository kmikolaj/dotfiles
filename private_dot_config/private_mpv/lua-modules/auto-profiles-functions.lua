local utils = require 'mp.utils'
local msg = require 'mp.msg'

local exec_cache = {}

local function exec(process, force_exec)
	local key = table.concat(process, " ")
	if force_exec or exec_cache[key] == nil or exec_cache[key].error then
		local p_ret = utils.subprocess({args = process, playback_only = false})
		exec_cache[key] = p_ret
		if p_ret.error and p_ret.error == "init" then
			msg.error("executable not found: " .. key)
		end
		return p_ret
	else
		return exec_cache[key]
	end
end

function is_remote_filesystem(path)
	if path == nil then
		return false
	end

	local is_url = string.match(path, '[a-z]*://[^ >,;]*') ~= nil
	if is_url then
		return false
	end

	local result = exec({'stat', '-f', '-c', '%T', path})
	local fs = result.stdout:gsub("%s+", "")
	return fs == "nfs"
end
