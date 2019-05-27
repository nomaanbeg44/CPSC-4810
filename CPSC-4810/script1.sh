#!/usr/bin/env bash

csvcut -c ArrDelay,Origin flightdelays.csv | csvgrep -c Origin -r "SFO" | head -n 4 > first3sfo.csv

csvlook first3sfo.csv

awk -F "\"*,\"*" '{print $18}' flightdelays.csv | sort -r | uniq -c | sort -nr | head -n 3 | csvlook -H


