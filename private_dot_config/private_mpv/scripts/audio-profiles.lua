-- Cycle audio normalization profiles defined in mpv.conf.
-- input.conf: n script-binding cycle-audio-profile

local modes = { "norm", "night", "off" }
local i = 0

mp.add_key_binding(nil, "cycle-audio-profile", function()
    i = i % #modes + 1
    local mode = modes[i]
    if mode == "off" then
        mp.set_property("af", "")
    else
        mp.commandv("apply-profile", mode)
    end
    mp.osd_message("Audio: " .. mode)
end)
