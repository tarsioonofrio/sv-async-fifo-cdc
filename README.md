# sv-async-fifo-cdc

A **CDC-safe asynchronous FIFO** written in **SystemVerilog**, designed for robust clock-domain crossing (CDC) between independent write and read clocks.

This repository targets an "industry-style" IP deliverable: clean RTL, clear interface contract, repeatable simulation, and verification artifacts (SystemVerilog testbench + optional assertions).

---

## Highlights

- **True async FIFO** for CDC: independent `write_clk` and `read_clk`
- **Modular RTL**: `rtl/async_fifo.sv` + dedicated `rtl/sync_2ff.sv`
- **Gray-coded pointers** with **2FF synchronizers** (classic, silicon-proven approach)
- Parameterized **BITS** and **SIZE** (power-of-two SIZE recommended)
- Clean flags: `full`, `empty`, optional `almost_full/empty` and fill levels
- Verification-ready: self-checking tests + stress tests across clock ratios/jitter
- Optional **SystemVerilog Assertions (SVA)** to lock down protocol and invariants

---

## Signal Naming Convention

- `p_`: module ports (inputs/outputs), except clock/reset.
- `r_`: registered signals (`always_ff` state).
- `w_`: combinational/internal wires.
- Clock/reset exception: use plain names without prefix, e.g. `write_clk`, `write_rst_n`, `read_clk`, `read_rst_n`.

---

## Why this FIFO is CDC-safe

Async FIFO correctness hinges on avoiding metastability propagation across domains. This implementation follows the standard approach:

1. Maintain **binary pointers** locally in each domain (write/read).
2. Convert pointers to **Gray code**.
3. Send Gray pointers across domains through **2-flop synchronizers**.
4. Convert synchronized Gray pointers back to binary locally.
5. Compute `full`/`empty` by comparing pointers in the **same clock domain**.

This avoids sampling multi-bit binary counters asynchronously, which can break due to metastability and intermediate transitions.

This implementation is based on the design approach presented in the paper _Simulation and Synthesis Techniques for Asynchronous FIFO Design_.

---

## Interface

### Write Domain (write_clk)

| Signal                   | Dir | Description                                           |
| ------------------------ | --: | ----------------------------------------------------- |
| `write_clk`              |  in | Write clock                                           |
| `write_rst_n`            |  in | Active-low asynchronous write reset                   |
| `p_write_en`             |  in | Write request (one entry per cycle when accepted)     |
| `p_write_data[BITS-1:0]` |  in | Data to write                                         |
| `p_write_full`           | out | FIFO full flag (do not write when 1)                  |
| `p_write_almost_full`    | out | (Optional) Programmable threshold                     |
| `p_write_level`          | out | (Optional) Approximate fill level (write domain view) |

**Write acceptance rule**  
A write is accepted on a rising edge of `write_clk` when:

- `p_write_en == 1` and `p_write_full == 0`

### Read Domain (read_clk)

| Signal                  | Dir | Description                                          |
| ----------------------- | --: | ---------------------------------------------------- |
| `read_clk`              |  in | Read clock                                           |
| `read_rst_n`            |  in | Active-low asynchronous read reset                   |
| `p_read_en`             |  in | Read request (one entry per cycle when accepted)     |
| `p_read_data[BITS-1:0]` | out | Data read                                            |
| `p_read_empty`          | out | FIFO empty flag (do not read when 1)                 |
| `p_read_almost_empty`   | out | (Optional) Programmable threshold                    |
| `p_read_level`          | out | (Optional) Approximate fill level (read domain view) |

**Read acceptance rule**  
A read is accepted on a rising edge of `read_clk` when:

- `p_read_en == 1` and `p_read_empty == 0`

---

## Parameters

- `BITS` (default: 32)  
  Width of each FIFO entry.
- `SIZE` (default: 16)  
  Number of entries. **Recommended: power-of-two** for simpler pointer logic.
- `ADDR_WIDTH` (optional derived)  
  `$clog2(SIZE)`; pointer width often uses `ADDR_WIDTH+1` to detect wrap.

Optional:

- `ALMOST_FULL_TH` / `ALMOST_EMPTY_TH`
- `SYNC_STAGES` (default 2)

---

## Reset & Initialization Notes

- The FIFO uses **per-domain active-low asynchronous resets** (`write_rst_n`, `read_rst_n`).
- On reset, pointers go to zero; flags initialize to:
  - `empty = 1`
  - `full = 0`

**CDC recommendation**: ensure both domains are reset to a consistent state, and synchronize reset deassertion per clock domain when required by your integration guidelines.

---

## Timing / Throughput

- **Max throughput:** 1 write per `write_clk` cycle + 1 read per `read_clk` cycle (when not full/empty)
- Latency depends on the chosen memory style (reg array vs inferred RAM).  
  For ASIC/FPGA inference, the FIFO can be adapted to:
  - Distributed regs (small SIZEs)
  - SRAM/BRAM (larger SIZEs)

