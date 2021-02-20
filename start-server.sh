#!/bin/bash

PROJECT=./src/project.godot
OUTDIR=./game

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ ! -f $PROJECT ]; then
  echo "ERROR: Source project not found!"
  exit 1
fi

if [ ! -d $OUTDIR ]; then
  echo "Creating output directory"
  mkdir -p $OUTDIR
fi

echo "Exporting project"
docker-compose --profile export up
echo "Launching servers"
docker-compose --profile run up -d