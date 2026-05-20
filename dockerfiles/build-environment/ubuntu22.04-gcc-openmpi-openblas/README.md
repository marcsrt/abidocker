# ABINIT MPI + OpenBLAS Docker Configuration

This Docker configuration builds ABINIT with MPI support and optimized OpenBLAS libraries for production parallel calculations.

## Configuration Details

**Build Type**: MPI + OpenBLAS (parallel)  
**Compilers**: GCC with MPI wrappers (mpif90, mpicc, mpic++)  
**MPI Implementation**: OpenMPI (default) or MPICH  
**Parallelization**: MPI + OpenMP hybrid  
**Linear Algebra**: OpenBLAS + ScaLAPACK  
**FFT**: FFTW3  
**Mandatory Libraries**: LibXC, HDF5, NetCDF  

## Use Cases

- **Production calculations**: Real-world DFT simulations
- **Parallel computing**: Multi-core and multi-node runs
- **HPC environments**: Cluster and supercomputer deployments
- **Large systems**: Calculations requiring significant computational resources

## Image Size & Build Time

- **Builder stage**: ~4-5 GB
- **Final runtime image**: ~1.5 - 2 GB
- **Build time**: ~25-40 minutes (depending on hardware)

## Build Instructions

### Basic Build

From the project root directory:

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-gcc-openmpi-openblas/Dockerfile \
  -t abidocker/abinit:mpi-openblas \
  .
```

### Build from Specific ABINIT Version

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-gcc-openmpi-openblas/Dockerfile \
  --build-arg ABINIT_REPO=https://github.com/abinit/abinit.git \
  --build-arg ABINIT_BRANCH=9.10.3 \
  -t abidocker/abinit:9.10.3-mpi \
  .
```

### Build with MPICH Instead of OpenMPI

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-gcc-openmpi-openblas/Dockerfile \
  --build-arg MPI_IMPL=mpich \
  -t abidocker/abinit:mpi-openblas-mpich \
  .
```

### Build Without Tests (Faster)

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-gcc-openmpi-openblas/Dockerfile \
  --build-arg RUN_TESTS=no \
  -t abidocker/abinit:mpi-openblas-notests \
  .
```

### Build with Custom MPI Test Configuration

```bash
docker build \
  -f dockerfiles/build-environment/ubuntu22.04-gcc-openmpi-openblas/Dockerfile \
  --build-arg NUM_MPI_PROCS=8 \
  --build-arg TEST_SUITE=paral \
  -t abidocker/abinit:mpi-openblas \
  .
```

## Usage Instructions

### Run with MPI (Single Node)

```bash
# Run with 4 MPI processes
docker run --rm \
  -v $(pwd):/workspace \
  abidocker/abinit:mpi-openblas \
  mpirun -np 4 abinit input.in
```

### Run with MPI + OpenMP Hybrid

```bash
# 4 MPI processes × 2 OpenMP threads = 8 cores total
docker run --rm \
  -e OMP_NUM_THREADS=2 \
  -v $(pwd):/workspace \
  abidocker/abinit:mpi-openblas \
  mpirun -np 4 abinit input.in
```

### Run with Specific CPU Binding

```bash
docker run --rm \
  --cpus="8.0" \
  -v $(pwd):/workspace \
  abidocker/abinit:mpi-openblas \
  mpirun -np 8 --bind-to core abinit input.in
```

### Interactive Shell

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  abidocker/abinit:mpi-openblas \
  /bin/bash
```

### Check Versions

```bash
# ABINIT version
docker run --rm abidocker/abinit:mpi-openblas abinit --version

# MPI version
docker run --rm abidocker/abinit:mpi-openblas mpirun --version

# OpenBLAS info
docker run --rm abidocker/abinit:mpi-openblas \
  /bin/bash -c "dpkg -l | grep openblas"
```

### View Build Information

```bash
docker run --rm abidocker/abinit:mpi-openblas cat /opt/abinit/BUILD_INFO
```

## Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `ABINIT_REPO` | `https://github.com/abinit/abinit.git` | Git repository URL |
| `ABINIT_BRANCH` | `master` | Git branch or tag to checkout |
| `RUN_TESTS` | `yes` | Run test suite during build (`yes`/`no`) |
| `TEST_SUITE` | `paral` | Test suite name (`paral`/`v1`/`v2`/etc) |
| `MPI_IMPL` | `openmpi` | MPI implementation (`openmpi`/`mpich`) |
| `NUM_MPI_PROCS` | `4` | Number of MPI processes for testing |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PATH` | `/opt/abinit/bin:$PATH` | Includes ABINIT binaries |
| `ABI_PSPDIR` | `/opt/abinit/tests/Pspdir` | Pseudopotential directory |
| `OMP_NUM_THREADS` | `1` | OpenMP thread count |
| `OMPI_ALLOW_RUN_AS_ROOT` | `1` | Allow MPI as root (Docker) |
| `OMPI_MCA_btl_vader_single_copy_mechanism` | `none` | Fix OpenMPI in containers |

## Performance Tuning

### MPI Process Count

Choose based on your system:

```bash
# Rule of thumb: 1 MPI process per physical core
# For 8-core system:
mpirun -np 8 abinit input.in

