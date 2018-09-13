#!/bin/sh

echo "dummy 8core job"
echo HOSTNAME: $(hostname -f)
echo IP: $(hostname -i)
echo sleep 60 sec...
sleep 60
echo finished
