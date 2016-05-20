#!/bin/bash

# start pipeline and wait for job

service ssh start
service pipeline2d start
while [ "`curl localhost:8181/ws/jobs 2>/dev/null | sed 's/</\n</g' | grep '<job ' | grep -v 'status=\"IDLE\"' | grep -v 'status=\"RUNNING\"' | wc -l`" = "0" ]; do
    echo "No finished jobs, waiting 5 more seconds..."
    sleep 5
done
#curl localhost:8181/ws/jobs 2>/dev/null | sed 's/.*<job \([^>]*\)>.*/\1/g' | sed 's/ /\n/g' > /mnt/target/done
JOB_ID="`curl localhost:8181/ws/jobs 2>/dev/null | sed 's/.*id="//g' | sed 's/".*//g'`"
curl localhost:8181/ws/jobs/$JOB_ID 2>/dev/null | sed 's/</\n</g' > "/mnt/target/done"
chown -R 1000:1000 /mnt/target
