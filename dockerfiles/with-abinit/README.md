# With-ABINIT Dockerfiles

This directory contains Dockerfiles that produce Docker images with ABINIT pre-installed. These images include ABINIT binaries built with the specified software environment.

## Image Naming Convention

Images follow the pattern: `abidocker/abinit:<os>-<compiler>-<mpi>-<mathlib>-<version>`

The version can be:
- A specific git tag (e.g., `9.10.3`)
- A git branch (e.g., `master`, `release-9.10`)
- A custom identifier (e.g., `git-main`)

Examples:
- `abidocker/abinit:ubuntu22.04-gcc-netlib-master`
- `abidocker/abinit:ubuntu22.04-gcc-openmpi-openblas-9.10.3`

## How These Images Are Built

These images are typically built using a two-stage process:

1. **Stage 1 (Builder)**: Use a build-environment image to compile ABINIT
2. **Stage 2 (Runtime)**: Copy the compiled ABINIT into a minimal runtime image

The Dockerfile pattern:

```dockerfile
# Use build environment
FROM abidocker/abienv:<build-env> AS builder

# Clone and build ABINIT
RUN git clone --branch <version> <abinit-repo> && \
    cd abinit && ./configure && make install

# Use minimal runtime base
FROM ubuntu:22.04 AS runtime

# Copy ABINIT from builder
COPY --from=builder /opt/abinit /opt/abinit
```

## Available Configurations

TODO: Add configurations as they are created.

## Adding a New Configuration

1. Create a subdirectory for your configuration
2. Create a Dockerfile that:
   - Uses a build-environment image for compilation
   - Copies the installed ABINIT to a runtime image
3. Document the build process in a README.md
4. Update this file with the new configuration

## Usage

```bash
# Pull an existing image
docker pull abidocker/abinit:<tag>

# Run ABINIT
docker run --rm abidocker/abinit:<tag> abinit --version

# Run with input file
docker run --rm -v $(pwd):/workspace abidocker/abinit:<tag> abinit input.in
```
