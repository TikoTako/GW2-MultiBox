<h1 align="center"><img src="Graphics/GW2MB150.png" alt="Program Icon"><br />GW2-MultiBox</h1>

![GitHub Issues](https://img.shields.io/github/stars/TikoTako/GW2-MultiBox?color=FFDD00&style=flat-square)
![GitHub Issues](https://img.shields.io/github/issues/TikoTako/GW2-MultiBox?color=FFAA00&style=flat-square)
![GitHub Issues](https://img.shields.io/github/issues-closed/TikoTako/GW2-MultiBox?color=99FF99&style=flat-square)
![GitHub release](https://img.shields.io/github/release/TikoTako/GW2-MultiBox?include_prereleases=&sort=semver&color=00BFFF&style=flat-square)
[![GPLv3 License](https://img.shields.io/badge/Delphi-10.4.2%20CE-FF4500.svg?style=flat-square)](https://www.gnu.org/licenses/)
[![GPLv3 License](https://img.shields.io/badge/License-GPLv3-7B68EE.svg?style=flat-square)](https://www.gnu.org/licenses/) <br/>
Simple program that open multiple "Guild Wars 2" clients. <br/>
Multibox is allowed as stated >[HERE](https://help.guildwars2.com/hc/en-us/articles/360013658134-Policy-Dual-or-Multi-Boxing)< <br/>
Command line arguments can be found in the wiki >[HERE](https://wiki.guildwars2.com/wiki/Command_line_arguments)<

## Features
- Start the game from any path.
- Automatic find and kill the game mutex.
- Forward the command line arguments to the game.
- Simple setup for multiple settings by using windows shortcuts.

## TODO
1. GUI mode.
2. Auto-Login.

## Usage
Command line arguments:

```-ShowDebugWindow``` Show the debug output in both Console and GUI mode.<br />
```-UseDebugClient``` Use the dummy client (i made it for fast testing).<br />
```-ConsoleMode``` Start in Console mode which accept these additional parameters:<br />
- ```-UseClientPath:"path"``` Path of the game exe.
- ```-Params:"-param1 -param2"``` Command line arguments for the client.

#### Some examples:	
```GW2MB.exe -ShowDebugWindow``` Open in GUI mode with the debug window.<br />
```GW2MB.exe -ConsoleMode -Params:"-nomusic -nosound -whatever"``` Open in console mode and forward the arguments to the client.<br />
```GW2MB.exe -ConsoleMode -UseClientPath:"g:\ames\topkek\gw2-64.exe" -Params:"-mumble potato"``` Same as above but point at another another path for the exe.<br />
```GW2MB.exe -ConsoleMode -ShowDebugWindow -Params:"-dx9" -UseClientPath:"c:\gamz\gw2-64.exe"``` Same as above plus show the debug window.<br />


#### NOTE:	
```-UseClientPath``` is ignored if ```-UseDebugClient``` is used.<br />

## Dependencies
This project utilize [LoggerPro](https://github.com/danieleteti/loggerpro) to log on file/console.

## License
GW2-MultiBox (GW2MB) is licensed under the terms of the [GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0.html).<br />
DummyClient is licensed under the terms of the **MIT License** (is in the dpr code at beginning)

"Guild Wars 2" (c) 2023 ArenaNet, LLC. All rights reserved.

All trademarks are the property of their respective owners.