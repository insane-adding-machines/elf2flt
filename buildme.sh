#!/bin/bash
BINUTILS=binutils-2.25.tar.gz

if [ -f $BINUTILS ];
then
    rm $BINUTILS
fi

echo \>\>\> Downloading binutils
wget https://ftp.gnu.org/gnu/binutils/$BINUTILS
if [ $? -ne 0 ]; then
    echo Failed to download binutils
    exit 1
fi

echo \>\>\> Unpacking binutils
tar xfz binutils-2.25.tar.gz 
if [ $? -ne 0 ]; then
    echo Failed to unpack binutils
    exit 1
fi
cd binutils-2.25

echo \>\>\> Configuring binutils
./configure
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
./configure --target=arm-none-eabi \
    --prefix=/usr \
    --with-libbfd=`pwd`/binutils-2.25/bfd/libbfd.a \
    --with-libiberty=`pwd`/binutils-2.25/libiberty/libiberty.a \
    --with-bfd-include-dir=`pwd`/binutils-2.25/bfd \
    --with-binutils-include-dir=`pwd`/binutils-2.25/include LDFLAGS=-ldl
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

