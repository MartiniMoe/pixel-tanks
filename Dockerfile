FROM alpine:latest

# Variables
ENV GODOT_VERSION "3.2.3"
ENV GODOT_GAME_NAME "pixeltanks"

# Updates and installs
RUN apk update
RUN apk add --no-cache bash
RUN apk add --no-cache wget

# Allow this to run Godot
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.31-r0/glibc-2.31-r0.apk
RUN apk add --allow-untrusted glibc-2.31-r0.apk

# Download Godot, version is set from variables
RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_server.64.zip \
    && mkdir ~/.cache \
    && mkdir -p ~/.config/godot \
    && unzip Godot_v${GODOT_VERSION}-stable_linux_server.64.zip \
    && mv Godot_v${GODOT_VERSION}-stable_linux_server.64 /usr/local/bin/godot \
    && rm -f Godot_v${GODOT_VERSION}-stable_linux_server.64.zip

# Change to directory to run the app from
WORKDIR /project/game
CMD godot --main-pack ${GODOT_GAME_NAME}.pck
