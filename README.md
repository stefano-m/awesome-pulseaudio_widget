# A widget for the Awesome Window Manager to control the volume

This widget is a wrapper around the
[`pulseaudio_dbus`](https://luarocks.org/modules/stefano-m/pulseaudio_dbus)
library for the Awesome Window Manager.

# Requirements

In addition to the requirements listed in the `rockspec` file, you will need
the [Awesome Window Manager](https://awesomewm.org)
and PulseAudio with DBus enabled (for more information about this, see the
[`pulseaudio_dbus`](https://luarocks.org/modules/stefano-m/pulseaudio_dbus)
documentation).

You will also need the DBus headers (`dbus.h`) installed.
For example, Debian and Ubuntu provide the DBus headers with the `libdbus-1-dev`
package, Fedora, RedHad and CentOS provide them with the `dbus-devel` package,
while Arch provides them (alongside the binaries) with the `libdbus` package.

# Installation

## Using Luarocks

Probably, the easiest way to install this widget is to use `luarocks`:

    luarocks install pulseaudio_widget

You can use the `--local` option if you don't want or can't install
it system-wide

This will ensure that all its dependencies are installed.

### A note about ldbus

This module depens on the [`ldbus`](https://github.com/daurnimator/ldbus)
module that provides the low-level DBus bindings

    luarocks install --server=http://luarocks.org/manifests/daurnimator \
        ldbus \
        DBUS_INCDIR=/usr/include/dbus-1.0/ \
        DBUS_ARCH_INCDIR=/usr/lib/dbus-1.0/include

As usual, you can use the `--local` option if you don't want or can't install
it system-wide.

## From source

Alternatively, you can copy the `pulseaudio_widget.lua` file in your
`~/.config/awesome` folder. You will have to install all the dependencies
manually though (see the `rockspec` file for more information).

# Configuration

The widget displays volume icons that are searched in the folder defined
by `beautiful.pulse_icon_theme` with extension `beautiful.pulse_icon_extension`.
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
* Right button: launches mixer (defaults to `pavucontrol`)

# Usage
Add the following to your `~/.config/awesome/rc.lua`:

Require the module:

    -- require *after* `beautiful.init` or the theme will be inconsistent!
    local pulse = require("pulseaudio_widget")

Add the widget to your layout:

    right_layout:add(pulse)

Finally add some keyboard shortcuts to control the volume:

    awful.util.table.join(
      awful.key({ }, "XF86AudioRaiseVolume", pulse.volume_up),
      awful.key({ }, "XF86AudioLowerVolume", pulse.volume_down),
      awful.key({ }, "XF86AudioMute",  pulse.toggle_muted)
    )

# Credits

Although heavily modified, this program is derived from the
[Awesome Pulseaudio Widget (APW)](https://github.com/mokasin/apw).
