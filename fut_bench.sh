#!/bin/bash

set -x

OS=$(uname)
if [ "$OS" == "Darwin" ] ; then
  OPENCL="-framework OpenCL"
elif [ "$OS" == "Linux" ] ; then
  OPENCL="-lOpenCL"
fi
echo $OPENCL

benchmark () {
  # USAGE: benchmark file.fut data/input.in
  FILENAME=$1
  echo ${FILENAME%.fut}
  BASENAME=${FILENAME%.fut}
  DATAFILE=$2
  futhark opencl $FILENAME 
  gcc $BASENAME.c -O -std=c99 -lm $OPENCL -o $BASENAME
  time ./$BASENAME < $DATAFILE > /dev/null
  gcc $BASENAME.c -O -std=c99 -lm -fprofile-generate $OPENCL -o ${BASENAME}_pg
  ./${BASENAME}_pg $DATAFILE > /dev/null
  gcc $BASENAME.c -O -std=c99 -lm -fprofile-use $OPENCL -o ${BASENAME}_pu
  time ./${BASENAME}_pu $DATAFILE > /dev/null
}

benchmark canny.fut data/lena256.in
