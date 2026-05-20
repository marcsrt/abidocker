# Build Environment Dockerfiles

This directory contains Dockerfiles for building the software environment in which ABINIT can be built and run. These images provide the build environment but do NOT include ABINIT itself.

## Directory Structure

```
build-environment/
├── ubuntu22.04-gcc-netlib/   # Serial build environment (Ubuntu 22.04)
│   ├── Dockerfile
│   ├── install-deps.sh       # Ubuntu 22.04-specific dependencies
│   └── README.md
└── ubuntu22.04-gcc-openmpi-openblas/  # MPI build environment (Ubuntu 22.04)
    ├── Dockerfile
    ├── install-deps.sh       # Ubuntu 22.04-specific dependencies
    └── README.md
```

**Note**: Each build environment directory contains its own `install-deps.sh` script with OS-specific package versions. For example, `ubuntu22.04-gcc-netlib/install-deps.sh` contains package versions specific to Ubuntu 22.04.

## Available Build Environments

| OS | Compiler | MPI | Math Lib | Directory | Description | Use Case |
|----|----------|-----|----------|-----------|-------------|----------|
| Ubuntu 22.04 | GCC/gfortran | No | Netlib BLAS/LAPACK | `ubuntu22.04-gcc-netlib/` | Minimal/Serial | Testing, CI/CD |
| Ubuntu 22.04 | GCC/gfortran | OpenMPI | OpenBLAS + ScaLAPACK | `ubuntu22.04-gcc-openmpi-openblas/` | MPI Parallel | Production |

## Image Naming Convention

Images follow the pattern: `abidocker/abienv:<os>-<compiler>-<mpi>-<mathlib>`

Examples:
- `abidocker/abienv:ubuntu22.04-gcc-netlib`
- `abidocker/abienv:ubuntu22.04-gcc-openmpi-openblas`

## Build All Environments

```bash
# Serial build environment
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-gcc-netlib/Dockerfile \
  -t abidocker/abienv:ubuntu22.04-gcc-netlib \
  dockerfiles/build-environment/ubuntu22.04-gcc-netlib

# MPI build environment
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-gcc-openmpi-openblas/Dockerfile \
  -t abidocker/abienv:ubuntu22.04-gcc-openmpi-openblas \
  dockerfiles/build-environment/ubuntu22.04-gcc-openmpi-openblas
```

## Dependencies

Each build environment directory contains an `install-deps.sh` script with OS-specific package versions. Each script provides the following functions:

- `install_build_tools()` - Build essentials (gcc, gfortran, make, autoconf, etc.)
- `install_abinit_mandatory_deps()` - Required libraries (HDF5, NetCDF, LibXC, FFTW3)
- `install_mpi()` - MPI implementation (openmpi or mpich)
- `install_optimized_linalg()` - Optimized linear algebra (openblas)
- `install_python_testing()` - Python for test suite
- `install_runtime_deps()` - Runtime-only dependencies
- `cleanup_apt()` / `cleanup_build_artifacts()` - Image size optimization
