package = "pulseaudio_widget"
version = "devel-1"
source = {
  url = "git://github.com/stefano-m/awesome-pulseaudio_widget",
  tag = "master"
}
description = {
  summary = "A PulseAudio widget for the Awesome Window Manager",
  detailed = [[
    Control your audio in the Awesome with PulseAudio and DBus.
    ]],
  homepage = "https://github.com/stefano-m/awesome-pulseaudio_widget",
  license = "GPL v3"
}
dependencies = {
  "lua >= 5.1",
  "pulseaudio_dbus",
}
supported_platforms = { "linux" }
build = {
  type = "builtin",
  modules = { pulseaudio_widget = "pulseaudio_widget.lua",
              pulseaudio_widget_client = "pulseaudio_widget_client.lua"},
}
