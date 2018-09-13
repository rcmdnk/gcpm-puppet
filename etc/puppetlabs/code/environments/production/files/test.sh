#!/bin/sh

date
echo "1 cpu job"
echo HOSTNAME: $(hostname -f)
echo IP: $(hostname -i)
echo sleep 60 sec...
sleep 60
echo finished
