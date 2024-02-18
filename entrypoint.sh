#!/bin/bash

set -eux

# install/update game
steamcmd +force_install_dir "$GAME_PATH" +login anonymous +app_update "$GAME_APPID" validate +quit

# run container cmd
exec "$@"
