#!/bin/bash

docker run -it \
  --net=host \
  --privileged \
  -v ~/.ssh:$HOME/.ssh \
  -v ~/.qnx:$HOME/.qnx \
  -v $HOME/.qnx:$HOME/.qnx \
  -v $HOME/ros2_workspace:$HOME/ros2_workspace \
  "qnxros2_humble:latest" /bin/bash
