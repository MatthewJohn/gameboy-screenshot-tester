FROM ubuntu:20.04

env DEBIAN_FRONTEND=noninteractive

# Install wine for running bgb, xvfb for fake display
RUN apt-get update && apt-get install --assume-yes wine64 xvfb wget unzip

# Donwload BGB
RUN cd /tmp && wget https://bgb.bircd.org/bgb.zip && unzip bgb.zip

# Install 32-bit wine
RUN dpkg --add-architecture i386 && apt-get update && apt-get install --assume-yes wine32

# Install imagemagick
RUN apt-get install --assume-yes curl imagemagick

COPY . /app/

RUN mv /tmp/bgb.* /app/tools/

ENTRYPOINT /app/entrypoint.sh
