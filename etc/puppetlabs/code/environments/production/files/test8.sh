#!/bin/sh

date
echo "8 cpus job"
echo HOSTNAME: $(hostname -f)
echo IP: $(hostname -i)
echo sleep 60 sec...
sleep 60
echo finished
