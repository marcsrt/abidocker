# AbiBuildbot Worker - Ubuntu 26.04 Intel oneAPI MKL

Buildbot worker image for ABINIT CI with the Intel oneAPI toolchain.

## Contents

| Component | Version | Notes |
|-----------|---------|-------|
| Base | Ubuntu 26.04 | |
| Fortran | Intel ifx (oneAPI) | via `intel-oneapi-compiler-fortran` |
| MPI | Intel MPI | via `intel-oneapi-mpi-devel` |
| BLAS/LAPACK | Intel oneMKL | via `intel-oneapi-mkl-devel` |
| LibXC | system pkg | `libxc-dev` |
| NetCDF | system pkg | `libnetcdf-dev`, `libnetcdff-dev` |
| HDF5 | system pkg | `libhdf5-dev` |
| FFTW3 | system pkg | `libfftw3-dev` |
| ScaLAPACK | system pkg | `libscalapack-mpi-dev` (best-effort) |
| GCC/gfortran | system pkg | fallback compiler |
| Python | 3.x | numpy, scipy, matplotlib, pyyaml |
| Buildbot worker | latest | via pip |
| Docker CLI | latest | for sibling container control |

## Build

```bash
docker build \
  -f dockerfiles/abibuildbotworker/ubuntu26.04-intel-oneapi-mkl/Dockerfile \
  -t abidocker/abibuildbotworker:ubuntu26.04-intel-oneapi-mkl .
```

## Run

```bash
docker run -d --name abibuildbot-worker-intel \
  -e WORKER_NAME=docker_ubuntu26_04_intel_oneapi_mkl \
  -e MASTER_HOST=127.0.0.1 \
  -e MASTER_PORT=9797 \
  -e WORKER_PASSWORD=secret \
  -v /var/run/docker.sock:/var/run/docker.sock \
  abidocker/abibuildbotworker:ubuntu26.04-intel-oneapi-mkl
```

## ABINIT Configure Hints

```bash
export CC=mpiicc
export CXX=mpiicpc
export FC=mpiifort
export MKLROOT=/opt/intel/oneapi/mkl/latest

./configure \
  --enable-mpi=yes \
  --enable-mpi-io=yes \
  --enable-openmp=yes \
  --with-linalg-flavor=mkl \
  --with-mkl="${MKLROOT}" \
  --with-libxc=yes \
  --with-hdf5=yes \
  --with-netcdf=yes \
  --with-netcdf-fortran=yes \
  --with-fft-flavor=dfti \
  FCFLAGS="-O2 -g -fopenmp -ffree-line-length-none"
```
