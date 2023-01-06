#!/bin/bash

FROM=1
TO=10

while getopts f:t: flag
do
    case "${flag}" in
        f) FROM=${OPTARG};;
        t) TO=${OPTARG};;
    esac
done

echo range=$FROM-$TO


PHASE=1

NEW_INSTALL=false
DPDK_REUSE=true

STAGE_DIR=/home/hnhan/Intel-FlexRAN/22-03

# Assume all source files are pre-saved under STARGE_DIR: dpdk_patch-22.03.patch.zip FlexRAN-22.03-L1.tar.gz_part00  FlexRAN-22.03-L1.tar.gz_part01 

DPDK_PATCH=$STAGE_DIR/dpdk_patch-22.03.patch
FLEXRAN_TAR_BALL=$STAGE_DIR/FlexRAN-22.03.tar.gz

source /opt/intel/oneapi/setvars.sh 
export PATH=/opt/intel/oneapi/compiler/2022.2.1/linux/bin-llvm:$PATH

# Assuming we have download 22.03 contents to STAGE_DIR
# Preprocess staeqd files i.e unzip, concat if necessary
cd $STAGE_DIR
if [ ! -e dpdk_patch-22.03.patch ]; then
    unzip dpdk_patch-22.03.patch
fi
if [ ! -e FlexRAN-22.03.tar.gz ]; then
    cat  FlexRAN-22.03-L1.tar.gz_part00 FlexRAN-22.03-L1.tar.gz_part01 > FlexRAN-22.03.tar.gz
fi

cd /opt

if [  $FROM -le 1  ] &&  [ $TO -ge 1 ]; then
  # Download and patch DPDK
  rm -fr dpdk-21.11
  wget -O dpdk-21.11.tar.gz https://fast.dpdk.org/rel/dpdk-21.11.tar.gz && tar xzvf dpdk-21.11.tar.gz  
  cd dpdk-21.11 &&  patch -p1 < $DPDK_PATCH

  # use oneAPI ready at /opt/intel
  echo use existing oneAPI
  #ln -s /home/opt/intel  /opt/intel

fi

if [  $FROM -le 2  ] &&  [ $TO -ge 2 ]; then
# unpack the new 22.03 FlexRAN tar ball
rm -rf /opt/flexran && cd /opt && mkdir -p flexran && tar zxvf ${FLEXRAN_TAR_BALL} -C flexran/
cd /opt/flexran && expect <<END_EXPECT
set timeout 300
spawn ./extract.sh
expect {
-ex {[.]} {send "\r"; exp_continue}
-ex {[Y]?} {send "y\r"; exp_continue}
-ex {--More--} {send " "; exp_continue}
}
END_EXPECT
 # If above expect step fails, try it manually: cd /opt/flexran && ./extract.sh
fi

# Attention, "-x icc" is new -  ./set_env_var.sh -d -x icc
if [  $FROM -le 3  ] &&  [ $TO -ge 3 ]; then
cd /opt/flexran && expect <<END_EXPECT
set timeout 5
spawn sh -c {source ./set_env_var.sh -d -x icx}
expect {
-ex {Install Directory for icx} {send "/opt/intel/oneapi\r"; exp_continue}
-ex {DPDK Install Directory} {send "/opt/dpdk-21.11\r"; exp_continue}
}
END_EXPECT
# if above expect step fails, try it manually: cd /opt/flexran && source ./set_env_var.sh -d
fi

# step 2
cd /opt/flexran && source ./set_env_var.sh -d -x icx
if [  $FROM -le 4  ] &&  [ $TO -ge 4 ]; then
 #cd /opt/flexran && source ./set_env_var.sh -d -x icx #moved outside if to support rerun
 cd /opt/flexran 
 #source ./set_env_var.sh 
 # Attention new:  flexran_build.sh -e -r 5gnr -b -m sdk 
 cd /opt/flexran && ./flexran_build.sh -e -r 5gnr -b -m sdk 
 # Attention New:  pip3 install pyelftools
 export PKG_CONFIG_PATH=$DIR_WIRELESS_SDK/pkgcfg:$PKG_CONFIG_PATH
 pip3 install pyelftools
fi

# step 3
if [  $FROM -le 5  ] &&  [ $TO -ge 5 ]; then
 cd /opt/flexran 
 #source ./set_env_var.sh 
 rm -rf /opt/dpdk-21.11/build && cd /opt/dpdk-21.11 && meson build
 cd /opt/dpdk-21.11/build && meson configure -Dexamples=ethtool -Dflexran_sdk=/opt/flexran/sdk/build-avx512-icx/install && ninja

fi
export MESON_BUILD=1

# if we have a testmac patch, and had not patch, path now
if [ -e /opt/testmac.patch ]; then
    pushd /opt/flexran/build/nr5g/gnb/testmac
    if [ ! -e ./testmac.patch ]; then
        cp  /opt/testmac.patch .
        patch  < ./testmac.patch
    fi
    popd
fi

if [  $FROM -le 6  ] &&  [ $TO -ge 6 ]; then
#step 4
 # Attention New: "5gnr", no '-m' means '-m all'
 # cd /opt/flexran && ./flexran_build.sh -e -r 5gnr  <== before reading

 cd /opt/flexran && ./flexran_build.sh -e -r 5gnr 

fi  

#step 5
if [  $FROM -le 7  ] &&  [ $TO -ge 7 ]; then
 # Atterntion New: build Sample app
 #cd /opt/flexran && source ./set_env_var.sh -d -x icx
 cd /opt/flexran 
 #source ./set_env_var.sh 
 export MLOG_DIR=/opt/flexran//libs/mlog
 #export GTEST_ROOT=/opt/gtest/gtest-1.7.0/
 cd /opt/flexran/xran && ./build.sh SAMPLEAPP xclean &&  ./build.sh SAMPLEAPP
fi


