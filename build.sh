#!/bin/bash

# Paths to godot binaries
GODOT_HEADLESS=./godot_headless
GODOT_SERVER=./godot_server

PROJECT=./src/project.godot
OUTDIR=./game

if [ ! -f $PROJECT ]; then
  echo "ERROR: Source project not found!"
  exit 1
fi

if [ ! -d $OUTDIR ]; then
  echo "Creating output directory"
  mkdir -p $OUTDIR
fi

echo "Exporting project"
$GODOT_HEADLESS --quiet --export HTML5 ../game/pixeltanks.html ./src/project.godot
echo "Launching server"
$GODOT_SERVER --main-pack ./game/pixeltanks.pck
