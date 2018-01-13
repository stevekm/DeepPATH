# Docker container for DeepPATH
# docker run --privileged --rm -ti centos:6 /bin/bash
# docker run --rm -ti stevekm/deeppath /bin/bash
FROM centos:6

MAINTAINER Stephen M. Kelly

# update the system
RUN yum update
RUN yum groupinstall -y "development tools"
RUN yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel expat-devel
RUN yum install -y wget


# install Python
RUN wget http://python.org/ftp/python/3.5.3/Python-3.5.3.tar.xz
RUN tar xf Python-3.5.3.tar.xz
RUN cd Python-3.5.3 && ./configure --prefix=/usr/local --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib" && make && make altinstall
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3.5 get-pip.py

# update Python packages with the req's for this repo
ADD requirements.txt /requirements.txt
RUN pip3.5 install -r /requirements.txt

# install tcsh for compatibility
RUN yum install -y tcsh

# install CUDA - doesn't work
# wget http://developer.download.nvidia.com/compute/cuda/repos/rhel6/x86_64/cuda-repo-rhel6-9.1.85-1.x86_64.rpm
# rpm -i cuda-repo-rhel6-9.1.85-1.x86_64.rpm
# yum clean all
# yum install libvdpau
# yum install dkms
# yum install cuda
# --> Processing Dependency: dkms for package: 1:nvidia-kmod-387.26-2.el6.x86_64
# ---> Package xorg-x11-drv-nvidia-libs.x86_64 1:387.26-1.el6 will be installed
# --> Processing Dependency: libvdpau(x86-64) >= 0.5 for package: 1:xorg-x11-drv-nvidia-libs-387.26-1.el6.x86_64
# --> Finished Dependency Resolution
# Error: Package: 1:xorg-x11-drv-nvidia-libs-387.26-1.el6.x86_64 (cuda)
#            Requires: libvdpau(x86-64) >= 0.5
# Error: Package: 1:nvidia-kmod-387.26-2.el6.x86_64 (cuda)
#            Requires: dkms
#  You could try using --skip-broken to work around the problem
#  You could try running: rpm -Va --nofiles --nodigest
# [


# install TensorFlow
# https://blog.abysm.org/2016/06/building-tensorflow-centos-6/
# yum -y install java-1.8.0-openjdk-devel
# wget https://github.com/bazelbuild/bazel/releases/download/0.8.1/bazel-0.8.1-dist.zip
# unzip bazel-0.8.1-dist.zip -d bazel-0.8.1-dist
# cd bazel-0.8.1-dist && ./compile.sh
