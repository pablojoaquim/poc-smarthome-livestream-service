FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

# Installing the necessary software
RUN apt-get update && apt-get install -y --no-install-recommends \
        flex bison wget \
        xz-utils \
        libssl1.1 \
        make \
        nginx
        
# Remove the unnecesary
RUN apt-get autoremove -y; apt-get clean; rm -rf /var/lib/apt/lists/*; rm /var/log/alternatives.log /var/log/apt/*; rm /var/log/* -r;

RUN mkdir /var/log/nginx

# Copy the hlsProxy, rtspProxy and the rtsp server
COPY live555/* /usr/local/bin/live555/

#COPY index.html /var/www/html/
# Configure the nginx web server for serving the HLS video
COPY nginx/default /etc/nginx/sites-available/default

ADD start.sh /
RUN chmod +x /start.sh

EXPOSE 8554 554 8555
EXPOSE 80 8000 8080

CMD ["/start.sh"]
    


