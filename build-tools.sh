#!/usr/bin/env bash
set -e

export NAME=hyperscan-toolchain
export THREADS=$(nproc --all)
export WORKING_DIR=/tmp/hs-tools
export SOURCE_DIR=$(pwd)/sources
export SCRIPT_DIR=$(pwd)
export TARGET=score-elf
export PREFIX=$(pwd)/$NAME
export PATH=$PREFIX/bin:$PATH

export BINUTILS_VERSION=2.35
export GCC_VERSION=4.9.4
#export NEWLIB_VERSION=1.20.0

mkdir -p $WORKING_DIR || exit 1
mkdir -p $SOURCE_DIR || exit 1
cd "$WORKING_DIR"

if [ ! -f $SOURCE_DIR/binutils-$BINUTILS_VERSION.tar.bz2 ]; then
  echo "Downloading binutils $BINUTILS_VERSION..."
  curl --progress-bar "https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.bz2" -o "$SOURCE_DIR/binutils-$BINUTILS_VERSION.tar.bz2" || exit 1
fi

if [ ! -f $SOURCE_DIR/gcc-$GCC_VERSION.tar.bz2 ]; then
  echo "Downloading gcc $GCC_VERSION..."
  curl --progress-bar "https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.bz2" -o "$SOURCE_DIR/gcc-$GCC_VERSION.tar.bz2" || exit 1
fi

#if [ ! -f "$SOURCE_DIR/newlib-$NEWLIB_VERSION.tar.gz" ]; then
  #echo "Downloading newlib $NEWLIB_VERSION..."
  #curl --progress-bar "ftp://sourceware.org/pub/newlib/newlib-$NEWLIB_VERSION.tar.gz" -o "$SOURCE_DIR/newlib-$NEWLIB_VERSION.tar.gz"
#fi

if [ ! -f extracted-binutils-$BINUTILS_VERSION ]; then
  echo "Unpacking binutils $BINUTILS_VERSION..."
  tar xf "$SOURCE_DIR/binutils-$BINUTILS_VERSION.tar.bz2" || exit 1;
  touch extracted-binutils-$BINUTILS_VERSION
fi

if [ ! -f patched-binutils-$BINUTILS_VERSION -a -f $SCRIPT_DIR/binutils-$BINUTILS_VERSION.patch ]; then
  echo "Patching binutils-$BINUTILS_VERSION"
  cd $WORKING_DIR/binutils-$BINUTILS_VERSION
  patch -p1 -i $SCRIPT_DIR/binutils-$BINUTILS_VERSION.patch || { echo "Error patching binutils"; exit 1; }
  cd $WORKING_DIR
  touch patched-binutils-$BINUTILS_VERSION
fi

if [ ! -f extracted-gcc-$GCC_VERSION ]; then
  echo "Unpacking gcc... $GCC_VERSION"
  tar xf "$SOURCE_DIR/gcc-$GCC_VERSION.tar.bz2" || exit 1;
  touch extracted-gcc-$GCC_VERSION
fi


if [ ! -f patched-gcc-$GCC_VERSION -a -f $SCRIPT_DIR/gcc-$GCC_VERSION.patch ]; then
  echo "Patching gcc-$GCC_VERSION"
  cd $WORKING_DIR/gcc-$GCC_VERSION
  patch -p1 -i $SCRIPT_DIR/gcc-$GCC_VERSION.patch || { echo "Error patching gcc"; exit 1; }
  cd $WORKING_DIR
  touch patched-gcc-$GCC_VERSION
fi

# echo "Unpacking newlib $NEWLIB_VERSION..."
# tar xf "newlib-$NEWLIB_VERSION.tar.gz"

# compile binutils
mkdir -p "$WORKING_DIR/build-binutils-$BINUTILS_VERSION" && cd "$WORKING_DIR/build-binutils-$BINUTILS_VERSION"

if [ ! -f configured-binutils ]; then
  $WORKING_DIR/binutils-$BINUTILS_VERSION/configure \
	--target=$TARGET --prefix=$PREFIX \
	--disable-nls --disable-multilib --disable-werror \
	--enable-lto --enable-plugins || exit 1
  touch configured-binutils
fi

if [ ! -f built-binutils ]; then
  make -j$THREADS all || exit 1;
  touch built-binutils
fi

if [ ! -f installed-binutils ]; then
  make install || exit 1;
  touch installed-binutils
fi

cd $WORKING_DIR/gcc-$GCC_VERSION

# compile first stage gcc
if [ ! -f downloaded-prerequisites ]; then
  ./contrib/download_prerequisites || exit 1;
  touch downloaded-prerequisites
  ls -al d*
  pwd
fi

mkdir -p "$WORKING_DIR/build-gcc-$GCC_VERSION" && cd "$WORKING_DIR/build-gcc-$GCC_VERSION"
if [ ! -f configured-gcc ]; then
  $WORKING_DIR/gcc-$GCC_VERSION/configure --target=$TARGET --prefix=$PREFIX --without-headers --with-newlib --enable-obsolete \
    --disable-libgomp --disable-libmudflap --disable-libssp --disable-libatomic --disable-libitm --disable-libsanitizer \
    --disable-libmpc --disable-libquadmath --disable-threads --disable-multilib --disable-target-zlib --with-system-zlib \
    --disable-shared --disable-nls --enable-languages=c --with-gnu-as --with-gnu-ld --disable-tm-clone-registry || exit 1;
  touch configured-gcc
fi

if [ ! -f built-stage1-gcc ]; then
  make -j$THREADS all-gcc all-target-libgcc || exit 1;
  touch built-stage1-gcc
fi

if [ ! -f installed-stage1-gcc ]; then
  make install-gcc install-target-libgcc || exit 1;
  touch installed-stage1-gcc
fi

cd $WORKING_DIR

# compile newlib
# mkdir -p "$WORKING_DIR/build-newlib" && cd "$WORKING_DIR/build-newlib"
# $WORKING_DIR/newlib-$NEWLIB_VERSION/configure --target=$TARGET --prefix=$PREFIX --with-gnu-as --with-gnu-ld --disable-nls
# make all -j$THREADS
# make install

#rm -rf "$WORKING_DIR"
