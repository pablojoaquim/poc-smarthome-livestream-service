#!/bin/bash

# Update the WebRTC server ip address
(envsubst < /opt/janus/etc/janus/janus.jcfg) > /dev/null

# Starting the nginx server (necessary for the HLS stream)
service nginx start
sleep 2

# Start the several stream servers
(cd /usr/local/bin/live555 && ./live555MediaServer &)
sleep 2
(cd /usr/local/bin/live555 && ./live555ProxyServer -t -p 8555 rtsp://localhost:554/test.264 &)
sleep 2
(cd /var/www/html && /usr/local/bin/live555/live555HLSProxy rtsp://localhost:8555/proxyStream video &)
sleep 2
(cd /opt/janus/bin && ./janus)



