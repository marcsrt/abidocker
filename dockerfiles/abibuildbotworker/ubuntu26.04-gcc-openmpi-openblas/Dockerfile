FROM ubuntu:26.04

ARG DEBIAN_FRONTEND=noninteractive

LABEL maintainer="AbiDocker"
LABEL description="AbiBuildbot worker with Ubuntu 26.04, GCC, OpenMPI, OpenBLAS, ScaLAPACK, FFTW3, LibXC, and NetCDF"
LABEL org.opencontainers.image.title="AbiBuildbot Worker Ubuntu 26.04 GCC OpenMPI OpenBLAS"
LABEL org.opencontainers.image.description="Buildbot worker runtime for ABINIT CI with current Ubuntu MPI and scientific libraries"

ENV OMPI_ALLOW_RUN_AS_ROOT=1 \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
    OMPI_MCA_btl_vader_single_copy_mechanism=none \
    OMP_NUM_THREADS=1 \
    WORKER_BASEDIR=/buildbot-worker \
    WORKDIR=/workdir

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
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
        libblas-dev \
        libfftw3-dev \
        libhdf5-dev \
        liblapack-dev \
        libnetcdf-dev \
        libnetcdff-dev \
        libopenblas-dev \
        libopenblas-openmp-dev \
        libopenmpi-dev \
        libtool \
        libxc-dev \
        libxml2-dev \
        make \
        openmpi-bin \
        pkg-config \
        python-is-python3 \
        python3 \
        python3-matplotlib \
        python3-numpy \
        python3-pip \
        python3-scipy \
        python3-yaml \
        wget && \
    if apt-get install -y --no-install-recommends libscalapack-mpi-dev; then \
        echo "ScaLAPACK installed successfully"; \
    else \
        echo "Warning: ScaLAPACK package unavailable on this platform"; \
    fi && \
    python3 -m pip install --break-system-packages --no-cache-dir buildbot-worker && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /usr/local/bin/abibuildbot-worker-entrypoint
RUN chmod +x /usr/local/bin/abibuildbot-worker-entrypoint && \
    mkdir -p "${WORKER_BASEDIR}" "${WORKDIR}"

WORKDIR /workdir

ENTRYPOINT ["/usr/local/bin/abibuildbot-worker-entrypoint"]
CMD ["start"]
