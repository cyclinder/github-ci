#!/bin/bash

#diff=`git diff`
#echo "diff: ${diff}"
if [ -z "`git diff`" ]; then
  echo "diff is empty"
else
  echo "diff is no empty"
fi