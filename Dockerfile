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

COPY flexran/bin/nr5g /opt/flexran/bin/nr5g
COPY flexran/bin/multi_rat /opt/flexran/bin/multi_rat
COPY flexran/libs /opt/flexran/libs
COPY flexran/sdk/build-avx512-icx  /opt/flexran/sdk/build-avx512-icx
COPY flexran/tests/nr5g /opt/flexran/tests/nr5g
COPY flexran/wls_mod /opt/flexran/wls_mod
COPY dpdk-21.11 /opt/flexran/dpdk-21.11

# Note, /opt/flexran/icx_libs is hardcoded in sdk.env

COPY intel/oneapi/compiler/latest/linux/compiler/lib/intel64_lin  /opt/flexran/icx_libs 
COPY intel/oneapi/mkl/latest/lib/intel64                          /opt/flexran/icx_libs
COPY intel/oneapi/ipp/latest/lib/intel64                          /opt/flexran/icx_libs
COPY flexran/xran /opt/flexran/xran
COPY sdk.env /opt/flexran

WORKDIR /opt/flexran

