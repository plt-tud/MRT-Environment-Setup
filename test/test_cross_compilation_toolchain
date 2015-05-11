#!/bin/bash
mkdir temp
arm-linux-gnueabihf-g++ -o temp/test.bin res/test.cpp
file temp/test.bin | grep 'ARM' &> /dev/null
if [ $? == 0 ]; then
    echo "Cross-compilation successful"
else
    echo "Something went wrong"
fi
rm -r temp