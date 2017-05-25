--[[
  Copyright 2017 Stefano Mazzucco <stefano AT curso DOT re>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  This program was inspired by the
  [Awesome Pulseaudio Widget (APW)](https://github.com/mokasin/apw)
]]

local awesome = awesome -- luacheck: ignore
local string = string

local awful = require("awful")
local gears = require("gears")

local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local pulse = require("pulseaudio_dbus")

local icon_theme = "/usr/share/icons/Adwaita/scalable/status"
local icon_extension = ".svg"

icon_theme = beautiful.pulse_icon_theme or icon_theme
icon_extension = beautiful.pulse_icon_extension or icon_extension

local icon = {
  high = icon_theme .. "/audio-volume-high-symbolic" .. icon_extension,
  med = icon_theme .. "/audio-volume-medium-symbolic" .. icon_extension,
  low = icon_theme .. "/audio-volume-low-symbolic" .. icon_extension,
  muted = icon_theme .. "/audio-volume-muted-symbolic" .. icon_extension
}

local widget = wibox.widget.imagebox()
widget.tooltip = awful.tooltip({ objects = { widget },})

function widget:update_appearance(v)
  local i, msg

  if v == "Muted" then
    msg = v
    i = icon.muted
  else
    v = v == "Unmuted" and self.sink:get_volume_percent()[1] or tonumber(v)
    msg = string.format("%d%%", v)
    if v <= 33 then
      i = icon.low
    elseif v <= 66 then
      i = icon.med
    else
      i = icon.high
    end
  end

  self:set_image(i)
  self.tooltip:set_text(msg)

end

function widget.notify(v)
  local msg = tonumber(v) and string.format("%d%%", v) or v
  naughty.notify({text=msg, timeout=1})
end

function widget:update_sink(object_path)
  self.sink = pulse.get_sink(self.connection, object_path)
end

function widget.volume_up()
  if not widget.sink:is_muted() then
    widget.sink:volume_up()
  end
end

function widget.volume_down()
  if not widget.sink:is_muted() then
    widget.sink:volume_down()
  end
end

function widget.toggle_muted()
  widget.sink:toggle_muted()
end

function widget:kill_client()
  if type(self.server_pid) == "number" then
    awful.spawn("kill -TERM " .. self.server_pid)
  end
end

function widget:run_client()

  local pid = awful.spawn.with_line_callback(
    [[lua -e 'require("pulseaudio_widget_client")']],
    {
      stdout = function (line)
        local v, found, _

        v, found = line:gsub("^(VolumeUpdated:%s+)(%d)", "%2")
        if found ~= 0 then
          self:update_appearance(v)
          widget.notify(v)
        end

        v, found = line:gsub("^(MuteUpdated:%s+)(%w)", "%2")
        if found ~= 0 then
          self:update_appearance(v)
          widget.notify(v)
        end

        v, found = line:gsub("^(NewSink:%s+)(/.*%w)", "%2")
        if found ~=0 then
          self:update_sink(v)
          local volume = self.sink:is_muted() and "Muted" or self.sink:get_volume_percent()[1]
          self:update_appearance(volume)
          widget.notify(volume)
        end
      end
  })

  self.server_pid = pid
end

widget:buttons(gears.table.join(
                 awful.button({ }, 1, widget.toggle_muted),
                 awful.button({ }, 3, function () awful.spawn(widget.mixer) end),
                 awful.button({ }, 4, widget.volume_up),
                 awful.button({ }, 5, widget.volume_down)))

awesome.connect_signal("exit", function () widget:kill_client() end)

function widget:init()
  local status, address = pcall(pulse.get_address)
  if not status then
    naughty.notify({title="Error while loading the PulseAudio widget",
                    text=address,
                    preset=naughty.config.presets.critical})
    return self
  end

  self.mixer = "pavucontrol"

  self.connection = pulse.get_connection(address)
  self.core = pulse.get_core(self.connection)
  local sink_path = assert(self.core:get_sinks()[1], "No sinks found")

  self:update_sink(sink_path)
  local volume = self.sink:is_muted() and "Muted" or self.sink:get_volume_percent()[1]
  self:update_appearance(volume)

  self:run_client()

  self.__index = self

  return self
end

return widget:init()
