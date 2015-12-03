#!/usr/bin/env bash

cd $(dirname $0)
# build name of executable inside the application package
export HMSLEXEC=`pwd`/hmsl
# cd above app package so that HMSL can read pforth.dic and other files.
cd ../../../
# run HMSL
$HMSLEXEC

