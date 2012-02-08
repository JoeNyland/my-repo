#!/bin/bash

# Script created by Joe Nyland on 08/02/2012 to update Bacula pools with new settings, then update all volume paramters.

#
# Sample set of commands for pool 'x':
# 
# 
# 
# 
#

$BACULADIR=`which bacula-dir`

$BACULADIR << EOPFR

EOPFR

$BACULADIR << EOVP

EOVP