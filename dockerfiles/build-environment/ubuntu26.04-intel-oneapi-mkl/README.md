# ABINIT Intel oneAPI + MKL Docker Configuration (Ubuntu 26.04)

This Docker configuration builds ABINIT with the Intel oneAPI toolchain: ifx Fortran compiler, Intel MPI, and Intel oneMKL on Ubuntu 26.04.

## Configuration Details

**Build Type**: Intel oneAPI + MKL (parallel)
**Base Image**: Ubuntu 26.04
**Fortran Compiler**: Intel ifx (oneAPI, not classic ifort)
**C/C++ Compilers**: Intel icx/icpx
**MPI**: Intel MPI
**Linear Algebra**: Intel oneMKL (BLAS, LAPACK, ScaLAPACK, FFT)
**FFT**: DFTI (via MKL)
**Additional Libraries**: LibXC, HDF5, NetCDF C/Fortran, FFTW3

## Build Instructions

### Basic Build

From the project root directory:

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu26.04-intel-oneapi-mkl/Dockerfile \
  -t abidocker/abinit:ubuntu26-intel-mkl \
  .
```

### Build from Specific ABINIT Version

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu26.04-intel-oneapi-mkl/Dockerfile \
  --build-arg ABINIT_BRANCH=9.10.3 \
  -t abidocker/abinit:9.10.3-intel-mkl \
  .
```

### Build Without Tests

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu26.04-intel-oneapi-mkl/Dockerfile \
  --build-arg RUN_TESTS=no \
  -t abidocker/abinit:ubuntu26-intel-mkl-notests \
  .
```

## Usage

### Run with Intel MPI

```bash
docker run --rm \
  -v $(pwd):/workspace \
  abidocker/abinit:ubuntu26-intel-mkl \
  mpirun -np 4 abinit input.in
```

### Run with MPI + OpenMP

```bash
docker run --rm \
  -e OMP_NUM_THREADS=2 \
  -v $(pwd):/workspace \
  abidocker/abinit:ubuntu26-intel-mkl \
  mpirun -np 4 abinit input.in
```

### Interactive Shell

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  abidocker/abinit:ubuntu26-intel-mkl \
  /bin/bash
```

## Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `ABINIT_REPO` | `https://github.com/abinit/abinit.git` | Git repository URL |
| `ABINIT_BRANCH` | `master` | Git branch or tag |
| `RUN_TESTS` | `yes` | Run test suite (`yes`/`no`) |
| `TEST_SUITE` | `fast` | Test suite name |
| `NUM_MPI_PROCS` | `4` | MPI processes for testing |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `MKLROOT` | Path to oneMKL installation |
| `PATH` | Includes ABINIT, Intel compiler, MPI, MKL binaries |
| `LD_LIBRARY_PATH` | Intel runtime libraries |
| `OMP_NUM_THREADS` | OpenMP thread count (default: 1) |

## Comparison with GCC + OpenBLAS

| Feature | GCC + OpenBLAS | Intel oneAPI + MKL |
|---------|---------------|-------------------|
| Compiler | GCC 15 | Intel ifx |
| MPI | OpenMPI 5 | Intel MPI |
| BLAS/LAPACK | OpenBLAS | oneMKL |
| FFT | FFTW3 | DFTI (MKL) |
| Image size | ~1.5-2 GB | ~3-4 GB (oneAPI is larger) |
