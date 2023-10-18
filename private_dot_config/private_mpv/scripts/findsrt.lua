-- findsrt.lua
-- finds .srt subtitles in subdirectories respecting --sub-auto setting

-- hacked from autoloadtxt.lua

local msg = require 'mp.msg'
local options = require 'mp.options'
local utils = require 'mp.utils'

local langs = {
	{ name='Polish', alpha2='pl', alpha3='pol'},
	{ name='English', alpha2='en', alpha3='eng'},
}

o = { disabled = false }
options.read_options(o)

function split_ext(path)
	return string.match(path, "^(.+)%.([^%.]+)$")
end

function extract_lang(str)
	local lang = string.match(str, "%d*_(%a*)")
	if lang ~= nil then
		-- try full name
		for _, v in ipairs(langs) do
			if v.name:lower() == lang:lower() then
				return v
			end
		end
		-- try alpha3
		for _, v in ipairs(langs) do
			if v.alpha3:lower() == lang:lower() then
				return v
			end
		end
	end
	return nil
end

function is_empty(string)
	return string == nil or string == ""
end

function basename(str)
	local name = string.gsub(str, "(.*/)(.*)", "%2")
	return name
end

table.filter = function(t, iter)
	for i = #t, 1, -1 do
		if not iter(t[i]) then
			table.remove(t, i)
		end
	end
end

function print(txt, tb)
	if tb ~= nil then
		for k, v in pairs(tb) do
			msg.info(txt, k, v)
		end
	end
end

function table.merge(t1, t2)
	if t2 == nil then
		return
	end
	if t1 ~= t2 then
		for _, v in ipairs(t2) do
			table.insert(t1, v)
		end
	end
	return t1
end

local read_files = function(dir)
	local files = utils.readdir(dir, 'files')
	if files ~= nil then
		for k, v in ipairs(files) do
			files[k] = utils.join_path(dir, v)
		end
	end
	return files
end

function file_list(dir, name)
	local subdirs = { 'subs', 'Subs', 'sub', 'Sub', 'subtitles', 'Subtitles' }
	local subs = {}

	for _, subdir in ipairs(subdirs) do
		table.merge(subs, read_files(dir .. '/' .. subdir))
		if name ~= nil then
			table.merge(subs, read_files(dir .. '/' .. subdir .. '/' .. name))
		end
	end

	return subs
end

function find_and_add_entries()
	local path = mp.get_property("path", "")
	local dir, filename = utils.split_path(path)
	local name, ext = string.match(filename, "(.+)%.([^%.]+)$")
	local fuzz = mp.get_property("sub-auto", "no")

	if o.disabled or #dir == 0 or fuzz == "no" then
		return
	end

	local files = file_list(dir, name)
	if not files then
		return
	end

	if name == nil then
			return
	end

	table.filter(files, function (v, k)
		local sname, sext = split_ext(v:lower())
		local name = name:lower()

		if sext==nil then
			return false
		end

		return (sext:lower() == "srt" or sext:lower() == "sub") and
		(
			(fuzz=="exact" and sname==name) or
			(fuzz=="fuzzy") or
			(fuzz=="all")
		)
	end)

	table.sort(files, function (a, b)
		local len = string.len(a) - string.len(b)
		if len ~= 0 then -- case for ordering filename ending with such as X.Y.Z
			local _, ext = split_ext(a)
			local ext = string.len(ext) + 1
			return string.sub(a, 1, -ext) < string.sub(b, 1, -ext)
		end
		return string.lower(a) < string.lower(b)
	end)
	-- msg.warn("candidates:", utils.to_string(files))

	if dir == "." then
		dir = ""
	end

	for i = 1,#files do
		local subpath = files[i]
		local file = basename(subpath)
		local subname = split_ext(file)
		local lang = extract_lang(subname)

		if subname:lower() == name:lower() then
			mp.commandv('sub-add', subpath, 'select')
		elseif fuzz == "all" or fuzz == "fuzzy" then
			if lang ~= nil then
				mp.commandv('sub-add', subpath, 'auto', lang.name, lang.alpha3)
			end
		end
	end

	mp.commandv('rescan-external-files')
end

mp.register_event("start-file", find_and_add_entries)
