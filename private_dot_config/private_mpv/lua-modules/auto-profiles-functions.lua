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

-- Returns one of: 'remote', 'local', 'unknown'
function filesystem_location(path)
	if path == nil then
		return 'unknown'
	end

	local is_url = string.match(path, '[a-z]*://[^ >,;]*') ~= nil
	if is_url then
		return 'remote'
	end

	local result = exec({'stat', '-f', '-c', '%T', path})
	if result.error or not result.stdout then
		return 'unknown'
	end

	local fs = result.stdout:gsub("%s+", "")
	if fs == "" then
		return 'unknown'
	end

	local remote_fs = { nfs = true, cifs = true, smb2 = true, fuseblk = true }
	if remote_fs[fs] then
		return 'remote'
	end
	return 'local'
end
