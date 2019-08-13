# Always start from an debian slim distro.
FROM debian:stable-slim
MAINTAINER Sakis Panou "sakis.panou@gmail.com"

# Update the Package Database
RUN apt-get update

# Install all the packages we need for a full yocto build.
RUN apt-get -y install git-core build-essential wget diffstat gcc-multilib debianutils xterm sudo locales locales-all autoconf automake vim

# Set the Locales needed by the Yocto packages
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Create the user builder and give it the passworld builder
RUN useradd -rm -d /home/builder -s /bin/bash -g root -G sudo -u 1000 builder
RUN echo builder:builder | chpasswd

# Change the default user to builder
USER builder

# Set the working home directory to the one for builder
WORKDIR /home/builder

#Set up the Git Acount
RUN git config --global user.name "builder"
RUN git config --global user.email "builder@xilinx.com"

# Download Accelleras' SystemC 2.3.3 Library and Build it.
RUN mkdir sources \
    && cd sources \
    && wget https://www.accellera.org/images/downloads/standards/systemc/systemc-2.3.3.tar.gz \
    && tar -xzf systemc-2.3.3.tar.gz \
    && cd systemc-2.3.3 \
    && mkdir objdir \
    && cd objdir \
    && ../configure CXXFLAGS="-DSC_CPLUSPLUS=201103L -std=c++11" --prefix=/home/builder/systemc-2.3.3 \
    && make -j4 \
    && make install \
    && make distclean \
    && cd .. \
    && rm -Rf objdir \
    && cd .. \
    && tar -cjf systemc-2.3.3.tar.bz2 systemc-2.3.3/ \
    && rm -Rf systemc-2.3.3/ \
    && rm systemc-2.3.3.tar.gz

CMD ["bash"]
