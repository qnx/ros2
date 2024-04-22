# Testing ros2 on QNX

ros2 for QNX is currently tested on Raspberry Pi 4 and QEMU.
ros2 has 300+ packages.

## Raspberry Pi 4 Testing

### Move ros2 to RPI4

Use scp to move ros2_humble.tar.gz to the target

```bash
scp ros2_humble.tar.gz root@<target-ip-address>:/
```

```bash
ssh root@<target-ip-address>
cd /
tar -xvzf ./ros2_humble.tar.gz
```

### Prepare Target

```bash
# Update system time
ntpdate -sb 0.pool.ntp.org 1.pool.ntp.org

# Install pip and packaging
mkdir -p /data
export TMPDIR=/data
python3 -m ensurepip
pip3 install packaging pyyaml lark
export PYTHONPATH=$PYTHONPATH:/opt/ros/humble/usr/lib/python3.11/site-packages/
```

### Run unit tests on the minimal set of packages
```bash
cd /opt/ros/humble
. /opt/ros/humble/setup.bash
cd /opt/ros/humble

export QNX_SDP_VERSION=qnx800
# export QNX_SDP_VERSION=qnx710

chmod +x ./qnxtest.sh
./qnxtest.sh
```

### Running the Listner Talker Demo on RPI4

Run listener in a terminal:

```bash
cd /opt/ros/humble
. /opt/ros/humble/setup.bash
python3 ./bin/ros2 run demo_nodes_cpp listener
```

Run talker in another terminal:

```bash
cd /opt/ros/humble
. /opt/ros/humble/setup.bash
python3 ./bin/ros2 run demo_nodes_cpp talker
```

## QEMU Testing

Currently not supported for a Docker build.

Start a QEMU instance:

```bash
source <path-to-qnxsdp-env.sh>/qnxsdp-env.sh
mkqnximage --extra-dirs=<repo_path>/qnx/test/mkqnximage --clean --run --force --python=yes  --sys-size=1024 --sys-inodes=10000  --data-inodes=10000  --data-size=1024 --test-ros2=<repo_path>
```

Install python packaging in the QEMU instance:
```bash
python3 -m ensurepip
export PATH=$PATH:/system/bin
pip3 install packaging colcon-common-extensions importlib-metadata importlib-resources lark-parser
```

source ros2's setup.sh in the QEMU instance:

```bash
cd /data/ros2/install/x86_64
export COLCON_CURRENT_PREFIX=/data/ros2/install/x86_64
export COLCON_PYTHON_EXECUTABLE=/system/xbin/python3
export PYTHONPATH=$PYTHONPATH:/data/ros2/install/x86_64/usr/lib/python3.11/site-packages
cp ./lib/libfastcdr.so.1.0.24  ./lib/libfastcdr.so.1
cp ./lib/libspdlog.so.1.8.2 ./lib/libspdlog.so.1
cp ./lib/libfastrtps.so.2.6.4 ./lib/libfastrtps.so.2.6
. ./setup.sh
```

### Run unit tests on the minimal set of packages
```bash
cd /data/ros2/install/x86_64
./qnxtest.sh
```

### Run the listener demo

```bash
python bin/ros2 run demo_nodes_cpp listener
```

### ssh into the QEMU instance to start another session and run the talker demo:

```bash
cd /data/ros2/install/x86_64
export COLCON_CURRENT_PREFIX=/data/ros2/install/x86_64
export COLCON_PYTHON_EXECUTABLE=/system/xbin/python3
export PYTHONPATH=$PYTHONPATH:/data/ros2/install/x86_64/usr/lib/python3.11/site-packages
. ./setup.sh

python bin/ros2 run demo_nodes_cpp talker
```

You should see the following output:

```console
# python bin/ros2 run demo_nodes_cpp listener
[INFO] [1704739320.554183163] [listener]: I heard: [Hello World: 1]
[INFO] [1704739321.553937507] [listener]: I heard: [Hello World: 2]
[INFO] [1704739322.554443870] [listener]: I heard: [Hello World: 3]
```

```console
# python ./bin/ros2 run demo_nodes_cpp talker 
[INFO] [1704739320.552586884] [talker]: Publishing: 'Hello World: 1'
[INFO] [1704739321.552590859] [talker]: Publishing: 'Hello World: 2'
[INFO] [1704739322.552594039] [talker]: Publishing: 'Hello World: 3'
```
