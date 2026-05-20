---
name: abidocker
description: >
  Generate Dockerfiles for ABINIT (density-functional theory software) across three categories: build environments,
  ABINIT-installed images, and AbiBuildbot CI workers. Use when creating or modifying Dockerfiles for ABINIT Docker
  images, setting up ABINIT build environments with specific OS/compiler/MPI/math-library combinations, building
  ABINIT from source in Docker, or configuring AbiBuildbot worker containers. Triggers: requests for ABINIT Docker
  images, Dockerfiles for abinit/abienv/abibuildbotworker, ABINIT containerization, or scientific computing Docker
  environments for DFT calculations.
---

# AbiDocker

Generate Dockerfiles for ABINIT Docker images in three categories.

## Categories

1. **build-environment** — Software environment (OS, compiler, MPI, math libs) for building/running ABINIT. Does NOT include ABINIT source or build process.
2. **with-abinit** — Same as build-environment PLUS ABINIT cloned, built, tested, and installed from a specific git version/branch.
3. **abibuildbotworker** — Build-environment PLUS CI worker tools (Python, Git, Docker CLI, Buildbot worker runtime).

## Workflow

1. Determine the category (build-environment / with-abinit / abibuildbotworker).
2. Determine the software stack: OS, compiler, MPI implementation, math libraries.
3. Read the matching reference Dockerfile from `references/` for structural patterns.
4. Generate Dockerfile following the patterns and conventions below.

## Directory & Naming Convention

Dockerfiles live under `dockerfiles/<category>/<os>-<compiler>-<mpi>-<mathlib>/`.

Each directory contains:
- `Dockerfile` — Multi-stage (builder + runtime)
- `install-deps.sh` — OS-specific dependency functions (sourced in Dockerfile RUN)
- `README.md` — Per-configuration docs

Image tag patterns:
- Build env: `abidocker/abienv:<os>-<compiler>-<mpi>-<mathlib>`
- With ABINIT: `abidocker/abinit:<os>-<compiler>-<mpi>-<mathlib>-<version>`
- Worker: `abidocker/abibuildbotworker:<os>-<compiler>-<mpi>-<mathlib>`

Directory name examples: `ubuntu22.04-gcc-netlib`, `ubuntu22.04-gcc-openmpi-openblas`

## Dockerfile Structure (Multi-Stage)

All Dockerfiles use multi-stage builds:

```
Stage 1 (builder):
  FROM <os> AS builder
  COPY install-deps.sh /tmp/
  RUN source /tmp/install-deps.sh && install_build_tools && install_abinit_mandatory_deps && ...
  [For with-abinit: clone source, configure, build, test, install]
  [For abibuildbotworker: install worker tools]

Stage 2 (runtime):
  FROM <os> AS runtime
  COPY install-deps.sh /tmp/
  RUN source /tmp/install-deps.sh && install_runtime_deps && ...
  COPY --from=builder /opt/... /opt/...
  ENV PATH="..." OMP_NUM_THREADS=1
  CMD ["abinit", "--help"]  # or worker-specific CMD
```

## install-deps.sh Convention

Each build env directory has its own `install-deps.sh` with OS-specific package versions. Functions:

| Function | Purpose |
|----------|---------|
| `install_build_tools()` | gcc, gfortran, make, autoconf, automake, libtool, pkg-config, git |
| `install_abinit_mandatory_deps()` | libhdf5-dev, libnetcdf-dev, libnetcdff-dev, libxc-dev, libfftw3-dev, liblapack-dev, libblas-dev |
| `install_mpi(impl)` | openmpi or mpich (parameterized) |
| `install_optimized_linalg(flavor)` | openblas + scalapack (parameterized) |
| `install_python_testing()` | python3, numpy, scipy |
| `install_runtime_deps()` | Runtime .so packages (no -dev), libgfortran5, libgomp1 |
| `cleanup_apt()` / `cleanup_build_artifacts()` | Remove apt cache, tmp, docs |

For a new OS version, create a new `install-deps.sh` with the correct package versions (e.g., `libhdf5-103` on Ubuntu 22.04 vs `libhdf5-310` on Ubuntu 24.04).

## ABINIT Configure Options

Key `./configure` flags for ABINIT builds:

| Flag | Purpose | Example Values |
|------|---------|----------------|
| `--prefix` | Install path | `/opt/abinit` |
| `--enable-mpi` | MPI support | `yes`/`no` |
| `--enable-mpi-io` | MPI-IO for parallel I/O | `yes` |
| `--enable-openmp` | OpenMP threading | `yes` |
| `--with-linalg-flavor` | Linear algebra backend | `netlib`, `openblas`, `mkl` |
| `--with-libxc` | LibXC exchange-correlation | `yes` |
| `--with-hdf5` | HDF5 support | `yes` |
| `--with-netcdf` | NetCDF support | `yes` |
| `--with-netcdf-fortran` | NetCDF Fortran API | `yes` |
| `--with-optim-flavor` | Optimization level | `standard`, `aggressive` |
| `--with-debug-flavor` | Debug level | `basic`, `none` |

Compiler flags (GCC): `FCFLAGS="-O2 -g -fopenmp -ffree-line-length-none -fallow-argument-mismatch"`

For MPI builds: set `FC=mpif90`, `CC=mpicc`, `CXX=mpic++` and add `LINALG_LIBS="-lopenblas -lscalapack-openmpi"`.

## Build Arguments (with-abinit)

| Arg | Default | Description |
|-----|---------|-------------|
| `ABINIT_REPO` | `https://github.com/abinit/abinit.git` | Source repo URL |
| `ABINIT_BRANCH` | `master` | Branch or tag |
| `RUN_TESTS` | `yes` | Run test suite |
| `TEST_SUITE` | `fast`/`paral` | Test suite name |
| `MPI_IMPL` | `openmpi` | MPI implementation |
| `NUM_MPI_PROCS` | `4` | MPI processes for testing |

## MPI in Docker

Set these env vars for OpenMPI in containers:
```
ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
ENV OMPI_MCA_btl_vader_single_copy_mechanism=none
```

## Category-Specific Notes

### build-environment
- Only installs dependencies, does NOT clone or build ABINIT.
- install-deps.sh functions: `install_build_tools`, `install_abinit_mandatory_deps`, optionally `install_mpi`, `install_optimized_linalg`.
- Runtime stage copies no ABINIT binaries.

### with-abinit
- Extends build-environment: clone ABINIT source, run `./autogen.sh`, `./configure`, `make`, `make install`.
- Test suite runs via `./runtests.py`.
- Runtime stage copies `/opt/abinit` from builder.
- Include pseudopotentials: copy `tests/Pspdir` to `/opt/abinit/tests/`.

### abibuildbotworker
- Extends build-environment with: Python 3, Docker CLI for host socket access, Git, and Buildbot worker runtime.
- Must support host Docker socket mounting for trusted workers that need Docker access.
- Should use the Buildbot worker protocol directly, without requiring SSH inside the container.
- CMD should start the worker process, not ABINIT.

## References

- `references/Dockerfile.serial-ubuntu2204-gcc-netlib` — Serial build env template (no MPI)
- `references/Dockerfile.mpi-ubuntu2204-gcc-openmpi-openblas` — MPI+OpenBLAS template
- `references/install-deps-ubuntu2204.sh` — Ubuntu 22.04 dependency script (reference for OS-specific packages)

Read the appropriate reference Dockerfile before generating a new one. Match the multi-stage structure, LABEL conventions, build arg patterns, and COPY/install flow exactly.
