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

]]

--[[-- This module is meant to be run with
  [`awful.spawn.with_line_callback`](https://awesomewm.org/apidoc/libraries/awful.spawn.html#with_line_callback).

  It starts a client that listens to the pulseaudio DBus server and prints to
  standard output wheter the volume or sinks (e.g. selecting the audio from the
  TV) change. The changes are printed to standard output and are used by the
  pulseaudio widget to change its appearance.

  We must do this because Awesome's DBus API can only connect to system and
  session buses, but pulseaudio uses its own per-user connection.

]]

local pulse = require("pulseaudio_dbus")
local GLib = require("lgi").GLib

local address = pulse.get_address()

local connection = pulse.get_connection(address)
local core = pulse.get_core(connection)
local sink = pulse.get_sink(connection, core.Sinks[1])

-- listen on ALL objects as sinks may change
core:ListenForSignal("org.PulseAudio.Core1.Device.VolumeUpdated", {})
core:ListenForSignal("org.PulseAudio.Core1.Device.MuteUpdated", {})

local function connect_sink(s)
  if s.signals.VolumeUpdated then
    s:connect_signal(
      function (self, vols)
        local v = math.ceil(tonumber(vols[1][1]) / self.BaseVolume * 100)
        print(string.format("VolumeUpdated: %s", v))
      end,
      "VolumeUpdated"
    )
  end

  if s.signals.MuteUpdated then
    s:connect_signal(
      function (_, is_mute)
        local m = is_mute[1] and "Muted" or "Unmuted"
        print(string.format("MuteUpdated: %s", m))
      end,
      "MuteUpdated"
    )
  end
end

connect_sink(sink)

core:ListenForSignal("org.PulseAudio.Core1.NewSink", {core.object_path})
core:connect_signal(
  function (_, newsinks)
    print(string.format("NewSink: %s", newsinks[1]))
    sink = pulse.get_sink(connection, newsinks[1])
    connect_sink(sink)
  end,
  "NewSink"
)

-- Start the client. Send SIGTERM to stop it.
print("Starting Awesome PulseAudio Widget Client")
GLib.MainLoop():run()
