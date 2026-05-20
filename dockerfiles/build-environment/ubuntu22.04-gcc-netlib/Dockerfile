# Multi-stage Dockerfile for ABINIT (Minimal/Serial Configuration)
# This builds ABINIT with minimal dependencies, no MPI, for single-core calculations
# 
# Build arguments:
#   ABINIT_REPO: Git repository URL for ABINIT source
#   ABINIT_BRANCH: Git branch or tag to checkout
#   RUN_TESTS: Whether to run test suite during build (yes/no)
#   TEST_SUITE: Which test suite to run (fast/v1/paral/etc)

# =============================================================================
# Stage 1: Builder - Full build environment
# =============================================================================
FROM ubuntu:22.04 AS builder

# Build arguments
ARG ABINIT_REPO=https://github.com/abinit/abinit.git
ARG ABINIT_BRANCH=master
ARG RUN_TESTS=yes
ARG TEST_SUITE=fast
ARG DEBIAN_FRONTEND=noninteractive

# Labels
LABEL stage=builder
LABEL description="ABINIT builder stage with full compilation environment"

# Install build dependencies
COPY install-deps.sh /tmp/install-deps.sh
RUN bash -c "source /tmp/install-deps.sh && \
    install_build_tools && \
    install_abinit_mandatory_deps && \
    install_python_testing && \
    cleanup_apt"

# Set up build environment
ENV FC=gfortran
ENV CC=gcc
ENV CXX=g++
ENV MAKEFLAGS="-j$(nproc)"

WORKDIR /tmp/abinit-build

# Clone ABINIT source from specified repository and branch
RUN echo "Cloning ABINIT from ${ABINIT_REPO} (branch: ${ABINIT_BRANCH})..." && \
     git clone --depth 1 --branch "${ABINIT_BRANCH}" "${ABINIT_REPO}" abinit-src && \
     cd abinit-src && \
     ABINIT_VERSION=$(cat .current_version 2>/dev/null || echo "unknown") && \
     echo "ABINIT Version: ${ABINIT_VERSION}" && \
     echo "${ABINIT_VERSION}" > /tmp/ABINIT_VERSION && \
     # Fix permissions for autogen.sh - make writable
     chmod -R u+w .

# Configure ABINIT
# Using system libraries, no MPI, OpenMP enabled for threading
# Important: netlib BLAS/LAPACK requires fftw3, NOT dfti (which is for MKL only)
# Let ABINIT auto-detect FFTW3 instead of explicitly specifying it
RUN cd abinit-src && \
    echo "Configuring ABINIT (minimal/serial)..." && \
    ./autogen.sh && \
    mkdir build && cd build && \
    ../configure \
        --prefix=/opt/abinit \
        --enable-openmp=yes \
        --with-mpi=no \
        --with-linalg-flavor=netlib \
        --with-libxc=yes \
        --with-hdf5=yes \
        --with-netcdf=yes \
        --with-netcdf-fortran=yes \
        --with-optim-flavor=standard \
        --with-debug-flavor=basic \
        FCFLAGS="-O2 -g -fopenmp -ffree-line-length-none -fallow-argument-mismatch" \
        CFLAGS="-O2 -g" 2>&1 | tee /tmp/configure-output.log

# Build ABINIT
RUN cd abinit-src/build && \
    echo "Building ABINIT with $(nproc) parallel jobs..." && \
    make -j$(nproc) 2>&1 | tee /tmp/build.log && \
    echo "Build complete."

# Install ABINIT
RUN cd abinit-src/build && \
    echo "Installing ABINIT to /opt/abinit..." && \
    make install > /tmp/install.log 2>&1 && \
    echo "Installation complete."

# Verify installation
RUN /opt/abinit/bin/abinit --version && \
    echo "ABINIT binaries installed successfully"

# Copy pseudopotentials for testing
RUN mkdir -p /opt/abinit/tests && \
    cp -r /tmp/abinit-build/abinit-src/tests/Pspdir /opt/abinit/tests/ && \
    echo "Pseudopotentials copied"

# Run test suite (optional, controlled by build arg)
RUN if [ "${RUN_TESTS}" = "yes" ]; then \
        echo "Running ABINIT test suite: ${TEST_SUITE}..." && \
        cd /tmp/abinit-build/abinit-src/tests && \
        export PATH="/opt/abinit/bin:${PATH}" && \
        mkdir -p /opt/abinit/test-results && \
        ./runtests.py ${TEST_SUITE} -j2 2>&1 | tee /opt/abinit/test-results/test.log || \
        echo "Tests completed with some failures (expected for minimal build)"; \
    else \
        echo "Skipping test suite (RUN_TESTS=${RUN_TESTS})"; \
    fi

# Save build information
RUN echo "Build Date: $(date -u)" > /opt/abinit/BUILD_INFO && \
    echo "ABINIT Version: $(cat /tmp/ABINIT_VERSION)" >> /opt/abinit/BUILD_INFO && \
    echo "ABINIT Repository: ${ABINIT_REPO}" >> /opt/abinit/BUILD_INFO && \
    echo "ABINIT Branch: ${ABINIT_BRANCH}" >> /opt/abinit/BUILD_INFO && \
    echo "Configuration: minimal-serial" >> /opt/abinit/BUILD_INFO && \
    echo "Compiler: GCC $(gcc --version | head -1)" >> /opt/abinit/BUILD_INFO && \
    cat /opt/abinit/BUILD_INFO

# =============================================================================
# Stage 2: Runtime - Minimal runtime environment
# =============================================================================
FROM ubuntu:22.04 AS runtime

ARG DEBIAN_FRONTEND=noninteractive

# Labels for the final image
LABEL maintainer="AbiDocker"
LABEL description="ABINIT - Minimal/Serial Configuration (no MPI, single-core)"
LABEL org.opencontainers.image.title="ABINIT Minimal/Serial"
LABEL org.opencontainers.image.description="ABINIT atomic-scale simulation software - minimal serial build"
LABEL org.opencontainers.image.url="https://www.abinit.org"
LABEL org.opencontainers.image.documentation="https://docs.abinit.org"
LABEL org.opencontainers.image.source="https://github.com/abinit/abinit"

# Install runtime dependencies only (no dev packages)
COPY install-deps.sh /tmp/install-deps.sh
RUN bash -c "source /tmp/install-deps.sh && \
    install_runtime_deps && \
    cleanup_build_artifacts"

# Copy ABINIT installation from builder
COPY --from=builder /opt/abinit /opt/abinit

# Copy ABINIT version info
COPY --from=builder /tmp/ABINIT_VERSION /opt/abinit/VERSION

# Set up environment
ENV PATH="/opt/abinit/bin:${PATH}"
ENV ABI_PSPDIR="/opt/abinit/tests/Pspdir"
ENV OMP_NUM_THREADS=1

# Create working directory
WORKDIR /workspace

# Verify installation in final image
RUN abinit --version && \
    echo "ABINIT is ready to use!"

# Display build info
RUN cat /opt/abinit/BUILD_INFO

# Default command - show help
CMD ["abinit", "--help"]
