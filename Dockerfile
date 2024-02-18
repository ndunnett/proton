FROM ubuntu:jammy

# setup locale
RUN set -eux; \
    DEBIAN_FRONTEND="noninteractive"; \
    apt-get update; \
    apt-get install --no-install-recommends -y locales; \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen; \
    dpkg-reconfigure --frontend=noninteractive locales

# update system and install packages
RUN set -eux; \
    DEBIAN_FRONTEND="noninteractive"; \
    dpkg --add-architecture i386; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y tini wget software-properties-common

# install steamcmd
RUN set -eux; \
    DEBIAN_FRONTEND="noninteractive"; \
    add-apt-repository multiverse; \
    echo steam steam/question select "I AGREE" | debconf-set-selections; \
    echo steam steam/license note '' | debconf-set-selections; \
    apt-get update; \
    apt-get install -y steamcmd

# install GloriousEggroll's proton build
RUN set -eux; \
    PROTON_GH_API="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"; \
    PROTON_TARBALL="$(wget -qO - "$PROTON_GH_API" | grep browser_download_url | cut -d\" -f4 | egrep .tar.gz)"; \
    wget -qO - "$PROTON_TARBALL" | tar -xz -C /usr/local/bin --strip-components=1

# install rcon cli
RUN set -eux; \
    RCON_GH_API="https://api.github.com/repos/gorcon/rcon-cli/releases/latest"; \
    RCON_TARBALL="$(wget -qO - "$RCON_GH_API" | grep tarball_url | cut -d\" -f4)"; \
    wget -qO - "$RCON_TARBALL" | tar -xz -C /usr/local/bin --strip-components=1

# clean up
RUN set -eux; \
    DEBIAN_FRONTEND="noninteractive"; \
    apt-get clean -y; \
    apt-get autoclean -y; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*

# set up environment
ARG USER=steam
ARG GAME_PATH=/opt/game
ARG GAME_APPID
ENV USER="$USER" GAME_PATH="$GAME_PATH" GAME_APPID="$GAME_APPID"
ENV HOME="/home/$USER" PATH="/usr/games:$PATH" SRCDS_APPID="$GAME_APPID"
ENV STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"
ENV STEAM_COMPAT_DATA_PATH="$STEAM_COMPAT_CLIENT_INSTALL_PATH/steamapps/compatdata/$SRCDS_APPID"

# create new user and set permissions
RUN set -eux; \
    useradd --create-home "$USER"; \
    mkdir -p "$GAME_PATH" && chown -R "$USER:$USER" "$GAME_PATH"; \
    mkdir -p "$STEAM_COMPAT_DATA_PATH" && chown -R "$USER:$USER" "$STEAM_COMPAT_DATA_PATH"

# set up entrypoint
WORKDIR "$GAME_PATH"
COPY --chmod=755 entrypoint.sh /opt/entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "--", "/opt/entrypoint.sh"]
CMD ["sleep", "infinity"]
USER "$USER"
