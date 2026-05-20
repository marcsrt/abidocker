# AbiBuildbot Worker: Ubuntu 22.04 GCC OpenMPI OpenBLAS

This image provides an AbiBuildbot worker runtime with an ABINIT build environment based on Ubuntu 22.04, GCC/gfortran, OpenMPI, OpenBLAS, ScaLAPACK, and FFTW3.

The image does not include ABINIT source code or the `abibuildbot` repository. Provide project checkouts, worker configuration, and secrets at runtime.

## Image Tag

`abidocker/abibuildbotworker:ubuntu22.04-gcc-openmpi-openblas`

## Build

```bash
docker build \
  -f dockerfiles/abibuildbotworker/ubuntu22.04-gcc-openmpi-openblas/Dockerfile \
  -t abidocker/abibuildbotworker:ubuntu22.04-gcc-openmpi-openblas \
  dockerfiles/abibuildbotworker/ubuntu22.04-gcc-openmpi-openblas
```

## Runtime Contract

Required environment variables:

- `WORKER_NAME`: Buildbot worker name registered on the master.
- `WORKER_PASSWORD`: Buildbot worker password.
- `MASTER_HOST`: Buildbot master host.
- `MASTER_PORT`: Buildbot worker protocol port.

Instead of `WORKER_PASSWORD`, you may set `WORKER_PASSWORD_FILE` to a mounted secret file path.

Optional mounts:

- `/buildbot-worker`: persistent Buildbot worker base directory.
- `/workdir`: persistent build workspace.
- `/abibuildbot`: runtime-provided `abibuildbot` checkout or helper scripts.
- `/var/run/docker.sock`: host Docker socket for trusted workers that need Docker access.

Mounting `/var/run/docker.sock` gives the container broad control over the host Docker daemon. Use it only for trusted workers.

## Run

```bash
docker run --rm \
  --name abibuildbot-worker \
  -e WORKER_NAME=worker-01 \
  -e WORKER_PASSWORD_FILE=/run/secrets/worker-password \
  -e MASTER_HOST=buildbot.example.org \
  -e MASTER_PORT=9989 \
  -v /path/to/worker-password:/run/secrets/worker-password:ro \
  -v abibuildbot-worker-state:/buildbot-worker \
  -v /path/to/workdir:/workdir \
  -v /path/to/abibuildbot:/abibuildbot:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  abidocker/abibuildbotworker:ubuntu22.04-gcc-openmpi-openblas
```

## Smoke Checks

```bash
docker run --rm abidocker/abibuildbotworker:ubuntu22.04-gcc-openmpi-openblas \
  bash -lc 'gcc --version && gfortran --version && mpirun --version && python3 --version && buildbot-worker --version && docker --version && pkg-config --exists fftw3 && pkg-config --exists openblas && ldconfig -p | grep -i scalapack'
```

ScaLAPACK is installed through Ubuntu's MPI ScaLAPACK development package when available for the target architecture.
