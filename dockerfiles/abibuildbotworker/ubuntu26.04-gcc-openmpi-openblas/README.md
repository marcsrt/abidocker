# AbiBuildbot Worker: Ubuntu 26.04 GCC OpenMPI OpenBLAS

This image provides an AbiBuildbot worker runtime with Ubuntu 26.04 package versions of GCC/gfortran, OpenMPI, OpenBLAS, ScaLAPACK, FFTW3, LibXC, HDF5, and NetCDF.

The image does not include ABINIT source code or the `abibuildbot` repository. Buildbot checks out ABINIT at runtime.

## Image Tag

`abidocker/abibuildbotworker:ubuntu26.04-gcc-openmpi-openblas`

## Build

```bash
docker build \
  -f dockerfiles/abibuildbotworker/ubuntu26.04-gcc-openmpi-openblas/Dockerfile \
  -t abidocker/abibuildbotworker:ubuntu26.04-gcc-openmpi-openblas \
  dockerfiles/abibuildbotworker/ubuntu26.04-gcc-openmpi-openblas
```

## Smoke Check

```bash
docker run --rm abidocker/abibuildbotworker:ubuntu26.04-gcc-openmpi-openblas \
  bash -lc 'gcc --version && gfortran --version && mpirun --version && python3 --version && buildbot-worker --version && pkg-config --exists fftw3 && pkg-config --exists openblas && pkg-config --exists libxc && pkg-config --exists netcdf && ldconfig -p | grep -i scalapack'
```

## Buildbot Worker

The matching AbiBuildbot worker name is `docker_ubuntu26_04_gnu_openmpi_openblas` and the matching builder is `docker_ubuntu26.04_gnu_openmpi_openblas`.
