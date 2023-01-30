
FROM docker.io/matthiasbock/debian:bullseye-amd64

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get update -q && \
    sudo apt-get -qy install time make gcc g++ clang llvm xvfb && \
    sudo apt-get -qy install libgl1 vtk7 libvtk7-dev libvtk7-qt-dev python3-pip python3-vtk7 && \
    sudo pip3 install vtk && \
    sudo pip3 install pyvista pyvirtualdisplay gmsh && \
    sudo apt-get clean && \
    sudo { find /lost+found /run /tmp /root/.bash_history /home/*/.bash_history \
      /usr/share/doc /usr/local/share/doc /usr/share/icons /usr/share/man /usr/share/vim/vim81/doc \
     /var/cache/apt/archives /var/cache/fonts /var/cache/man /var/lib/apt/lists /var/lock \
     /var/log /var/mail /var/run /var/spool /var/tmp -type f -exec rm -fv {} \; || true }
