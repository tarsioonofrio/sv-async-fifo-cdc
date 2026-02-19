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
│   └── test_async_fifo.sv        # SystemVerilog testbench
├── sim/
│   ├── Makefile
│   └── waves/                    # generated
└── docs/
    └── design.md                 # deeper notes & diagrams
```

---

## Verification

### What is tested

- Basic push/pop ordering (FIFO correctness)
- Randomized traffic with backpressure
- Many clock ratios:
  - `write_clk` faster than `read_clk`
  - `read_clk` faster than `write_clk`
  - close frequencies + phase drift
- Reset behavior (including mid-traffic resets, if enabled)
- Corner cases at wrap boundaries

### Suggested SVA (examples)

- No write when full: `p_write_full |-> !accept_write`
- No read when empty: `p_read_empty |-> !accept_read`
- Data stability under backpressure (if applicable)
- Pointer monotonicity within each domain

---

## How to Run Simulation

### Using ModelSim/Questa (recommended)

From `sim/` (uses `sim/Makefile`):

```bash
make build
make run
make test
make waves
make clean
```

`sim/Makefile` prepends the ModelSim path via:

```make
MODELSIM_BIN ?= /opt/intelFPGA/20.1/modelsim_ase/bin
```

If your installation is in another location:

```bash
cd sim
make MODELSIM_BIN=/path/to/modelsim/bin build
make MODELSIM_BIN=/path/to/modelsim/bin run
```

---

## Integration Notes (practical)

- Connect `p_write_full` to your upstream backpressure logic
- Connect `p_read_empty` to your downstream request logic
- Avoid combinational paths between clock domains

---

## Roadmap (if you want to grow the IP)

- [ ] Add formal properties (optional)
- [ ] Add programmable thresholds (`almost_full/empty`)
- [ ] Add dual-port RAM inference templates for FPGA/ASIC
- [ ] Add optional fall-through (FWFT) read mode

---

## References

1. Clifford E. Cummings and Peter Alfke, _Simulation and Synthesis Techniques for Asynchronous FIFO Design_, SNUG San Jose 2002. Official technical library listing: https://www.sunburst-design.com/papers/ . Public PDF access: https://www.researchgate.net/publication/252160343_Simulation_and_Synthesis_Techniques_for_Asynchronous_FIFO_Design

---

## License

MIT (or your preferred license).
