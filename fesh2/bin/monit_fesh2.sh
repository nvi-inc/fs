#!/usr/bin/env bash
while true;
do
    fesh2 --monit >& /tmp/fesh2out.txt
    a=`wc -l /tmp/fesh2out.txt | awk '{print $1}'`
    printf "\e[8;%d;%dt" $[a+1] 80
    cat /tmp/fesh2out.txt
    COUNTER=60
    while [  $COUNTER -gt 0 ]; do
      printf "\33[2K\rNext check in %d sec" $[COUNTER]
      let COUNTER=COUNTER-1
      sleep 1
    done
    printf "\33[2K\r"
done
