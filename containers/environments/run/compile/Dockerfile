
FROM docker.io/matthiasbock/compute:base

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get update && \
    sudo apt-get install -q -y --no-install-recommends \
      git openssh-client bash-completion \
      gcc g++ make cmake cmake-extras cmake-curses-gui \
      clinfo llvm clang opencl-headers ocl-icd-libopencl1 ocl-icd-opencl-dev \
      libc6-dev libgl1 xvfb vtk7 libvtk7-dev libvtk7-qt-dev \
      python3-minimal python3-pip python3-vtk7 \
      gmsh && \
    sudo apt-get clean && \
    sudo pip3 install numpy pyvista pyvirtualdisplay pillow vtk gmsh
