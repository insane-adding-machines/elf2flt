#!/bin/bash

### CONFIG ###
# Adapt version to your toolchain
# GCC 5.3 needs at least 2.25.1
BINUTILS=binutils-2.25.1
#PATH_TO_TOOLCHAIN=~/gcc-arm-none-eabi-5_2-2015q4/
PATH_TO_TOOLCHAIN=/usr
TARGET=arm-none-eabi
# Current directory
BASEPATH=`pwd`

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
cd $BASEPATH/$BINUTILS

echo \>\>\> Configuring binutils
rm -rf build
mkdir -p build
cd build
../configure --target=$TARGET --prefix=$PATH_TO_TOOLCHAIN --disable-nls
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

cd $BASEPATH
echo \>\>\> Configuring elf2flt
./configure --target=$TARGET \
    --prefix=$PATH_TO_TOOLCHAIN \
    --with-libbfd=$BASEPATH/$BINUTILS/build/bfd/libbfd.a \
    --with-libiberty=$BASEPATH/$BINUTILS/build/libiberty/libiberty.a \
    --with-bfd-include-dir=$BASEPATH/$BINUTILS/build/bfd/ \
    --with-binutils-include-dir=$BASEPATH/$BINUTILS/include LDFLAGS=-ldl
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

