#!/bin/bash
mkdir -p results

# 1) PASS
node server.js > /dev/null 2>&1 & SP=$!; sleep 1
k6 run slo-test.js 2>&1 | tee results/pass.txt
kill $SP; sleep 1

# 2) CHAOS: 10 сек дээр сервер зогсоож, 10 сек-ийн дараа дахин асаана
node server.js > /dev/null 2>&1 & SP=$!; sleep 1
( sleep 10; kill $SP; sleep 10; node server.js > /dev/null 2>&1 ) &
k6 run slo-test.js 2>&1 | tee results/chaos.txt
pkill -f "node server.js"; sleep 1

# 3) FAIL
node server.js > /dev/null 2>&1 & SP=$!; sleep 1
k6 run slo-test-fail.js 2>&1 | tee results/fail.txt
echo "exit=${PIPESTATUS[0]}" | tee -a results/fail.txt
kill $SP
