#!/bin/bash

# Adapt version to your toolchain
# GCC 5.3 needs at least 2.25.1
BINUTILS=binutils-2.25.1
PATH_TO_TOOLCHAIN=/usr
#PATH_TO_TOOLCHAIN=~/gcc-arm-none-eabi-4_9-2015q3
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
./configure --target=$TARGET
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
    --enable-always-reloc-text \
    --with-libbfd=`pwd`/$BINUTILS/bfd/libbfd.a \
    --with-libiberty=`pwd`/$BINUTILS/libiberty/libiberty.a \
    --with-bfd-include-dir=`pwd`/$BINUTILS/bfd \
    --with-binutils-include-dir=`pwd`/$BINUTILS/include LDFLAGS=-ldl
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
sudo make install
if [ $? -ne 0 ]; then
    echo Failed to install elf2flt
    exit 1
else
    echo elf2flt installed successfully
fi

