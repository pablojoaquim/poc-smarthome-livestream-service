#!/bin/bash

service nginx start
sleep 2

(cd /usr/local/bin/live555 && ./live555MediaServer &)
sleep 2
(cd /usr/local/bin/live555 && ./live555ProxyServer -t -p 8555 rtsp://localhost:554/test.264 &)
sleep 2
(cd /var/www/html && /usr/local/bin/live555/live555HLSProxy rtsp://localhost:8555/proxyStream video)