# For 32-core system:
mpirun -np 32 abinit input.in
```

### Hybrid MPI + OpenMP

For best performance on modern CPUs:

```bash
# Example: 16-core system
# 4 MPI × 4 OpenMP = 16 cores
docker run --rm \
  --cpus="16.0" \
  -e OMP_NUM_THREADS=4 \
  -v $(pwd):/workspace \
  abidocker/abinit:mpi-openblas \
  mpirun -np 4 abinit input.in
```

### Memory Allocation

```bash
# Allocate 16 GB memory
docker run --rm \
  --memory="16g" \
  -v $(pwd):/workspace \
  abidocker/abinit:mpi-openblas \
  mpirun -np 4 abinit input.in
```

## Parallel Efficiency

This configuration provides:

- **Linear scaling** up to ~32 cores for typical DFT calculations
- **Good efficiency** (>80%) for systems with 100+ atoms
- **Hybrid parallelization** for modern multi-core architectures

Actual performance depends on:
- System size (number of atoms)
- K-point sampling density
- Basis set size (ecut)
- Network latency (for multi-node runs)

## Multi-Node Deployment

For multi-node clusters, you'll need:

1. **Shared filesystem**: NFS or similar for input/output
2. **Network configuration**: Low-latency network (InfiniBand recommended)
3. **MPI configuration**: Proper hostfile and network settings
4. **Container orchestration**: Kubernetes, Slurm, or similar

Example with Docker Compose (2 nodes):

```yaml
version: '3.8'
services:
  node1:
    image: abidocker/abinit:mpi-openblas
    volumes:
      - ./data:/workspace
    networks:
      - mpi-network
  node2:
    image: abidocker/abinit:mpi-openblas
    volumes:
      - ./data:/workspace
    networks:
      - mpi-network
networks:
  mpi-network:
```

## Comparison with Minimal/Serial

| Feature | Minimal/Serial | MPI + OpenBLAS |
|---------|----------------|----------------|
| Parallelization | OpenMP only | MPI + OpenMP |
| Max cores | Limited (~16) | Unlimited |
| Multi-node | No | Yes |
| Linear algebra | netlib (basic) | OpenBLAS (optimized) |
| ScaLAPACK | No | Yes |
| Performance | Baseline | 2-10× faster |
| Image size | ~500 MB | ~1.5-2 GB |
| Use case | Testing, learning | Production |

## Limitations

- **Container networking**: MPI across containers requires special configuration
- **GPU support**: Not included (see GPU configurations)
- **Intel MKL**: Not included (see Intel MKL configuration for better performance)

## Troubleshooting

### MPI fails with "unable to find a useable PMI component"

Add to docker run:
```bash
-e OMPI_MCA_pmix=^s1,s2,cray,isolated
```

### "Read -1, expected X, errno = 1" error

This is OpenMPI's shared memory issue in containers. Already fixed via:
```bash
OMPI_MCA_btl_vader_single_copy_mechanism=none
```

### Performance lower than expected

1. Check CPU allocation: `docker run --cpus="N"`
2. Verify MPI process count matches available cores
3. Monitor with: `docker stats`
4. Consider hybrid MPI+OpenMP instead of pure MPI

### Out of memory

1. Increase Docker memory: `docker run --memory="16g"`
2. Reduce system size or k-points in ABINIT input
3. Use more nodes with fewer processes per node

## Example: Parallel Calculation

```bash
# Create input file for parallel calculation
cat > parallel-input.in << 'EOF'
# Silicon bulk calculation with k-point parallelism
ndtset 1
paral_kgb 1  # Enable band/FFT/k-point parallelism

# ... rest of ABINIT input ...
EOF

# Run with 8 MPI processes
docker run --rm \
  --cpus="8.0" \
  -v $(pwd):/workspace \
  abidocker/abinit:mpi-openblas \
  mpirun -np 8 abinit parallel-input.in
```

## Benchmarking

To benchmark performance:

```bash
# Run with timing
docker run --rm \
  -v $(pwd):/workspace \
  abidocker/abinit:mpi-openblas \
  /bin/bash -c "time mpirun -np 4 abinit input.in"

# Extract timing from output
grep "Proc.   0 individual time" outputfile
```

## Further Information

- ABINIT Parallelization Guide: <https://docs.abinit.org/guide/parallelism/>
- OpenMPI Documentation: <https://www.open-mpi.org/doc/>
- OpenBLAS Project: <https://www.openblas.net/>
- ScaLAPACK: <https://www.netlib.org/scalapack/>
