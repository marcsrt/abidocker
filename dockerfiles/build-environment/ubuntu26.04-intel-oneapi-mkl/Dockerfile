# Multi-stage Dockerfile for ABINIT (Intel oneAPI + MKL Configuration)
# Ubuntu 26.04 with Intel ifx, Intel MPI, oneMKL, LibXC, NetCDF, HDF5
#
# Build arguments:
#   ABINIT_REPO: Git repository URL for ABINIT source
#   ABINIT_BRANCH: Git branch or tag to checkout
#   RUN_TESTS: Whether to run test suite during build (yes/no)
#   TEST_SUITE: Which test suite to run (fast/paral/v1/v2/etc)
#   NUM_MPI_PROCS: Number of MPI processes for testing

FROM ubuntu:26.04 AS builder

ARG ABINIT_REPO=https://github.com/abinit/abinit.git
ARG ABINIT_BRANCH=master
ARG RUN_TESTS=yes
ARG TEST_SUITE=fast
ARG NUM_MPI_PROCS=4
ARG DEBIAN_FRONTEND=noninteractive

LABEL stage=builder
LABEL description="ABINIT builder stage with Intel oneAPI (ifx + MPI + MKL)"

COPY install-deps.sh /tmp/install-deps.sh
RUN bash -c "source /tmp/install-deps.sh && \
    install_build_tools && \
    setup_intel_oneapi_repo && \
    install_intel_oneapi && \
    install_abinit_mandatory_deps && \
    install_optimized_linalg && \
    install_python_testing && \
    cleanup_apt"

ENV PATH="/opt/intel/oneapi/compiler/latest/bin:/opt/intel/oneapi/mpi/latest/bin:/opt/intel/oneapi/mkl/latest/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/intel/oneapi/compiler/latest/lib:/opt/intel/oneapi/mpi/latest/lib:/opt/intel/oneapi/mkl/latest/lib:${LD_LIBRARY_PATH:-}"
ENV CPATH="/opt/intel/oneapi/mkl/latest/include:${CPATH:-}"
ENV MKLROOT="/opt/intel/oneapi/mkl/latest"

ENV FC=mpiifort
ENV CC=mpiicc
ENV CXX=mpiicpc
ENV MAKEFLAGS="-j$(nproc)"

ENV I_MPI_ROOT=/opt/intel/oneapi/mpi/latest

WORKDIR /tmp/abinit-build

RUN echo "Cloning ABINIT from ${ABINIT_REPO} (branch: ${ABINIT_BRANCH})..." && \
    git clone --depth 1 --branch "${ABINIT_BRANCH}" "${ABINIT_REPO}" abinit-src && \
    cd abinit-src && \
    ABINIT_VERSION=$(cat .current_version 2>/dev/null || echo "unknown") && \
    echo "ABINIT Version: ${ABINIT_VERSION}" && \
    echo "${ABINIT_VERSION}" > /tmp/ABINIT_VERSION && \
    chmod -R u+w .

RUN cd abinit-src && \
    echo "Configuring ABINIT (Intel oneAPI + MKL)..." && \
    if [ -x ./config/scripts/makemake ]; then \
      ./config/scripts/makemake; \
    elif [ -x ./autogen.sh ]; then \
      ./autogen.sh; \
    fi && \
    mkdir build && cd build && \
    ../configure \
        --prefix=/opt/abinit \
        --enable-mpi=yes \
        --enable-mpi-io=yes \
        --enable-openmp=yes \
        --with-linalg-flavor=mkl \
        --with-mkl="${MKLROOT}" \
        --with-fft-flavor=dfti \
        --with-libxc=yes \
        --with-hdf5=yes \
        --with-netcdf=yes \
        --with-netcdf-fortran=yes \
        --with-optim-flavor=standard \
        --with-debug-flavor=basic \
        FCFLAGS="-O2 -g -fopenmp -ffree-line-length-none" \
        CFLAGS="-O2 -g" \
        > /tmp/configure.log 2>&1 && \
    echo "Configuration complete. See /tmp/configure.log for details."

RUN cd abinit-src/build && \
    echo "Building ABINIT with $(nproc) parallel jobs..." && \
    make -j$(nproc) > /tmp/build.log 2>&1 && \
    echo "Build complete. See /tmp/build.log for details."

