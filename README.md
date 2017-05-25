# A widget for the Awesome Window Manager 4.x to control the volume

A widget for the Awesome Window Manager (version 4.x) that
uses [pulseaudio_dbus](https://github.com/stefano-m/lua-pulseaudio_dbus) to
control your audio devices.

## A note about PulseAudio, DBus and Awesome

The Pulseaudio DBus interface requires clients to use peer-to-peer connection
rather than the usual system/session buses. This means that we *cannot* use the
Awesome DBus API that supports *only* system and session buses.

The solution is to run an external client application to establish a
peer-to-peer connection and listen to DBus signals. The output of the client is
read by the widget that updates itself accordingly. This is done thanks
to
[`awful.spawn.with_line_callback`](https://awesomewm.org/apidoc/libraries/awful.spawn.html#with_line_callback).

# Requirements

In addition to the requirements listed in the `rockspec` file, you will need
the [Awesome Window Manager](https://awesomewm.org) *version 4.x* and
PulseAudio with DBus enabled.

To enable DBus in PulseAudio, ensure that the line

    load-module module-dbus-protocol

is present in `/etc/pulse/default.pa` or `~/.config/pulse/default.pa`

# Installation

The easiest way to install this widget is to use `luarocks`:

    luarocks install pulseaudio_widget

You can use the `--local` option if you don't want or can't install
it system-wide

This will ensure that all its dependencies are installed.


# Configuration

The widget displays volume icons that are searched in the folder defined by
`beautiful.pulse_icon_theme` with extension `beautiful.pulse_icon_extension`.
The default is to look into `"/usr/share/icons/Adwaita/scalable/status"` for
icons whose extension is `".svg"`.

Specifically, you will need icons named:

* `audio-volume-high-symbolic`
* `audio-volume-medium-symbolic`
* `audio-volume-low-symbolic`
* `audio-volume-muted-symbolic`

# Mouse controls

When the widget is focused:

* Scroll: controls the volume
* Left button: toggles mute
* Right button: launches mixer (`mixer` field of the widget table, defaults to
  `pavucontrol`)

# Usage

Add the following to your `~/.config/awesome/rc.lua`:

Require the module:

``` lua
-- require *after* `beautiful.init` or the theme will be inconsistent!
local pulse = require("pulseaudio_widget")

```

Add the widget to your layout:

``` lua
s.mywibox:setup {
  layout = wibox.layout.align.horizontal,
  { -- Left widgets },
  s.mytasklist, -- Middle widget
  { -- Right widgets
    pulse
  }
}
```

Finally add some keyboard shortcuts to control the volume:

``` lua
awful.util.table.join(
  awful.key({ }, "XF86AudioRaiseVolume", pulse.volume_up),
  awful.key({ }, "XF86AudioLowerVolume", pulse.volume_down),
  awful.key({ }, "XF86AudioMute",  pulse.toggle_muted)
)
```

# Credits

This program was inspired by
the [Awesome Pulseaudio Widget (APW)](https://github.com/mokasin/apw).
