-- Limit laptop speaker volume to 1.0 (100%)
-- Volume is stored in Device Route props, accessed via route.props.properties

-- log = Log.open_topic("s-node")
local cutils = require("common-utils")
local MAX_VOLUME = 1.0
local TARGET_DEVICE = "alsa_card.pci-0000_c3_00.6"
local TARGET_ROUTE = "analog-output-speaker"

SimpleEventHook {
  name = "node/limit-speaker-volume",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "device-params-changed" },
    },
  },
  execute = function(event)
    local device = event:get_subject()
    if device.properties["device.name"] ~= TARGET_DEVICE then return end

    for p in device:iterate_params("Route") do
      local route = cutils.parseParam(p, "Route")
      if not route or route.name ~= TARGET_ROUTE then goto continue end

      local props = route.props and route.props.properties
      if not (props and props.channelVolumes) then goto continue end

      local needs_clamp = false
      for _, v in ipairs(props.channelVolumes) do
        if v > MAX_VOLUME then needs_clamp = true; break end
      end

      if needs_clamp then
        -- log:warning(device, "clamping speaker volume to " .. MAX_VOLUME)

        local clamped = {}
        for i, v in ipairs(props.channelVolumes) do
          clamped[i] = math.min(v, MAX_VOLUME)
        end
        table.insert(clamped, 1, "Spa:Float")

        local new_props = {
          "Spa:Pod:Object:Param:Props", "Route",
          volume = MAX_VOLUME,
          mute = props.mute,
          channelVolumes = Pod.Array(clamped),
        }

        device:set_param("Route", Pod.Object {
          "Spa:Pod:Object:Param:Route", "Route",
          index = route.index,
          device = route.device,
          props = Pod.Object(new_props),
          save = true,
        })
      end

      ::continue::
    end
  end,
}:register()
