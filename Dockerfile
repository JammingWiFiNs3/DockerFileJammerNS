FROM ubuntu:16.04

RUN apt-get update 

# General dependencies

RUN apt-get install -y \
    git \
    wget \
    libgsl2 \
    tar \
    lbzip2 \
    libgsl-dev 

# Install Qmake 
RUN apt-get install -y \
    qtbase5-dev
    
# Python Component

RUN apt-get install -y \
    python3 \
    python3-dev \
    cmake \
    libc6-dev \
    g++-multilib
   


########NS-3#############



#Create working directory

RUN mkdir -p /usr/ns3
WORKDIR  /usr

#FETCH NS-3 source 

RUN wget https://www.nsnam.org/releases/ns-allinone-3.30.1.tar.bz2
RUN ls
RUN tar -xvf ns-allinone-3.30.1.tar.bz2

#Configure and compile NS3

RUN cd ns-allinone-3.30.1 && ./build.py --enable-examples --enable-tests

RUN ln -s /usr/ns-allinone-3.30.1/ns-3.30.1 /usr/ns3/

#Cleanup 

RUN apt-get clean && \
    rm -rf /var/lib/apt && \
    rm /usr/ns-allinone-3.30.1.tar.bz2

######## OpenAI #############

# install dependencies 

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:maarten-fonville/protobuf

RUN apt-get update 

# clone openAi

WORKDIR ns3/ns-3.30.1/src

RUN mkdir /backup
WORKDIR backup

RUN git clone https://github.com/tkn-tub/ns3-gym.git

RUN cp -R  ns3-gym/src/opengym ../

WORKDIR ../../

RUN ls

RUN apt-add-repository "deb http://in.archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse"
RUN apt-add-repository "deb http://archive.ubuntu.com/ubuntu focal main universe restricted multiverse"
RUN apt-get update 

RUN apt-get install -y \
    libzmq5 \
    libzmq5-dev \
    libprotobuf-dev \
    protobuf-compiler 

RUN ./waf configure
RUN ./waf build 

RUN apt-get install -y \
    python3-pip

RUN pip3  install ./src/opengym/model/ns3gym 

# clean 

WORKDIR src
RUN rm -R backup

# install Jammer 

WORKDIR wifi/model
RUN rm interference-helper.cc
RUN rm interference-helper.h
RUN rm wifi-phy.cc
RUN rm wifi-phy.h
RUN rm wifi-preamble.h

WORKDIR ../../

RUN git clone https://github.com/JammingWiFiNs3/JammingWifiModule.git
RUN cp -R  JammingWifiModule/jamming ./

RUN ls
WORKDIR jamming
RUN ls
RUN cp interference-helper.h ../wifi/model/
RUN cp interference-helper.cc ../wifi/model/
RUN cp wifi-phy.h ../wifi/model/
RUN cp wifi-phy.cc ../wifi/model/
RUN cp wifi-preamble.h ../wifi/model
RUN rm interference-helper.cc
RUN rm interference-helper.h
RUN rm wifi-phy.cc
RUN rm wifi-phy.h
RUN rm wifi-preamble.h

WORKDIR ../
RUN rm -R JammingWifiModule



WORKDIR ../

RUN ./waf configure
RUN ./waf build 
