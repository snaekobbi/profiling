#!/bin/bash
#set -e
#set -x

LOGFILE=/tmp/output.log

if [ "$MAX_TIMEOUT" = "" ]; then
    MAX_TIMEOUT=600
fi
if [ "$SUCCESS_TIME" = "" ]; then
    SUCCESS_TIME=60
fi

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
        STATUS="error"
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
        return "failure"
    else
        STATUS="`timeout 10 ~/daisy-pipeline/cli/dp2 status $JOB_ID 2>&1 | grep 'Status:' | sed 's/.*[ \t]//'`"
        if [ "$STATUS" = "DONE" ]; then
            STATUS="success"
        else
            if [ "$STATUS" = "ERROR" ]; then
                STATUS="failure"
            else
                STATUS="error"
            fi
        fi
        echo $STATUS
    fi
}

timer_start "Download Pipeline 2"
cd ~/pipeline
git fetch -a
git checkout "$COMMIT"
timer_end "success"

echo "# Speed tests for `cd ~/pipeline && git rev-parse --short $COMMIT` ($COMMIT) - `date`" > $LOGFILE

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
    FILESIZE="`ls -lh ~/src/resources/$BOOK_ID.xml | awk '{print $5}'`"
    TITLE="$2 ($BOOK_ID / filesize $FILESIZE)"
    
    if [ $TIMER -lt $SUCCESS_TIME ]; then # only continue if previous test took less than $SUCCESS_TIME
        timer_start "$TITLE"
        OUT_DIR="`tempfile`"
        rm $OUT_DIR
        timeout $MAX_TIMEOUT daisy-pipeline/cli/dp2 dtbook-to-pef --persistent --source ~/src/resources/$BOOK_ID.xml --output $OUT_DIR
        TEST_STATUS="`status`"
        timer_end "$TEST_STATUS"
        TOTAL_SPEED_TEST_TIME="`expr $TOTAL_SPEED_TEST_TIME + $TIMER`"
        if [ "$TEST_STATUS" = "success" ]; then
            LAST_SUCCESSFUL_BOOK=$BOOK_ID
        fi
    else
        TOTAL_SPEED_TEST_TIME="`expr $TOTAL_SPEED_TEST_TIME + $MAX_TIMEOUT`"
    fi
}

function run_speed_test_parallel {
    COUNT="$1"
    BOOK_ID="$2"
    FILESIZE="`ls -lh ~/src/resources/$BOOK_ID.xml | awk '{print $5}'`"
    TITLE="$3 x$COUNT ($BOOK_ID / filesize $FILESIZE)"
    
    timer_start "$TITLE"
    for i in `seq 1 $COUNT`; do
        OUT_DIR="`tempfile`"
        rm $OUT_DIR
        timeout $MAX_TIMEOUT daisy-pipeline/cli/dp2 dtbook-to-pef --persistent --source ~/src/resources/$BOOK_ID.xml --output $OUT_DIR &
    done
    for job in `jobs -p`; do
        wait $job
    done
    TEST_STATUS="`timeout 10 ~/daisy-pipeline/cli/dp2 jobs 2>&1 | tail -n $COUNT | sed 's/[ \t].*//' | xargs ~/daisy-pipeline/cli/dp2 status 2>&1 | grep 'Status:' | sed 's/.*[ \t]//' | uniq | paste -s -d" "`"
    if [ "echo $TEST_STATUS | grep ERROR | wc -l" = "1" ]; then
        TEST_STATUS="failure"
    else
        if [ "$TEST_STATUS" = "DONE" ]; then
            TEST_STATUS="success"
        else
            TEST_STATUS="error"
        fi
    fi
    timer_end "$TEST_STATUS"
    TOTAL_SPEED_TEST_TIME="`expr $TOTAL_SPEED_TEST_TIME + $TIMER`"
}

TOTAL_SPEED_TEST_TIME=0
LAST_SUCCESSFUL_BOOK=""

run_speed_test 552974 "Speed test #1"
run_speed_test 552739 "Speed test #2"
run_speed_test 553184 "Speed test #3"
run_speed_test 554664 "Speed test #4"
run_speed_test 501035 "Speed test #5"

TIMER=0 && run_speed_test $LAST_SUCCESSFUL_BOOK "Speed test sequential #1"
TIMER=0 && run_speed_test $LAST_SUCCESSFUL_BOOK "Speed test sequential #2"
TIMER=0 && run_speed_test $LAST_SUCCESSFUL_BOOK "Speed test sequential #3"

SUCCESS_TIME=`expr $SUCCESS_TIME \* 4`
if [ $SUCCESS_TIME -gt $MAX_TIMEOUT ]; then
    SUCCESS_TIME=$MAX_TIMEOUT
fi
run_speed_test_parallel 4 $LAST_SUCCESSFUL_BOOK "Speed test parallel"

echo "Total test time: ${TOTAL_SPEED_TEST_TIME}s ($LAST_TIMER_STATUS)" | tee -a $LOGFILE
