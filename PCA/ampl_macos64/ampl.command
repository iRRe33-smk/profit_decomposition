#!/bin/bash
cd "`dirname "$0"`"
export PATH="`pwd`:$PATH"
xattr -rc .
clear
echo 'wd:' `pwd`
./ampl -v
