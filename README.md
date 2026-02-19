# sv-async-fifo-cdc

A **CDC-safe asynchronous FIFO** written in **SystemVerilog**, designed for robust clock-domain crossing (CDC) between independent write and read clocks.

This repository targets an "industry-style" IP deliverable: clean RTL, clear interface contract, repeatable simulation, and verification artifacts (cocotb + assertions).

---

## Highlights

- **True async FIFO** for CDC: independent `wr_clk` and `rd_clk`
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
- Clock/reset exception: use plain names without prefix, e.g. `wr_clk`, `wr_rst_n`, `rd_clk`, `rd_rst_n`.

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

### Write Domain (wr_clk)

| Signal                | Dir | Description                                           |
| --------------------- | --: | ----------------------------------------------------- |
| `wr_clk`              |  in | Write clock                                           |
| `wr_rst_n`            |  in | Active-low write reset (async or sync — see notes)    |
| `p_wr_en`             |  in | Write request (one entry per cycle when accepted)     |
| `p_wr_data[BITS-1:0]` |  in | Data to write                                         |
| `p_wr_full`           | out | FIFO full flag (do not write when 1)                  |
| `p_wr_almost_full`    | out | (Optional) Programmable threshold                     |
| `p_wr_level`          | out | (Optional) Approximate fill level (write domain view) |

**Write acceptance rule**  
A write is accepted on a rising edge of `wr_clk` when:

- `p_wr_en == 1` and `p_wr_full == 0`

### Read Domain (rd_clk)

| Signal                | Dir | Description                                          |
| --------------------- | --: | ---------------------------------------------------- |
| `rd_clk`              |  in | Read clock                                           |
| `rd_rst_n`            |  in | Active-low read reset                                |
| `p_rd_en`             |  in | Read request (one entry per cycle when accepted)     |
| `p_rd_data[BITS-1:0]` | out | Data read                                            |
| `p_rd_empty`          | out | FIFO empty flag (do not read when 1)                 |
| `p_rd_almost_empty`   | out | (Optional) Programmable threshold                    |
| `p_rd_level`          | out | (Optional) Approximate fill level (read domain view) |

**Read acceptance rule**  
A read is accepted on a rising edge of `rd_clk` when:

- `p_rd_en == 1` and `p_rd_empty == 0`

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

- The FIFO uses **per-domain resets** (`wr_rst_n`, `rd_rst_n`).
- On reset, pointers go to zero; flags initialize to:
  - `empty = 1`
  - `full = 0`

**CDC recommendation**: ensure resets are applied such that both domains start from a consistent state. If resets are asynchronous, consider synchronizing reset deassertion per domain.

---

## Timing / Throughput

- **Max throughput:** 1 write per `wr_clk` cycle + 1 read per `rd_clk` cycle (when not full/empty)
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
│   ├── sync_2ff.sv
│   └── gray_pkg.sv
├── tb/
│   ├── test_async_fifo.sv        # cocotb tests
│   └── assertions.sv             # optional SVA bind file
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
  - `wr_clk` faster than `rd_clk`
  - `rd_clk` faster than `wr_clk`
  - close frequencies + phase drift
- Reset behavior (including mid-traffic resets, if enabled)
- Corner cases at wrap boundaries

### Suggested SVA (examples)

- No write when full: `p_wr_full |-> !accept_write`
- No read when empty: `p_rd_empty |-> !accept_read`
- Data stability under backpressure (if applicable)
- Pointer monotonicity within each domain

---

## How to Run Simulation

### Using ModelSim/Questa (recommended)

From `sim/`:

```bash
make SIM=questa
make waves
```

### Using open-source simulators (optional)

If supported:

```bash
make SIM=iverilog
```

---

## Integration Notes (practical)

- Connect `p_wr_full` to your upstream backpressure logic
- Connect `p_rd_empty` to your downstream request logic
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