---

## Directory Structure

```
.
├── rtl/
│   ├── async_fifo.sv
│   └── sync_2ff.sv
├── tb/
│   ├── test_async_fifo.sv        # SystemVerilog testbench
│   └── assertions.sv             # SVA checks
├── sim/
│   ├── Makefile
│   └── waves/                    # generated
└── docs/
    └── design.md                 # deeper notes & diagrams
```

---

## Verification

### What is tested

- Reset sanity and initial flags
- Smoke sequence (write N then read N)
- Interleaved traffic (ping-pong write/read)
- Write clock faster than read clock (stress full-side behavior)
- Read clock faster than write clock (stress empty-side behavior)

### Test Matrix

| `TEST` generic         | Objective                          | Status |
| ---------------------- | ---------------------------------- | ------ |
| `reset`                | Reset sanity (`empty=1`, `full=0`) | Ready  |
| `smoke`                | Ordered write/read data integrity  | Ready  |
| `interleaved`          | Ping-pong write/read flow          | Ready  |
| `write-clock-faster`   | Stress when write dominates read   | Ready  |
| `read-clock-faster`    | Stress when read dominates write   | Ready  |
| `""` (empty / regress) | Run all tests above in sequence    | Ready  |

### Assertions (SVA): What Is Checked

- Write domain protocol safety (no illegal pointer advance on full)
- Read domain protocol safety (no illegal pointer advance on empty)
- Pointer/Gray encoding consistency checks
- Gray transition sanity checks
- Flag consistency checks (`full`/`empty` equations)
- Unknown/X checks after reset deassertion

Note: ModelSim Intel Edition compiles SVA but reports limited support warnings;
full SVA feature support is available in Questa.

---

## How to Run Simulation

### Using ModelSim/Questa (recommended)

From project root (uses `Makefile`):

```bash
make build
make run
make test
make regress
make waves
make clean
```

`make test` and `make regress` both execute the regression when `TEST` is empty.

Run a single test:

```bash
make test TEST=smoke
make test TEST=write-clock-faster
```

Run with explicit generics:

```bash
make test TEST=read-clock-faster SEED=11 BITS=8 SIZE=8
```

`Makefile` prepends the ModelSim path via:

```make
MODELSIM_BIN ?= /opt/intelFPGA/20.1/modelsim_ase/bin
```

If your installation is in another location:

```bash
make MODELSIM_BIN=/path/to/modelsim/bin build
make MODELSIM_BIN=/path/to/modelsim/bin run
```

---

## Integration Notes (practical)

- Connect `p_write_full` to your upstream backpressure logic
- Connect `p_read_empty` to your downstream request logic
- Avoid combinational paths between clock domains

---

## Limitations / Assumptions

- `SIZE` is expected to be power-of-two (`async_fifo.sv` enforces this)
- Testbench currently targets ModelSim/Questa command-line flow
- SVA execution in ModelSim Intel Edition has feature limitations/warnings
- Current verification is simulation-based (no formal proof in this repo yet)

---

## TODO

### SVA (pending)

- [ ] Complete assertions 5 and 11 (full/empty flag equivalence with Gray-domain next-state conditions)
- [ ] Implement assertions 6 and 12 (no X/Z after reset deassertion for flags and pointers)
- [ ] Add optional assertions 13 and 14 (synced Gray one-bit change, no flag glitching between edges)
- [ ] Review and fix antecedents in existing properties to match accepted transactions (`p_write_en && !p_write_full`, `p_read_en && !p_read_empty`)
- [ ] Run SVA-enabled simulation and capture a clean pass report

### Regression tests (pending)

- [ ] Add `make regress` matrix with multiple `BITS`/`SIZE` combinations
- [ ] Add deterministic multi-test runs by `NAME` and fixed `SEED` set
- [ ] Add wrap-around focused regression case (>= 10x depth transactions)
- [ ] Add overflow/underflow stress regression with scoreboard checks
- [ ] Publish regression summary (tests, seeds, params, pass/fail) in CI/log output

### Optional IP growth

- [ ] Add formal properties
- [ ] Add programmable thresholds (`almost_full/empty`)
- [ ] Add dual-port RAM inference templates for FPGA/ASIC
- [ ] Add optional fall-through (FWFT) read mode

---

## References

1. Clifford E. Cummings and Peter Alfke, _Simulation and Synthesis Techniques for Asynchronous FIFO Design_, SNUG San Jose 2002. Official technical library listing: https://www.sunburst-design.com/papers/ . Public PDF access: https://www.researchgate.net/publication/252160343_Simulation_and_Synthesis_Techniques_for_Asynchronous_FIFO_Design
2. Jason Yu, _Dual-Clock Asynchronous FIFO in SystemVerilog_, VerilogPro: https://www.verilogpro.com/asynchronous-fifo-design/

---

## License

MIT (or your preferred license).
