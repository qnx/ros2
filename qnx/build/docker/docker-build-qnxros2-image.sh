#!/bin/bash

if [ ! -d ~/ros2_workspace/ros2/qnx/build/docker/qnx800 ]; then
	echo "copy QNX SDP into the ~/ros2_workspace/ros2/qnx/build/docker directory"
	exit 1
fi

docker build -t qnxros2_humble \
  --build-arg USER_NAME=$(id --user --name) \
  --build-arg GROUP_NAME=$(id --group --name) \
  --build-arg USER_ID=$(id --user) \
  --build-arg GROUP_ID=$(id --group) .
