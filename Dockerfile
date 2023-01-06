FROM centos:stream8
RUN yum install -y rsync kmod libhugetlbfs libhugetlbfs-devel libhugetlbfs-utils \
        numactl-devel vim python3 pciutils iproute procps-ng expect libatomic \
     && yum clean all \
     && rm -rf /var/cache/yum \
     && pip3 install pyyaml lxml dataclasses \
     && mkdir -p /opt/flexran \
     && mkdir -p /opt/flexran/sdk \
     && mkdir -p /opt/flexran/tests \
     && mkdir -p /opt/flexran/bin

#COPY setting.env /opt/flexran
COPY flexran/bin/nr5g /opt/flexran/bin/nr5g
COPY flexran/bin/multi_rat /opt/flexran/bin/multi_rat
COPY flexran/libs /opt/flexran/libs
COPY flexran/sdk/build-avx512-icx  /opt/flexran/sdk/build-avx512-icx
COPY flexran/tests/nr5g /opt/flexran/tests/nr5g
COPY flexran/wls_mod /opt/flexran/wls_mod
COPY dpdk-21.11 /opt/flexran/dpdk-21.11
COPY intel/oneapi/compiler/2022.2.1/linux/compiler/lib/intel64_lin  /opt/flexran/icx_libs 
COPY intel/oneapi/mkl/2022.2.1/lib/intel64                          /opt/flexran/icx_libs
COPY intel/oneapi/ipp/2021.6.2/lib/intel64                          /opt/flexran/icx_libs
COPY flexran/xran /opt/flexran/xran
COPY cru_env_vars.sh /opt/flexran

ENV flexranPath=/opt/flexran
ENV RTE_SDK=/opt/dpdk-21.11
ENV WIRELESS_SDK_TARGET_ISA=avx512
ENV CPA_DIR=/opt/flexran/libs/cpa
ENV XRAN_DIR=/opt/flexran/xran
ENV DIR_WIRELESS_SDK_ROOT=/opt/flexran/sdk
ENV SDK_BUILD=build-avx512-icx
ENV DIR_WIRELESS_SDK=/opt/flexran/sdk/build-avx512-icx
ENV FLEXRAN_SDK=/opt/flexran/sdk/build-avx512-icx/install
ENV DIR_WIRELESS_FW=/opt/flexran/framework
ENV DIR_WIRELESS_TEST_4G=/opt/flexran/tests/lte
ENV DIR_WIRELESS_TEST_5G=/opt/flexran/tests/nr5g
ENV DIR_WIRELESS_TABLE_5G=/opt/flexran/bin/nr5g/gnb/l1/table

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${flexranPath}/icx_libs:${flexranPath}/wls_mod:${flexranPath}/libs/cpa/bin



WORKDIR /opt/flexran

