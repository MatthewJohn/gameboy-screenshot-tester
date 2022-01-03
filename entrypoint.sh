#!/bin/bash

set -x
set -e

if [ "$MOUNT_DIR" == "" ]
then
    MOUNT_DIR=/work
fi

if [ "$DELAY" == "" ]
then
    DELAY=15
fi

if [ "$SOURCE_IMAGE" == "" ]
then
    SOURCE_IMAGE=source.jpg
fi

if [ "$REPLAY_FILE" == "" ]
then
    REPLAY_FILE=replay.dem
fi

if [ "$BGB_TIMEOUT" == "" ]
then
    BGB_TIMEOUT=20
fi

if [ "$ROM_FILE" == "" ]
then
    ROM_FILE="gb.rom"
fi

if [ "$OUTPUT_IMAGE" == "" ]
then
    OUTPUT_IMAGE=output.jpg
fi

if [ "$COMPARISON_IMAGE" == "" ]
then
    COMPARISON_IMAGE=comparison.jpg
fi

if [ "$THRESHOLD" == "" ]
then
    THRESHOLD=95
fi

# Start display
Xvfb :99 -screen 0 600x400x16 +extension GLX +render -noreset &
xvfb_pid=$!

# Wait for screen to start
sleep 10

export DISPLAY=:99

# Start scot to take screenhot
scrot --delay=$DELAY $MOUNT_DIR/$OUTPUT_IMAGE &

set +e
# Start BGB with timeout
timeout --signal=TERM ${BGB_TIMEOUT}s wine64 /tools/bgb.exe bgb -runfast -rom $MOUNT_DIR/$ROM_FILE -demoplay $MOUNT_DIR/$REPLAY_FILE -setting 'WaveOut=0'

# Compare images
compare -verbose -metric mae $MOUNT_DIR/$SOURCE_IMAGE $MOUNT_DIR/$OUTPUT_IMAGE -compose Src $MOUNT_DIR/$COMPARISON_IMAGE

comparison_failed=$?

if [ "$comparison_failed" != "0" ]
then
    echo Image comparison failed!
    exit 1
fi

