# proton
Docker image for hosting dedicated servers that run on Proton. This uses Ubuntu as a base image and installs [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD), [GloriousEggroll's Proton build](https://github.com/GloriousEggroll/proton-ge-custom), and [rcon-cli](https://github.com/gorcon/rcon-cli). Use this as a base image and write your own script to be called by `CMD` to start/manage your game server. You must set the build argument `GAME_APPID` to the Steam AppID of the game you wish to host. By default, the container will be run as a non-root user named `steam` and the game will be installed to `/opt/game` - this is set through build arguments `USER` and `GAME_PATH`.
