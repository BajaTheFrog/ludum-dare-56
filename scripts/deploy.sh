#!/bin/sh

source $(dirname "$0")/build-server.sh
source $(dirname "$0")/build-web.sh
ssh root@ld56.dmsilva.com -t "echo $(git rev-parse HEAD) > /root/CURRENT_REV_BETA && ./docker-restart-beta.sh"
scp -r $(dirname "$0")/../build/web/* root@137.184.55.161:/var/www/html/beta
