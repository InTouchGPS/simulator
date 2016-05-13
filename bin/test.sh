#!/bin/sh

# This script will start a couple test gateways and a device simoulator to send readings
#
# THIS SHOULD BE STARTED FROM THE PROJECT ROOT DIRECTORY

bin/term.sh "cd `pwd` && ruby server.rb 1234 Y Y"
bin/term.sh "cd `pwd` && ruby server.rb 2234 Y N"
bin/term.sh "cd `pwd` && ruby simulator.rb P Y data/full_day_test.txt.gz 12 1"

