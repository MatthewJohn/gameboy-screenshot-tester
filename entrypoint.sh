#!/bin/bash

if [ "$MOUNT_DIR" == "" ]
then
    MOUNT_DIR=/work
fi

if [ "$DELAY" == "" ]
then
    DELAY=30
fi

if [ "$INPUT_FILE" == "" ]
then
    INPUT_FILE=comparison.jpg
fi

if [ "$REPLAY_FILE" == "" ]
then
    REPLAY_FILE=replay.dem
fi

if [ "$BGB_TIMEOUT" == "" ]
then
    BGB_TIMEOUT=45s
fi

if [ "$ROM_FILE" == "" ]
then
    ROM_FILE="gb.rom"
fi

if [ "$OUTPUT_SCREENSHOT" == "" ]
then
    OUTPUT_SCREENSHOT=output.jpg
fi

# Start display
Xvfb :99 -screen 0 1024x768x16 +extension GLX +render -noreset &
xvfb_pid=$!

# Wait for screen to start
sleep 10

export DISPLAY=:99

# Start scot to take screenhot
scrot --delay=$DELAY --focused $MOUNT_DIR/$OUTPUT_SCREENSHOT &

# Start BGB with timeout
timeout $BGB_TIMEOUT wine64 /tools/bgb.exe bgb -rom $MOUNT_DIR/$ROM_FILE -demoplay $MOUNT_DIR/$REPLAY_FILE

wait
