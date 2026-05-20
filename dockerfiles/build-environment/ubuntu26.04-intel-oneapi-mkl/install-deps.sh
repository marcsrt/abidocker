#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

install_build_tools() {
    log_info "Installing build tools..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential gfortran gcc g++ make autoconf automake libtool \
        pkg-config ca-certificates wget curl git gnupg
    log_info "Build tools installed successfully"
}

setup_intel_oneapi_repo() {
    log_info "Setting up Intel oneAPI APT repository..."
    curl -fsSL https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
        | gpg --dearmor | tee /usr/share/keyrings/intel-oneapi-archive-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/intel-oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
        > /etc/apt/sources.list.d/oneAPI.list
    apt-get update
    log_info "Intel oneAPI repository configured"
}

install_intel_oneapi() {
    log_info "Installing Intel oneAPI (ifx, MPI, MKL)..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        intel-oneapi-compiler-fortran \
        intel-oneapi-mpi-devel \
        intel-oneapi-mkl-devel
    log_info "Intel oneAPI installed successfully"
}

install_abinit_mandatory_deps() {
    log_info "Installing ABINIT mandatory dependencies..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libhdf5-dev libnetcdf-dev libnetcdff-dev libxc-dev libfftw3-dev \
        liblapack-dev libblas-dev
    log_info "Mandatory dependencies installed successfully"
}

install_optimized_linalg() {
    log_info "Installing optimized linear algebra..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libopenblas-dev libopenblas-openmp-dev || true
    if apt-get install -y --no-install-recommends libscalapack-mpi-dev 2>/dev/null; then
        log_info "ScaLAPACK installed successfully"
    else
        log_warn "ScaLAPACK not available"
    fi
    log_info "Optimized linear algebra installed"
}

install_python_testing() {
    log_info "Installing Python for test suite..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3 python3-pip python3-numpy python3-scipy python3-yaml python-is-python3
    log_info "Python testing dependencies installed"
}

install_runtime_deps() {
    log_info "Installing runtime dependencies..."
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libhdf5-310 libnetcdf22 libnetcdff7 libxc9 libfftw3-3 \
        liblapack3 libblas3 libgfortran-15-dev libgomp1
    log_info "Runtime dependencies installed"
}

cleanup_apt() {
    log_info "Cleaning up apt cache..."
    apt-get clean
    rm -rf /var/lib/apt/lists/*
    log_info "Cleanup complete"
}
