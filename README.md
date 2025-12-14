### Benchmarking bit set implementations

1. Naive implementation: counts bits one by one
2. Lookup table implementation: uses a precomputed table for byte values

### Running

```bash
zig build --release=fast
```

### Benchmark
- `<implementation>`: either `(0) naive` or `(1) lookup`
- `<size>`: size of the bit set in bits (e.g., `1000000`)

```bash
./zig-out/bin/bit_bench <implementation> <size>
```