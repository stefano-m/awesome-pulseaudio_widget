--[[
  Copyright 2016 Stefano Mazzucco <stefano AT curso DOT re>
  Copyright 2013 mokasin

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

  Although heavily modified, this program is derived from the
  [Awesome Pulseaudio Widget (APW)](https://github.com/mokasin/apw)
]]

local awful = require("awful")

local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local ldbus = require("ldbus_api")
local pulse = require("pulseaudio_dbus")

local spawn_with_shell = awful.util.spawn_with_shell or awful.spawn.with_shell
local icon_theme = "/usr/share/icons/Adwaita/scalable/status"
local icon_extension = ".svg"

icon_theme = beautiful.pulse_icon_theme or icon_theme
icon_extension = beautiful.pulse_icon_extension or icon_extension

local widget = wibox.widget.imagebox()
local widget_t = awful.tooltip({ objects = { widget },})

local icon = {
  high = icon_theme .. "/audio-volume-high-symbolic" .. icon_extension,
  med = icon_theme .. "/audio-volume-medium-symbolic" .. icon_extension,
  low = icon_theme .. "/audio-volume-low-symbolic" .. icon_extension,
  muted = icon_theme .. "/audio-volume-muted-symbolic" .. icon_extension
}

local status, address = pcall(pulse.get_address)
if not status then
  naughty.notify({title="Error while loading PulseAudio",
                  text=address,
                  preset=naughty.config.presets.critical})
  return widget
end

pulse.listen_for_signal(address, "org.PulseAudio.Core1", "NewSink")
local watcher = ldbus.api.watch(address)

local function _get_volume_as_string()
  local volume = {}

  for _, v in ipairs(widget.sink.volume) do
    volume[v] = 0
  end

  local msg = ""
  for k, _ in pairs(volume) do
    msg = msg .. k .. "%"
  end

  return msg
end

local function _update_sink_if_changed()
  local sink_added = watcher()
  if sink_added ~= "no_answer" then
   local new_sink = assert(pulse.get_sinks(address)[1])
    widget.sink = pulse.Sink:new(address, new_sink)
  end
end

local function _update_appearance()
  -- Get first channel only.
  local v = widget.sink.volume[1]
  local i
  if widget.sink.muted then
    i = icon.muted
  elseif v <= 33 then
    i = icon.low
  elseif v <= 66 then
    i = icon.med
  else
    i = icon.high
  end

  widget:set_image(i)
  widget_t:set_text(_get_volume_as_string())
end

local function _init()
  local first_sink = assert(pulse.get_sinks(address)[1])
  widget.mixer = "pavucontrol"
  widget.sink = pulse.Sink:new(address, first_sink)
  _update_appearance()
end

local function _notify_volume()
  naughty.notify({
      text='Volume: ' .. _get_volume_as_string(),
      timeout=1,
  })
end

function widget.volume_up()
  _update_sink_if_changed()
  if not widget.sink.muted then
    widget.sink:volume_up()
    _update_appearance()
    _notify_volume()
  end
end

function widget.volume_down()
  _update_sink_if_changed()
  if not widget.sink.muted then
    widget.sink:volume_down()
    _update_appearance()
    _notify_volume()
  end
end

function widget.toggle_muted()
  _update_sink_if_changed()
  widget.sink:toggle_muted()
  _update_appearance()
end

function widget.launch_mixer()
  spawn_with_shell(widget.mixer)
end

-- register mouse button actions
widget:buttons(awful.util.table.join(
                 awful.button({ }, 1, widget.toggle_muted),
                 awful.button({ }, 3, widget.launch_mixer),
                 awful.button({ }, 4, widget.volume_up),
                 awful.button({ }, 5, widget.volume_down)))

-- initialize
_init()

return widget
