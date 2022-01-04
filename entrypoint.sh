#!/bin/bash

set -x
set -e

if [ "$INPUT_DIR" == "" ]
then
    INPUT_DIR=/work
fi

if [ "$OUTPUT_DIR" == "" ]
then
    OUTPUT_DIR=/work
fi

if [ "$ROM_DIR" == "" ]
then
    ROM_DIR=/work
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

if [ "$INPUT_DIR" != "$OUTPUT_DIR" ]
then
  # Copy source image to output dir, if they are no the same
  cp $INPUT_DIR/$SOURCE_IMAGE $OUTPUT_DIR/
fi

# Start display
Xvfb :99 -screen 0 600x400x16 +extension GLX +render -noreset &
xvfb_pid=$!

# Wait for screen to start
sleep 10

export DISPLAY=:99

# Start scot to take screenhot
scrot --delay=$DELAY $OUTPUT_DIR/$OUTPUT_IMAGE &

set +e
# Start BGB with timeout
timeout --signal=TERM ${BGB_TIMEOUT}s wine64 /tools/bgb.exe bgb -runfast -rom $ROM_DIR/$ROM_FILE -demoplay $INPUT_DIR/$REPLAY_FILE -setting 'WaveOut=0'

# Compare images
compare -verbose -metric mae $INPUT_DIR/$SOURCE_IMAGE $OUTPUT_DIR/$OUTPUT_IMAGE -compose Src $OUTPUT_DIR/$COMPARISON_IMAGE

comparison_failed=$?

if [ "$comparison_failed" != "0" ]
then
    echo Image comparison failed!
    exit 1
fi

