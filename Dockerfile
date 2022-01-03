FROM ubuntu:latest

env DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --assume-yes scrot wine64 xvfb

RUN dpkg --add-architecture i386 && apt-get update && apt-get install --assume-yes wine32

COPY tools/bgb.exe /tools/
COPY entrypoint.sh /tools/
ENTRYPOINT /tools/entrypoint.sh
