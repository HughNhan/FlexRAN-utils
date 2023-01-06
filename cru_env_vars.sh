# SDK env. Manually extracted from ./set_env_var.sh output
export flexranPath=/opt/flexran
export RTE_SDK=/opt/dpdk-21.11
export WIRELESS_SDK_TARGET_ISA=avx512
export CPA_DIR=/opt/flexran/libs/cpa
export XRAN_DIR=/opt/flexran/xran
export DIR_WIRELESS_SDK_ROOT=/opt/flexran/sdk
export SDK_BUILD=build-avx512-icx
export DIR_WIRELESS_SDK=/opt/flexran/sdk/build-avx512-icx
export FLEXRAN_SDK=/opt/flexran/sdk/build-avx512-icx/install
export DIR_WIRELESS_FW=/opt/flexran/framework
export DIR_WIRELESS_TEST_4G=/opt/flexran/tests/lte
export DIR_WIRELESS_TEST_5G=/opt/flexran/tests/nr5g
export DIR_WIRELESS_TABLE_5G=/opt/flexran/bin/nr5g/gnb/l1/table
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${flexranPath}/icx_libs:${flexranPath}/wls_mod:${flexranPath}/libs/cpa/bin

# TBD: move this to mv-params.json in the near future
export ORU_DIR=${flexranPath}/bin/nr5g/gnb/l1/orancfg/sub3_mu0_20mhz_4x4/oru


