#!/bin/bash
# netboot-data-server.sh - This shell script will boot
# the data server using WOL.
#

MAC=""

sudo etherwake $MAC
