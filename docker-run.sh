#! /bin/sh
#

# Fix for running GUI programs from within the docker container:
# Make xorg disable access control, i.e. let any x client connect to our
# server.
xhost +

docker run -it \
	--privileged \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v /dev/bus/usb:/dev/bus/usb \
	-e DISPLAY=unix$DISPLAY \
	-u `id -u` \
	--name riot \
	riotbuild
