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
