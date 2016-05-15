#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

if [ "$YOURKIT_HOME" = "" ]; then
    YOURKIT_HOME="$HOME/yourkit/yjp-2016.02"
    echo "YOURKIT_HOME not set, using this default: $YOURKIT_HOME"
fi

# start docker container
rm "$DIR/target" -rf && mkdir "$DIR/target"
IMAGE_ID=$(docker build . | tail -n 1 | sed 's/.* //')

CONTAINER_ID=$(docker run -d -v "$DIR/test-job":"/mnt/job" -v "$DIR/target":"/mnt/target" -v "$YOURKIT_HOME/bin/linux-x86-64/":"/mnt/yourkit/":ro -p 8181:8181 $IMAGE_ID)
CONTAINER_IP=$(docker inspect $CONTAINER_ID | grep '"IPAddress"' | head -n 1 | sed 's/"[^"]*$//' | sed 's/.*"//')

# connect yourkit
read -n1 -s -p "Now, connect to root@$CONTAINER_IP:22 (password: root) from YourKit and press enter to continue..."
echo
if [ "`curl "http://localhost:8181/ws/alive" 2>/dev/null | grep '<alive' | wc -l`" = "0" ]; then
    echo "Engine is not alive yet, waiting 10 seconds more..."
    sleep 10
    if [ "`curl "http://localhost:8181/ws/alive" 2>/dev/null | grep '<alive' | wc -l`" = "0" ]; then
        echo "Engine is not alive, aborting..."
        docker kill $CONTAINER_ID
        exit
    fi
fi

# submit job
echo "Submitting job..."
curl -X POST -d @"test-job/jobRequest.xml" --header "Content-Type: application/xml" "http://localhost:8181/ws/jobs" 2>/dev/null \
    | sed 's/</\n</g' | grep '<job' | sed 's/ /\n/g' | grep -v '<job' | grep -v 'xmlns'

# wait until job is done
sleep 5
if [ "`curl localhost:8181/ws/jobs 2>/dev/null | sed 's/</\n</g' | grep '<job ' | wc -l`" = "0" ]; then
    echo "Job was not successfully submitted; aborting..."
    docker kill $CONTAINER_ID
    
else
    STATUS="RUNNING"
    while [ "$STATUS" = "RUNNING" ]; do
        STATUS="`curl localhost:8181/ws/jobs 2>/dev/null | sed 's/</\n</g' | grep '<job ' | sed 's/ /\n/g' | grep 'status=' | sed 's/.*="//' | sed 's/".*//'`"
        echo "$STATUS (`date`)"
        sleep 5
    done
    cat "target/done"
fi
