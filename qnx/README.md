# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

## Use Docker to build

```bash
# Create a workspace
mkdir -p ~/ros2_workspace && cd ~/ros2_workspace

# Clone googletest
git clone -b qnx-sdp8-main https://github.com/qnx/googletest

# Clone ros2
git clone -b qnx-sdp8-humble-release https://github.com/qnx/ros2

# Copy your SDP 8.0 to where the Dockerfile is
# Your qnx800 SDP is assumed to be at ~/qnx800
cp -r ~/qnx800 ~/ros2_workspace/ros2/qnx/build/docker

# Build the Docker image
cd  ~/ros2_workspace/ros2/qnx/build/docker
./docker-build-qnxros2-image.sh

# Create a Docker container using the built image
./docker-create-container.sh

# Once you're in the image, set up environment variables
. ./env/bin/activate
. ./qnx800/qnxsdp-env.sh

# Build googletest
cd ~/ros2_workspace/googletest
JLEVEL=4 make  -C qnx/build install

# Import ros2 packages
cd ~/ros2_workspace/ros2
mkdir -p src
vcs import src < ros2.repos

# Run required scripts
./qnx/build/scripts/colcon-ignore.sh
./qnx/build/scripts/patch.sh

# Build ros2
./qnx/build/scripts/build-ros2.sh
```

## Build on host without using Docker

```bash
# Create a workspace
mkdir -p ~/ros2_workspace && cd ~/ros2_workspace

# Build and install googletest
git clone -b qnx-sdp8-main https://github.com/qnx/googletest && cd googletest
JLEVEL=4 make -C qnx/build install
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

# Run scripts to build and install ros2
./qnx/build/scripts/colcon-ignore.sh
./qnx/build/scripts/patch.sh
./qnx/build/scripts/build-ros2.sh
```
