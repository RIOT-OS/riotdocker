#! /bin/bash

SCRIPT_PATH=`readlink -f $0`
SCRIPT_DIR=`dirname $SCRIPT_PATH`

# Configuration env vars will be set to default values if not defined.
[ -z $OPENOCD_TOP_DIR ] && OPENOCD_TOP_DIR=$SCRIPT_DIR
[ -z $OPENOCD_VERSION ] && OPENOCD_VERSION="master"
[ -z $OPENOCD_INSTALL_PREFIX ] && OPENOCD_INSTALL_PREFIX="/usr/local"
[ -z $OPENOCD_CONFIGURE_OPTS ] && OPENOCD_CONFIGURE_OPTS="--enable-cmsis-dap"
[ -z $OPENOCD_J_LEVEL ] && OPENOCD_J_LEVEL=`nproc`
[ -z $OPENOCD_GIT_URL ] && OPENOCD_GIT_URL="git://git.code.sf.net/p/openocd/code"
[ -z $OPENOCD_WORKING_DIR ] && OPENOCD_WORKING_DIR="openocd"

# Enter the top build dir
pushd $OPENOCD_TOP_DIR

# Clone and build openocd
git clone $OPENOCD_GIT_URL $OPENOCD_WORKING_DIR
[ $? -ne 0 ] && >&2 echo "ERROR: Unable to clone git repo $OPENOCD_GIT_URL" && exit 1
pushd $OPENOCD_WORKING_DIR
git checkout $OPENOCD_VERSION
[ $? -ne 0 ] && >&2 echo "ERROR: Unable to checkout git revision $OPENOCD_VERSION" && exit 1
./bootstrap
[ $? -ne 0 ] && >&2 echo "ERROR: openocd bootstrap fail!" && exit 1
./configure --prefix $OPENOCD_INSTALL_PREFIX $OPENOCD_CONFIGURE_OPTS
[ $? -ne 0 ] && >&2 echo "ERROR: openocd configure fail!" && exit 1
make && make install
[ $? -ne 0 ] && >&2 echo "ERROR: openocd build fail!" && exit 1
popd

# Generate environment setup script.
# This script can be sourced by the user if the prefix is a local directory.
cat << EOF > $OPENOCD_INSTALL_PREFIX/setup-openocd-env
export PATH=$OPENOCD_INSTALL_PREFIX/bin:\$PATH
export LD_LIBRARY_PATH=$OPENOCD_INSTALL_PREFIX/lib
EOF

popd #pushd $OPENOCD_TOP_DIR
