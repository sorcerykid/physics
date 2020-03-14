Interactive Physics Mod v1.1
By Leslie E. Krause

Interactive Physics is a completely Lua-driven physics simulator for Minetest based on a
fork of my Athletics mod.

The library handles quasi-realistic physical interactions between entities vs. players 
and entities vs. nodes (including air and water) -- sufficient to suspend disbelief for 
purposes of gameplay, but also with minimal performance costs incurred.

Besides the API, a control panel interface is available to manually override the physical 
properties of solid and liquid nodes as well as entities directly in-game.

For more information, please refer to the forum topic:
https://forum.minetest.net/viewtopic.php?f=9&t=22164


Compatibility
----------------------

Requires PR #9717 for Minetest 5.3-dev

Dependencies
----------------------

Default Mod
  https://github.com/minetest-game-mods/default

Configuration Panel Mod
  https://bitbucket.org/sorcerykid/config

ActiveFormspecs Mod (optional)
  https://bitbucket.org/sorcerykid/formspecs

Repository
----------------------

Browse source code...
  https://bitbucket.org/sorcerykid/physics

Download archive...
  https://bitbucket.org/sorcerykid/physics/get/master.zip
  https://bitbucket.org/sorcerykid/physics/get/master.tar.gz

Installation
----------------------

  1) Unzip the archive into the mods directory of your game.
  2) Rename the physics-master directory to "physics".
  3) Add "physics" as a dependency to any mods using the API.

Source Code License
----------------------------------------------------------

GNU Lesser General Public License v3 (LGPL-3.0)

Copyright (c) 2019-2020, Leslie E. Krause (leslie@searstower.org)

This program is free software; you can redistribute it and/or modify it under the terms of
the GNU Lesser General Public License as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

http://www.gnu.org/licenses/lgpl-2.1.html
