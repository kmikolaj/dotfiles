-- Toggle horizontal flip for the current file, using a filter that matches
-- the decode path:
--   vaapi hw frames  -> transpose_vaapi (stays on the GPU)
--   software frames  -> hflip (also used with vaapi-copy)
-- Each new file starts unflipped.
-- input.conf:  F12 script-binding hflip/toggle

local LABEL = "@hflip"

local function is_flipped()
    for _, f in ipairs(mp.get_property_native("vf") or {}) do
        if f.label == LABEL:sub(2) then return true end
    end
    return false
end

mp.add_key_binding(nil, "toggle", function()
    if is_flipped() then
        mp.commandv("vf", "remove", LABEL)
        mp.osd_message("hflip: off")
        return
    end
    local filter = "hflip"
    if mp.get_property("video-dec-params/pixelformat") == "vaapi" then
        filter = "lavfi=[transpose_vaapi=dir=hflip]"
    end
    mp.commandv("vf", "add", LABEL .. ":" .. filter)
    mp.osd_message("hflip: on (" .. filter .. ")")
end)

-- vf is a global option and would carry over to the next file otherwise
mp.register_event("start-file", function()
    if is_flipped() then mp.commandv("vf", "remove", LABEL) end
end)
