#!/bin/bash
#set -e
#set -x

LOGFILE=/tmp/target/output.log
MAX_TIMEOUT=600
SUCCESS_TIME=60

# initial values for timer
TIMER_START=`date --utc +"%s"`
TIMER_END=$TIMER_START
TIMER_NAME="Unknown"
TIMER=0
LAST_TIMER_STATUS="success"

# start timer
function timer_start {
    TIMER_NAME="$1"
    TIMER_START=`date --utc +"%s"`
    TIMER_END=$TIMER_START
    TIMER=0
}

# end timer
function timer_end {
    STATUS="$1"
    TIMER_END=`date --utc +"%s"`
    TIMER=`expr $TIMER_END - $TIMER_START`
    if [ $TIMER -gt $SUCCESS_TIME ] && [ "$STATUS" = "success" ]; then
        STATUS="warning"
    fi
    LAST_TIMER_STATUS="$STATUS"
    echo "$TIMER_NAME: ${TIMER}s ($STATUS)" | tee -a $LOGFILE
}

function lastid {
    timeout 10 ~/daisy-pipeline/cli/dp2 jobs 2>&1 | tail -n 1 | sed 's/[ \t].*//'
}

function status {
    JOB_ID="`lastid`"
    if [ "$JOB_ID" = "" ]; then
        return "failed"
    else
        STATUS="`timeout 10 ~/daisy-pipeline/cli/dp2 status $JOB_ID 2>&1 | grep 'Status:' | sed 's/.*[ \t]//'`"
        if [ "$STATUS" = "DONE" ]; then
            STATUS="success"
        else
            if [ "$STATUS" = "ERROR" ]; then
                STATUS="failed"
            else
                STATUS="error"
            fi
        fi
        echo $STATUS
    fi
}

timer_start "Download Pipeline 2"
cd ~
git clone https://github.com/daisy/pipeline.git
cd ~/pipeline
git checkout "$COMMIT"
timer_end "success"

echo >> $LOGFILE
echo "# Speed tests for `cd ~/pipeline && git rev-parse --short $COMMIT` ($COMMIT) - `date`" >> $LOGFILE

timer_start "Build Pipeline 2"
cd ~/pipeline
mkdir -p .maven-cache
make dist-zip
timer_end "success"

timer_start "Install Pipeline 2"
cd ~
unzip pipeline/pipeline2-*_linux.zip
timer_end "success"

timer_start "Starting Pipeline 2"
daisy-pipeline/cli/dp2
timer_end "success"

function run_speed_test {
    BOOK_ID="$1"
    TITLE="$2"
    
    if [ $TIMER -lt $SUCCESS_TIME ]; then # only continue if previous test took less than $SUCCESS_TIME
        timer_start "$TITLE"
        timeout $MAX_TIMEOUT daisy-pipeline/cli/dp2 dtbook-to-pef --persistent --source ~/src/resources/$BOOK_ID.xml --output /tmp/$BOOK_ID/
        timer_end "`status`"
        TOTAL_SPEED_TEST_TIME="`expr $TOTAL_SPEED_TEST_TIME + $TIMER`"
    else
        TOTAL_SPEED_TEST_TIME="`expr $TOTAL_SPEED_TEST_TIME + $MAX_TIMEOUT`"
    fi
}

TOTAL_SPEED_TEST_TIME=0

run_speed_test 552974 "Speed test #1 (552974 / filesize 2 kB)"
run_speed_test 552739 "Speed test #2 (552739 / filesize 0.5 MB)"
run_speed_test 553184 "Speed test #3 (553184 / filesize 1 MB)"
run_speed_test 554664 "Speed test #4 (554664 / filesize 2.4 MB)"
run_speed_test 501035 "Speed test #5 (501035 / filesize 7.3 MB)"

echo "Total test time: ${TOTAL_SPEED_TEST_TIME}s ($LAST_TIMER_STATUS)" | tee -a $LOGFILE