RUN cd abinit-src/build && \
    echo "Installing ABINIT to /opt/abinit..." && \
    make install > /tmp/install.log 2>&1 && \
    echo "Installation complete."

RUN /opt/abinit/bin/abinit --version && \
    echo "ABINIT binaries installed successfully"

RUN mkdir -p /opt/abinit/tests && \
    cp -r /tmp/abinit-build/abinit-src/tests/Pspdir /opt/abinit/tests/ && \
    echo "Pseudopotentials copied"

RUN if [ "${RUN_TESTS}" = "yes" ]; then \
        echo "Running ABINIT test suite: ${TEST_SUITE} with ${NUM_MPI_PROCS} MPI processes..." && \
        cd /tmp/abinit-build/abinit-src/tests && \
        export PATH="/opt/abinit/bin:${PATH}" && \
        mkdir -p /opt/abinit/test-results && \
        ./runtests.py ${TEST_SUITE} -n${NUM_MPI_PROCS} -j2 2>&1 | tee /opt/abinit/test-results/test.log || \
        echo "Tests completed with some failures (check test.log for details)"; \
    else \
        echo "Skipping test suite (RUN_TESTS=${RUN_TESTS})"; \
    fi

RUN echo "Build Date: $(date -u)" > /opt/abinit/BUILD_INFO && \
    echo "ABINIT Version: $(cat /tmp/ABINIT_VERSION)" >> /opt/abinit/BUILD_INFO && \
    echo "ABINIT Repository: ${ABINIT_REPO}" >> /opt/abinit/BUILD_INFO && \
    echo "ABINIT Branch: ${ABINIT_BRANCH}" >> /opt/abinit/BUILD_INFO && \
    echo "Configuration: intel-oneapi-mkl" >> /opt/abinit/BUILD_INFO && \
    echo "Compiler: Intel ifx $(ifx --version 2>/dev/null | head -1)" >> /opt/abinit/BUILD_INFO && \
    echo "MPI: Intel MPI" >> /opt/abinit/BUILD_INFO && \
    echo "Linear Algebra: Intel oneMKL" >> /opt/abinit/BUILD_INFO && \
    echo "FFT: DFTI (MKL)" >> /opt/abinit/BUILD_INFO && \
    cat /opt/abinit/BUILD_INFO

# =============================================================================
# Stage 2: Runtime
# =============================================================================
FROM ubuntu:26.04 AS runtime

ARG DEBIAN_FRONTEND=noninteractive

LABEL maintainer="AbiDocker"
LABEL description="ABINIT - Intel oneAPI + MKL Configuration on Ubuntu 26.04"
LABEL org.opencontainers.image.title="ABINIT Intel oneAPI + MKL (Ubuntu 26.04)"
LABEL org.opencontainers.image.description="ABINIT atomic-scale simulation software - Intel ifx + MPI + oneMKL build on Ubuntu 26.04"
LABEL org.opencontainers.image.url="https://www.abinit.org"
LABEL org.opencontainers.image.documentation="https://docs.abinit.org"
LABEL org.opencontainers.image.source="https://github.com/abinit/abinit"

COPY install-deps.sh /tmp/install-deps.sh
RUN bash -c "source /tmp/install-deps.sh && \
    install_build_tools && \
    setup_intel_oneapi_repo && \
    install_intel_oneapi && \
    install_runtime_deps && \
    cleanup_apt"

COPY --from=builder /opt/abinit /opt/abinit
COPY --from=builder /tmp/ABINIT_VERSION /opt/abinit/VERSION

ENV PATH="/opt/intel/oneapi/compiler/latest/bin:/opt/intel/oneapi/mpi/latest/bin:/opt/intel/oneapi/mkl/latest/bin:/opt/abinit/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/intel/oneapi/compiler/latest/lib:/opt/intel/oneapi/mpi/latest/lib:/opt/intel/oneapi/mkl/latest/lib:${LD_LIBRARY_PATH:-}"
ENV ABI_PSPDIR="/opt/abinit/tests/Pspdir"
ENV OMP_NUM_THREADS=1
ENV MKLROOT="/opt/intel/oneapi/mkl/latest"

WORKDIR /workspace

RUN abinit --version && \
    mpirun --version && \
    echo "ABINIT with Intel MPI is ready to use!"

RUN cat /opt/abinit/BUILD_INFO

CMD ["abinit", "--help"]
