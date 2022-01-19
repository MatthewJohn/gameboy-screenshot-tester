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

if [ "$SOURCE_IMAGE" == "" ]
then
    SOURCE_IMAGE=source.bmp
fi

if [ "$REPLAY_FILE" == "" ]
then
    REPLAY_FILE=replay.dem
fi

if [ "$ROM_FILE" == "" ]
then
    ROM_FILE="gb.rom"
fi

if [ "$OUTPUT_IMAGE" == "" ]
then
    OUTPUT_IMAGE=output.bmp
fi

if [ "$COMPARISON_IMAGE" == "" ]
then
    COMPARISON_IMAGE=comparison.jpg
fi

if [ "$GENERATE_SOURCE_IMAGE" == "" ]
then
  GENERATE_SOURCE_IMAGE=false
fi

# Remove output file if it exists
rm -f $OUTPUT_DIR/$OUTPUT_IMAGE

if [ "$INPUT_DIR" != "$OUTPUT_DIR" ]
then
  # Copy source image to output dir, if they are no the same
  cp $INPUT_DIR/$SOURCE_IMAGE $OUTPUT_DIR/
fi

# Start display
Xvfb :99 -screen 0 600x400x16 +extension GLX +render -noreset &
xvfb_pid=$!

# Wait for screen to start
sleep 3

export DISPLAY=:99

set +e
# Start BGB
wine64 /app/tools/bgb.exe -autoexit -runfast -rom $ROM_DIR/$ROM_FILE -demoplay $INPUT_DIR/$REPLAY_FILE -setting 'WaveOut=0' -setting 'RecordMovie=1'

mv $(ls -t -1 /app/tools/bgb*.bmp | head -1) $OUTPUT_DIR/$OUTPUT_IMAGE

# Check if just wanting to generate source image
if [ "$GENERATE_SOURCE_IMAGE" != "false" ]
then
  # Rename output to source
  echo "Generated source image: $INPUT_DIR/$SOURCE_IMAGE"
  mv $OUTPUT_DIR/$OUTPUT_IMAGE $INPUT_DIR/$SOURCE_IMAGE
  exit 0
fi

# Compare images
compare -verbose -metric mae $INPUT_DIR/$SOURCE_IMAGE $OUTPUT_DIR/$OUTPUT_IMAGE -compose Src $OUTPUT_DIR/$COMPARISON_IMAGE

comparison_failed=$?

if [ "$comparison_failed" != "0" ]
then
    echo Image comparison failed!
    exit 1
fi

