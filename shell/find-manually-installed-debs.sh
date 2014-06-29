#!/bin.sh
for pkg in $(aptitude search ~i | grep -v "i A" | cut -d " " -f 4)
  do echo "-- markauto $pkg --"
  sudo aptitude markauto $pkg
done