#!/bin/bash

FROM=1
TO=10


# For debug by executing individual step(s) i.e 'bash this_script -fm -tn'
while getopts f:t: flag
do
    case "${flag}" in
        f) FROM=${OPTARG};;
        t) TO=${OPTARG};;
    esac
done


STAGE_DIR=/home/hnhan/Intel-FlexRAN/22-11

# Assume all source files are pre-saved under STARGE_DIR: dpdk_patch-22.11.patch.zip FlexRAN-22.11-L1.tar.gz_part00  FlexRAN-22.11-L1.tar.gz_part01 

DPDK_PATCH=$STAGE_DIR/dpdk_patch-22.11.patch
FLEXRAN_TAR_BALL=$STAGE_DIR/FlexRAN-22.11.tar.gz

# Assuming we have download 22.11 contents to STAGE_DIR
# Preprocess staeqd files i.e unzip, concat if necessary
cd $STAGE_DIR
if [ ! -e dpdk_patch-22.11.patch ]; then
    unzip dpdk_patch-22.11.patch
fi
if [ ! -e FlexRAN-22.11.tar.gz ]; then
    cat  FlexRAN-22.11-L1.tar.gz_part0 FlexRAN-22.11-L1.tar.gz_part1 > FlexRAN-22.11.tar.gz
fi

cd /opt

if [  $FROM -le 1  ] &&  [ $TO -ge 1 ]; then
  # Download and patch DPDK
  rm -fr dpdk-21.11
  wget -O dpdk-21.11.tar.gz https://fast.dpdk.org/rel/dpdk-21.11.tar.gz && tar xzvf dpdk-21.11.tar.gz  
  cd dpdk-21.11 &&  patch -p1 < $DPDK_PATCH

fi

if [  $TO -lt 2 ]; then echo short 2;  exit ; fi

if [  $FROM -le 2  ] &&  [ $TO -ge 2 ]; then
# unpack the new 22.11 FlexRAN tar ball
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

if [  $TO -lt 3 ]; then echo short 3;  exit ; fi

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

if [  $TO -lt 4 ]; then echo short 4;  exit ; fi

# step 4

if [[ -z "${RTE_SDK}" ]]; then
    cd /opt/flexran && source ./set_env_var.sh -d -x icx
    export PATH=/opt/intel/oneapi/compiler/latest/linux/bin-llvm:$PATH
fi

if [  $FROM -le 4  ] &&  [ $TO -ge 4 ]; then
 #cd /opt/flexran && source ./set_env_var.sh -d -x icx #moved outside if to support rerun
 cd /opt/flexran 
 
 # Attention new:  flexran_build.sh -e -r 5gnr-m sdk   <=== 22.11
 cd /opt/flexran && ./flexran_build.sh -e -r 5gnr -m sdk -m mlog
fi

if [  $TO -lt 5 ]; then echo short 5;  exit ; fi

# Attention New:  pip3 install pyelftools
export PKG_CONFIG_PATH=$DIR_WIRELESS_SDK/pkgcfg:$PKG_CONFIG_PATH
pip3 install pyelftools

# step 5
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

if [  $TO -lt 6 ]; then echo short 6;  exit ; fi

#step 5
if [  $FROM -le 6  ] &&  [ $TO -ge 6 ]; then
 # Attention New: "5gnr", no '-m' means '-m all'
 # cd /opt/flexran && ./flexran_build.sh -e -r 5gnr  <== before reading
 #                      sdk - SDK Library
 #                      bbu - Framework Library
 #                      wls - Wireless Shared Memory Library
 #                      mlog - MLog library
 #                      cpa - CPA 5GNR library
 #                      xran - xran library
 #                      l1app - Build L1 Application for radio mode chosen with -r option
 #                      testmac - Build Testmac Application for radio mode chosen with -r option
 #                      testapp - Build Testapp Application for radio mode chosen with -r option
 #                      all - Build all of the above for the specified RAT(s) (default if not set)

 cd /opt/flexran && ./flexran_build.sh -e -r 5gnr 

fi  

if [  $TO -lt 7 ]; then echo short 7;  exit ; fi

#step 7
if [  $FROM -le 7  ] &&  [ $TO -ge 7 ]; then
 # Atterntion New: build Sample app
 #cd /opt/flexran && source ./set_env_var.sh -d -x icx
 cd /opt/flexran 
 #source ./set_env_var.sh 
 export MLOG_DIR=/opt/flexran//libs/mlog
 #export GTEST_ROOT=/opt/gtest/gtest-1.7.0/
 cd /opt/flexran/xran && ./build.sh SAMPLEAPP xclean &&  ./build.sh SAMPLEAPP
fi

SDK_ENV=/opt/sdk.env
gen_sdk_env () {
    # Collect env variables from ./set_env_var.sh outputs

    echo "#" `basename "$0"` generated env > $SDK_ENV
    pushd /opt/flexran
    echo "export FLEXRAN_ROOT=/opt/flexran" >> $SDK_ENV

    source ./set_env_var.sh -d -x icx |  sed -n '/Envi/,//p' | grep -v "==\|Envi" | awk  -F= '{print "export " $0}' >> $SDK_ENV
    # sed 
    #   -n skip until "Envi"
    #    p then print
    # grep 
    #    ignore lines with pattern "==" and "Envi"
    # awk
    #    add "export " in front of lines

    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${FLEXRAN_ROOT}/icx_libs:${FLEXRAN_ROOT}/wls_mod:${FLEXRAN_ROOT}/libs/cpa/bin'  >> $SDK_ENV
    # LD_LIBRARY_PATH should have been done in Dockerfile, but the remotehost's chroot env 
    # cannot inherit Dockerfile's ENV settings.

    popd 
}

# And lastly
if [  $FROM -le 8  ] &&  [ $TO -ge 8 ]; then
  echo invokde: gen_sdk_env
  gen_sdk_env
fi

# That's all folks

