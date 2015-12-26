#!/bin/bash

### CONFIG ###
# Adapt version to your toolchain
# GCC 5.3 needs at least 2.25.1
BINUTILS=binutils-2.25.1
#PATH_TO_TOOLCHAIN=~/gcc-arm-none-eabi-5_2-2015q4/
PATH_TO_TOOLCHAIN=/usr
PATH_TO_LIBIBERTY_INC=$PATH_TO_TOOLCHAIN/lib/gcc/arm-none-eabi/5.3.0/plugin/include/
TARGET=arm-none-eabi

if [ -d $BINUTILS ];
then
    echo \>\>\> Removing existing dir: $BINUTILS
    rm -rf $BINUTILS
fi

if [ -f $BINUTILS.tar.gz ];
then
    echo \>\>\> Re-using existing tarbal: $BINUTILS.tar.gz
else
    echo \>\>\> Downloading binutils
    wget https://ftp.gnu.org/gnu/binutils/$BINUTILS.tar.gz
    if [ $? -ne 0 ]; then
        echo Failed to download binutils
        exit 1
    fi
fi

echo \>\>\> Unpacking binutils
tar xfz $BINUTILS.tar.gz
if [ $? -ne 0 ]; then
    echo Failed to unpack binutils
    exit 1
fi
cd $BINUTILS

echo \>\>\> Configuring binutils
./configure --target=$TARGET --prefix=$PATH_TO_TOOLCHAIN --disable-nls
if [ $? -ne 0 ]; then
    echo Failed to configure binutils
    exit 1
fi

echo \>\>\> Building binutils
make
if [ $? -ne 0 ]; then
    echo Failed to build binutils
    exit 1
fi

cd ..
echo \>\>\> Configuring elf2flt
./configure --target=$TARGET \
    --prefix=$PATH_TO_TOOLCHAIN \
    --with-libbfd=`pwd`/$BINUTILS/bfd/libbfd.a \
    --with-libiberty=`pwd`/$BINUTILS/libiberty/libiberty.a \
    --with-bfd-include-dir=/usr/include \
    --with-binutils-include-dir=$PATH_TO_LIBIBERTY_INC LDFLAGS=-ldl
if [ $? -ne 0 ]; then
    echo Failed to configure elf2flt
    exit 1
fi

echo \>\>\> Building elf2flt
make
if [ $? -ne 0 ]; then
    echo Failed to build elf2flt
    exit 1
fi

echo \>\>\> Installing elf2flt
make install
if [ $? -ne 0 ]; then
    echo Failed to install elf2flt, retrying as root
    sudo make install
    if [ $? -ne 0 ]; then
        echo Failed to install elf2flt
        exit 1
    fi
fi
echo elf2flt installed successfully

