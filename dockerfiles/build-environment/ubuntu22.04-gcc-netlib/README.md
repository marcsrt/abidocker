# ABINIT Minimal/Serial Docker Configuration

This Docker configuration builds ABINIT with minimal dependencies for single-core calculations without MPI support.

## Configuration Details

**Build Type**: Minimal/Serial (no MPI)  
**Compilers**: GCC, gfortran, g++  
**Parallelization**: OpenMP threading only  
**Linear Algebra**: Netlib BLAS/LAPACK  
**FFT**: FFTW3  
**Mandatory Libraries**: LibXC, HDF5, NetCDF  

## Use Cases

- **Educational purposes**: Learning ABINIT basics
- **Quick testing**: Fast calculations on small systems
- **CI/CD**: Automated build verification
- **Development**: Testing code changes with minimal overhead

## Image Size & Build Time

- **Builder stage**: ~3-4 GB
- **Final runtime image**: ~500 MB - 1 GB
- **Build time**: ~20-30 minutes (depending on hardware)

## Build Instructions

### Basic Build

From the project root directory:

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-gcc-netlib/Dockerfile \
  -t abidocker/abinit:minimal-serial \
  .
```

### Build from Specific ABINIT Version

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-gcc-netlib/Dockerfile \
  --build-arg ABINIT_REPO=https://github.com/abinit/abinit.git \
  --build-arg ABINIT_BRANCH=9.10.3 \
  -t abidocker/abinit:9.10.3-minimal \
  .
```

### Build Without Running Tests

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-gcc-netlib/Dockerfile \
  --build-arg RUN_TESTS=no \
  -t abidocker/abinit:minimal-serial-notests \
  .
```

### Build with Custom Test Suite

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-gcc-netlib/Dockerfile \
  --build-arg TEST_SUITE=v1 \
  -t abidocker/abinit:minimal-serial-v1 \
  .
```

## Usage Instructions

### Interactive Shell

Start a container with an interactive shell:

```bash
docker run -it --rm abidocker/abinit:minimal-serial /bin/bash
```

### Run ABINIT with Input File

Mount your working directory and run ABINIT:

```bash
docker run --rm \
  -v $(pwd):/workspace \
  abidocker/abinit:minimal-serial \
  abinit < input.in > output.log
```

### Run with Multiple OpenMP Threads

```bash
docker run --rm \
  -e OMP_NUM_THREADS=4 \
  -v $(pwd):/workspace \
  abidocker/abinit:minimal-serial \
  abinit input.in
```

### Check ABINIT Version

```bash
docker run --rm abidocker/abinit:minimal-serial abinit --version
```

### View Build Information

```bash
docker run --rm abidocker/abinit:minimal-serial cat /opt/abinit/BUILD_INFO
```

### Access Test Results

Test results from the build process are saved in the image:

```bash
docker run --rm abidocker/abinit:minimal-serial cat /opt/abinit/test-results/test.log
```

## Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `ABINIT_REPO` | `https://github.com/abinit/abinit.git` | Git repository URL |
| `ABINIT_BRANCH` | `master` | Git branch or tag to checkout |
| `RUN_TESTS` | `yes` | Run test suite during build (`yes`/`no`) |
| `TEST_SUITE` | `fast` | Which test suite to run (`fast`/`v1`/`v2`/etc) |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PATH` | `/opt/abinit/bin:$PATH` | Includes ABINIT binaries |
| `ABI_PSPDIR` | `/opt/abinit/tests/Pspdir` | Pseudopotential directory |
| `OMP_NUM_THREADS` | `1` | OpenMP thread count |

## Limitations

This minimal configuration has the following limitations:

- **No MPI**: Cannot run parallel calculations across multiple processes
- **No GPU support**: CPU-only calculations
- **Basic libraries**: Uses netlib BLAS/LAPACK (not optimized)
- **Limited features**: Some advanced ABINIT features may require additional libraries

For production calculations or HPC environments, consider using the MPI or Intel MKL configurations.

## Included ABINIT Binaries

The following executables are available in `/opt/abinit/bin/`:

- `abinit` - Main DFT calculation program
- `anaddb` - Analysis of derivative databases
- `cut3d` - Cuts and analyzes 3D files
- `aim` - Atoms in molecules analysis
- `optic` - Optical properties calculation
- `mrgddb` - Merge derivative databases
- `mrgdv` - Merge first-order derivatives
- `mrggkk` - Merge GKK files

## Example Workflow

```bash
# 1. Create a working directory
mkdir my-abinit-calc && cd my-abinit-calc

# 2. Create an input file (input.in)
# ... your ABINIT input ...

# 3. Run ABINIT in Docker
docker run --rm \
  -v $(pwd):/workspace \
  abidocker/abinit:minimal-serial \
  abinit input.in > output.log

# 4. Analyze results
ls -lh  # Check output files
```

## Troubleshooting

### Build fails during compilation
- Ensure you have sufficient disk space (~10 GB)
- Check Docker has enough memory allocated (recommend 4+ GB)
- Review build logs: `docker build ... 2>&1 | tee build.log`

### Tests fail during build
- Some test failures are expected with minimal configuration
- To skip tests: `--build-arg RUN_TESTS=no`
- Review test logs in `/opt/abinit/test-results/test.log`

### Out of memory during run
- Reduce system size in ABINIT input
- Reduce OMP_NUM_THREADS
- Allocate more memory to Docker

## Further Information

- ABINIT Documentation: <https://docs.abinit.org/>
- ABINIT Forum: <https://discourse.abinit.org/>
- Project Repository: See main README.md
