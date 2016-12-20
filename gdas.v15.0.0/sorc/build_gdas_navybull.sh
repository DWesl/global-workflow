#!/bin/sh
set -x -e

######################################################################
#
# Build executable utility: navybull using module compile standard
#
######################################################################
######################################################################

target=$1
if [ $# -ne 1 ]; then
 echo "Usage: $0 wcoss or cray or theia"
 exit
fi

if [ $target = wcoss ]; then
. /usrx/local/Modules/3.2.10/init/sh
elif [ $target = cray ]; then
. $MODULESHOME/init/sh
elif [ $target = theia ]; then
. /apps/lmod/lmod/init/sh
else
 exit
fi

module purge
if [ $target = wcoss -o $target = cray ]; then
 module load ../modulefiles/gdas_navybull.$target
else
 source ../modulefiles/gdas_navybull.$target
fi

cd navybull.fd
make
make clean
mv navybull   ../../exec/
