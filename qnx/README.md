Documentation for QNX ROS2 Humble https://ros2-qnx-documentation.readthedocs.io/en/humble/

# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

Currently the port is supported for QNX SDP 7.1 and 8.0.

We recommend that you use Docker to build ros2 for QNX to ensure the build environment consistency.

## Use Docker to build

Don't forget to source qnxsdp-env.sh in your SDP.

```bash
# Set QNX_SDP_VERSION to be qnx800 for SDP 8.0 or qnx710 for SDP 7.1
export QNX_SDP_VERSION=qnx800

# source qnxsdp-env.sh in your SDP
source <path-to-qnxsdp-env.sh>/qnxsdp-env.sh

# Create a workspace
mkdir -p ~/ros2_workspace && cd ~/ros2_workspace

# Clone googletest
git clone https://github.com/qnx/googletest && cd googletest
git checkout 792c30ac6226e95ba4e08ded16bcccb011bd9f76
cd -

# Clone ros2
git clone -b qnx-sdp8-humble-release https://github.com/qnx/ros2

# Build the Docker image
cd  ~/ros2_workspace/ros2/qnx/build/docker
./docker-build-qnxros2-image.sh

# Create a Docker container using the built image
./docker-create-container.sh

# Once you're in the image, set up environment variables
. ./env/bin/activate
. ./$QNX_SDP_VERSION/qnxsdp-env.sh

# Import ros2 packages
cd ~/ros2_workspace/ros2
mkdir -p src
vcs import src < ros2.repos

# Run required scripts
./qnx/build/scripts/colcon-ignore.sh
./qnx/build/scripts/patch.sh

# Build googletest
cd ~/ros2_workspace/googletest
JLEVEL=4 make  -C qnx/build install

# Build ros2
cd ~/ros2_workspace/ros2
./qnx/build/scripts/build-ros2.sh
```

After the build completes, ros2_humble.tar.gz will be created at $QNX_TARGET/$CPUVARDIR/ros2_humble.tar.gz

## Build on host without using Docker

Don't forget to source qnxsdp-env.sh in your SDP.

```bash
# Set QNX_SDP_VERSION to be qnx800 for SDP 8.0 or qnx710 for SDP 7.1
export QNX_SDP_VERSION=qnx800

# Create a workspace
mkdir -p ~/ros2_workspace && cd ~/ros2_workspace

# Build and install googletest
git clone https://github.com/qnx/googletest && cd googletest
git checkout 792c30ac6226e95ba4e08ded16bcccb011bd9f76
cd -

# Clone ros2
git clone -b qnx-sdp8-humble-release https://github.com/qnx/ros2 && cd ros2

# Install python 3.11
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt-get install -y python3.11-dev python3.11-venv python3.11-distutils software-properties-common rename

# Create a python 3.11 virtual environment
python3.11 -m venv env
source env/bin/activate

# Install required python packages
pip install -U \
  pip \
  empy \
  lark \
  Cython \
  wheel \
  colcon-common-extensions \
  vcstool \
  catkin_pkg \
  argcomplete \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  pytest-repeat \
  pytest-rerunfailures \
  pytest

# Import ros2 packages
mkdir -p src
vcs import src < ros2.repos

# Run scripts to ignore some packages and apply QNX patches
./qnx/build/scripts/colcon-ignore.sh
./qnx/build/scripts/patch.sh

# Set LD_PRELOAD to the host libzstd.so for x86_64 SDP 7.1 builds
export LD_PRELOAD=$LD_PRELOAD:/usr/lib/x86_64-linux-gnu/libzstd.so

# Build and install googletest
cd ~/ros2_workspace/googletest
JLEVEL=4 make -C qnx/build install

# Build ros2
cd ~/ros2_workspace/ros2
./qnx/build/scripts/build-ros2.sh
```
