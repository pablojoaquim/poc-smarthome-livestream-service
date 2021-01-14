FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# Installing the necessary software
RUN apt-get update && apt-get install -y --no-install-recommends \
        flex bison wget \
        xz-utils \
        libssl1.1 \
        make \
        nginx \
        build-essential \
        cmake \
    libmicrohttpd-dev \
    libjansson-dev \
    libssl-dev \
    libini-config-dev \
    libconfig-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \
    libopus-dev \
    libcurl4-openssl-dev \
    liblua5.3-dev \
    libogg-dev \
    libini-config-dev \
    libcollection-dev \
    pkg-config \
    gengetopt \
    libtool \
    autotools-dev \
    automake    

# Install the necessary for compiling Janus
RUN apt install -y python3-pip
RUN pip3 install ninja meson

COPY janus-gateway-req /usr/local/bin/janus-gateway-req

RUN cd /usr/local/bin/janus-gateway-req \
    && cd libsrtp \
    && ./configure --prefix=/usr --enable-openssl \
    && make shared_library \
    && make install
RUN cd /usr/local/bin/janus-gateway-req \
    && cd usrsctp \
    && ./bootstrap \
    && ./configure --prefix=/usr \
    && make \
    && make install
RUN cd /usr/local/bin/janus-gateway-req \
    && cd libnice \
    && meson --prefix=/usr build && ninja -C build && ninja -C build install
RUN cd /usr/local/bin/janus-gateway-req \
    && cd libwebsockets \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .. \
    && make \
    && make install

# Remove the unnecesary
RUN apt-get autoremove -y; apt-get clean; rm -rf /var/lib/apt/lists/*; rm /var/log/alternatives.log /var/log/apt/*; rm /var/log/* -r;

RUN mkdir /var/log/nginx

# Copy the hlsProxy, rtspProxy and the rtsp server
COPY live555/* /usr/local/bin/live555/

# Configure the nginx web server for serving the HLS video
COPY nginx/default /etc/nginx/sites-available/default

# Configure the Janus WebRTC server
COPY janus-gateway /usr/local/bin/janus-gateway
RUN cd /usr/local/bin/janus-gateway \
    && sh autogen.sh \
    && ./configure --prefix=/opt/janus --disable-rabbitmq --disable-mqtt \
    && make CFLAGS='-std=c99' \
    && make install \
    && make configs
RUN cp /usr/local/bin/janus-gateway/myconfig/* /opt/janus/etc/janus/
    
# Prepare the bash script for the execution of the several services
ADD start.sh /
RUN chmod +x /start.sh

# Expose the ports for the several services
EXPOSE 8554 554 8555
EXPOSE 80 8000 8080

# Entry point
CMD ["/start.sh"]
    


