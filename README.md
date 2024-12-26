[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

<div align="center">
  <span align="center"> <img width="128" height="128" class="center" src="data/icons/128.png" alt="Tomato Icon"></span>
  <h1 align="center">Tomato</h1>
  <h3 align="center">A simple, usable, and efficient pomodoro app designed for elementary OS</h3>
</div>

![Screenshot](https://github.com/ellie-commons/tomato/blob/main/data/screenshot.png?raw=true)

## Keep focused on your work

Tomato is a clean, easy-to-use time manager based on Pomodoro technique. It breaks down work into intervals to keep you focused and allows you to rest during strategic periods to reward your progress. It is a must-have app if you need to avoid procrastination.

## Made for [elementary OS](https://elementary.io)

Tomato is designed and developed on and for [elementary OS](https://elementary.io). Installing via AppCenter ensures instant updates straight from us. Get it on AppCenter for the best experience.

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg?new)](https://appcenter.elementary.io/io.github.ellie_commons.tomato)

Versions of Tomato may have been built and made available elsewhere by third-parties. These builds may have modifications or changes and **are not provided nor supported by us**. The only supported version is distributed via AppCenter on elementary OS.

## Developing and Building

If you want to hack on and build Tomato yourself, you'll need the following dependencies:

- gtk4
- granite-7
- libadwaita-1
- libcanberra

Run meson `build` to configure the build environment. Change to the build directory and run ninja to build

```shell
meson build --prefix=/usr
cd build
ninja
```

To install, use `ninja install`, then execute with `io.github.ellie_commons.tomato`

```shell
ninja install
io.github.ellie_commons.app-generator
```

## Flatpak

Run `flatpak-builder` to configure the build environment, download dependencies, build, and install

```bash
flatpak-builder build io.github.ellie_commons.tomato.yml --user --install --force-clean --install-deps-from=appcenter
```

Then execute with

```bash
flatpak run io.github.ellie_commons.tomato
```

## Do you want to contribute?

Tomato is open source. You can contribute by reporting/fixing [bugs](https://github.com/ellie-commons/tomato/issues) or proposing/implementing new [features](https://github.com/ellie-commons/tomato/issues).

Before getting started, read the following guidelines:

- elementary OS [HIG](https://elementary.io/docs/human-interface-guidelines#human-interface-guidelines)
- elementary OS [developer guide](https://elementary.io/docs/code/getting-started#developer-sdk)