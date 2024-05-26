#!/bin/bash

# Build suite on Linux
# Ensure wla-z80 and wlalink and in the system path

set -e                              # exit on errors
cd "$(dirname "$0")"                # set directory to script directory
wla-z80 -o suite.o suite.asm        # assemble objects
wlalink -d -S -A linkfile suite.sms # link objects

echo "Zest suite ROM saved to $(realpath suite.sms)"
cd - > /dev/null                    # return to previous directory
