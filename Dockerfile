FROM ubuntu:latest

env DEBIAN_FRONTEND=noninteractive

# Install scrot for screenshots, wine for running bgb, xvfb for fake display
RUN apt-get update && apt-get install --assume-yes scrot wine64 xvfb

# Install 32-bit wine
RUN dpkg --add-architecture i386 && apt-get update && apt-get install --assume-yes wine32

# Install node
RUN apt-get install --assume-yes curl imagemagick

COPY tools/bgb.exe /tools/
COPY entrypoint.sh /tools/
ENTRYPOINT /tools/entrypoint.sh
