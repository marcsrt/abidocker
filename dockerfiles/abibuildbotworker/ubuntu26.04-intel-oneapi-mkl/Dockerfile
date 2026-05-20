FROM ubuntu:26.04

ARG DEBIAN_FRONTEND=noninteractive

LABEL maintainer="AbiDocker"
LABEL description="AbiBuildbot worker with Ubuntu 26.04, Intel oneAPI (ifx, IntelMPI, MKL), LibXC, NetCDF, HDF5"
LABEL org.opencontainers.image.title="AbiBuildbot Worker Ubuntu 26.04 Intel oneAPI MKL"
LABEL org.opencontainers.image.description="Buildbot worker runtime for ABINIT CI with Intel oneAPI Fortran compiler, Intel MPI, oneMKL, LibXC, NetCDF, HDF5"

ENV OMPI_ALLOW_RUN_AS_ROOT=1 \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    OMPI_MCA_btl_vader_single_copy_mechanism=none \
    OMP_NUM_THREADS=1 \
    WORKER_BASEDIR=/buildbot-worker \
    WORKDIR=/workdir

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        build-essential \
        ca-certificates \
        curl \
        docker.io \
        g++ \
        gcc \
        gfortran \
        git \
        gnupg \
        libhdf5-dev \
        liblapack-dev \
        libblas-dev \
        libnetcdf-dev \
        libnetcdff-dev \
        libopenblas-dev \
        libtool \
        libxc-dev \
        libxml2-dev \
        make \
        pkg-config \
        python-is-python3 \
        python3 \
        python3-matplotlib \
        python3-numpy \
        python3-pip \
        python3-scipy \
        python3-yaml \
        wget && \
    if apt-get install -y --no-install-recommends libfftw3-dev; then \
        echo "FFTW3 installed"; \
    else \
        echo "Warning: FFTW3 unavailable"; \
    fi && \
    if apt-get install -y --no-install-recommends libscalapack-mpi-dev; then \
        echo "ScaLAPACK installed"; \
    else \
        echo "Warning: ScaLAPACK unavailable"; \
    fi && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -fsSL https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    | gpg --dearmor | tee /usr/share/keyrings/intel-oneapi-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/intel-oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
    > /etc/apt/sources.list.d/oneAPI.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        intel-oneapi-compiler-fortran \
        intel-oneapi-mpi-devel \
        intel-oneapi-mkl-devel && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH="/opt/intel/oneapi/compiler/latest/bin:/opt/intel/oneapi/mpi/latest/bin:/opt/intel/oneapi/mkl/latest/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/intel/oneapi/compiler/latest/lib:/opt/intel/oneapi/mpi/latest/lib:/opt/intel/oneapi/mkl/latest/lib" \
    CPATH="/opt/intel/oneapi/mkl/latest/include" \
    MKLROOT="/opt/intel/oneapi/mkl/latest" \
    I_MPI_ROOT="/opt/intel/oneapi/mpi/latest"

RUN python3 -m pip install --break-system-packages --no-cache-dir buildbot-worker && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY dockerfiles/abibuildbotworker/ubuntu26.04-intel-oneapi-mkl/entrypoint.sh /usr/local/bin/abibuildbot-worker-entrypoint
RUN chmod +x /usr/local/bin/abibuildbot-worker-entrypoint && \
    mkdir -p "${WORKER_BASEDIR}" "${WORKDIR}"

WORKDIR /workdir

ENTRYPOINT ["/usr/local/bin/abibuildbot-worker-entrypoint"]
CMD ["start"]
