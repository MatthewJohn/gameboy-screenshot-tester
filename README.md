
# Gameboy Automated Screenshot Tester

Run a gameboy ROM in a docker container, running a bgb replay, capture screenshot and compare to expected screenshot.

## Building

Download BGB from https://bgb.bircd.org/ and place bgb.exe into `tools/` directory

```
docker build . -t gameboy-automated-screenshot-tester
```

## Generating replay file

Run BGB with rom and control game to generate replay:

```
bgb.exe ./gb.rom -demorec replay.dem
```

This can also be run within wine:

```
wine64 bgb.exe ./gb.rom -demorec replay.dem
```

## Running

Run docker container, mounting the current directory into `/work`

```
docker run -v `pwd`:/work gameboy-automated-screenshot-tester
```

## Configs

The following are configs that can be provided as environment arguments to `docker run` using `-e KEY=VALUE`

| Key  | Description | Default |
--- | --- | --- |
| `INPUT_DIR` | Directory within the container that the `SOURCE_IMAGE` is expected to be found | `/work` |
| `OUTPUT_DIR` | Directory within the container that the `OUTPUT_IMAGE` and `COMPARISON_IMAGE` will be saved | `/work` |
| `ROM_DIR` | Directory within the container that the `ROM_FILE` is expected to be found | `/work` |
| `SOURCE_IMAGE` | Filename of image to compare screenshot to | `source.bmp` |
| `REPLAY_FILE` | Name of the replay file, that is provided to BGB | `replay.dem` |
| `ROM_FILE` | Name of ROM file to run | `gb.rom` |
| `OUTPUT_IMAGE` | Filename of output screenshot | `output.bmp` |
| `COMPARISON_IMAGE` | Filename of comparison image that is generated | `comparison.jpg` |
| `GENERATE_SOURCE_IMAGE` | Whether to generate (and overwrite) source image. Set when creating new test. Set to `true` to enable | `false` |

## Example structure for running multiple tests

In this example, I 'bake' the tests into the gameboy-automated-screenshot-tester docker image.

The tests are then run in a container, which has the ROM in a volume and the screenshots are copied into this volume during the tests, so that they can be archived by the CI application.

### Directory structure

```
game.gb
test_1/source.bmp
test_2/source.bmp
test_3/source.bmp
...
```

Example script to run tests:
```
tests_failed=0

for test_name in test_{1..3}
do
  mkdir $test_name

  set +e
  docker run --rm \
    -e INPUT_DIR=/app/${test_name} \
    -e OUTPUT_DIR=/output/${test_name} \
    -e ROM_DIR=/output \
    -e ROM_FILE=game.gb \
    -v `pwd`:/output \
    stickrpg-automated-test-tool:latest
  if [ "$?" != "0" ]
  then
    tests_failed=1
  fi
  set -e
done

if [ "$tests_failed" != "0" ]
then
  echo One or more tests failed
  exit 1
fi

```

# License

This project is licensed under Apache License 2.0.

Please see `LICENSE` file for full license

