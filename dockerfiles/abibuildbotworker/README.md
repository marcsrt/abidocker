# AbiBuildbot Worker Dockerfiles

This directory contains Dockerfiles for creating Docker images suitable for running AbiBuildbot workers. These images include both the ABINIT build environment AND the tools required to run an AbiBuildbot worker (Python, CI/CD tooling, etc.).

## Image Naming Convention

Images follow the pattern: `abidocker/abibuildbotworker:<os>-<compiler>-<mpi>-<mathlib>`

Examples:
- `abidocker/abibuildbotworker:ubuntu22.04-gcc-netlib`
- `abidocker/abibuildbotworker:ubuntu22.04-gcc-openmpi-openblas`

## What's Included

An AbiBuildbot worker image includes:

### Build Environment
- Compiler toolchain (GCC, gfortran)
- MPI implementation (OpenMPI or MPICH)
- Linear algebra libraries (OpenBLAS, ScaLAPACK)
- Required dependencies (HDF5, NetCDF, LibXC, FFTW3)

### Worker Tools
- Python 3.x
- Git
- Docker CLI (for host Docker socket access when mounted)
- Buildbot worker protocol runtime
- Required Python packages for Buildbot worker operation

## Directory Structure

```
abibuildbotworker/
├── ubuntu22.04-gcc-netlib/    # Serial worker
│   ├── Dockerfile
│   └── README.md
└── ubuntu22.04-gcc-openmpi-openblas/  # MPI worker
    ├── Dockerfile
    ├── entrypoint.sh
    └── README.md
```

## Usage

### Build a Worker Image

```bash
docker build \
  -f dockerfiles/abibuildbotworker/ubuntu22.04-gcc-openmpi-openblas/Dockerfile \
  -t abidocker/abibuildbotworker:ubuntu22.04-gcc-openmpi-openblas \
  dockerfiles/abibuildbotworker/ubuntu22.04-gcc-openmpi-openblas
```

## Available Configurations

| OS | Compiler | MPI | Math Lib | Directory | Status |
|----|----------|-----|----------|-----------|--------|
| Ubuntu 22.04 | GCC/gfortran | OpenMPI | OpenBLAS + ScaLAPACK | `ubuntu22.04-gcc-openmpi-openblas/` | Available |

### Run as a Worker

```bash
docker run -d \
  --name abibuildbot-worker \
  -e WORKER_NAME=worker-01 \
  -e WORKER_PASSWORD_FILE=/run/secrets/worker-password \
  -e MASTER_HOST=<abibuildbot-master-host> \
  -e MASTER_PORT=<worker-port> \
  -v /path/to/worker-password:/run/secrets/worker-password:ro \
  -v abibuildbot-worker-state:/buildbot-worker \
  -v /path/to/workdir:/workdir \
  -v /var/run/docker.sock:/var/run/docker.sock \
  abidocker/abibuildbotworker:ubuntu22.04-gcc-openmpi-openblas
```

Mount `/var/run/docker.sock` only for trusted workers that need host Docker access.

## AbiBuildbot Integration

These images are designed to work with the AbiBuildbot CI system. For more information about AbiBuildbot, see the [main project documentation](../../README.md).

## Adding a New Configuration

1. Create a subdirectory for your configuration
2. Create a Dockerfile that:
   - Extends a build-environment image
   - Adds worker-specific tools (Python, Git, Docker CLI, Buildbot worker)
   - Configures the worker startup
3. Document the configuration in a README.md
4. Update this file with the new configuration
