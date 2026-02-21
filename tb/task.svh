// task 01: Reset + initial Empty/Full
// - After reset: p_read_empty=1 and p_write_full=0.
// - Pointers start in a consistent state.
// - No X on flags/outputs.
task automatic test_reset_empty_full_start(
  ref logic write_rst_n,
  ref logic read_rst_n,
  ref logic p_write_en,
  ref logic p_read_en,
  ref logic p_write_full,
  ref logic p_read_empty,
  ref logic write_clk,
  ref logic read_clk
);
  write_rst_n = 0;
  read_rst_n = 0;
  p_read_en = 0;
  p_write_en = 0;

  repeat (2) @(posedge write_clk);
  repeat (2) @(posedge read_clk);

  write_rst_n = 1;
  read_rst_n = 1;

  repeat (2) @(posedge write_clk);
  repeat (2) @(posedge read_clk);

  assert (p_write_full == 0) else $error("test_reset_empty_full_start p_write_full ERR");
  assert (p_read_empty == 1) else $error("test_reset_empty_full_start p_read_empty ERR");
endtask


// task 02: Smoke write N then read N
// - Write a known sequence (0,1,2,...).
// - Read everything afterward.
// - Validate ordering and integrity (no loss/duplication).
task automatic test_smoke_writen_readn(
  ref logic p_write_en,
  ref logic p_read_en,
  ref logic [BITS-1:0] p_write_data,
  ref logic [BITS-1:0] p_read_data,
  ref logic write_clk,
  ref logic read_clk
);

@(posedge read_clk);
p_write_en = 1;
for (int i = 0; i < SIZE; i++) begin
  p_write_data = i;
  @(posedge write_clk);
end

@(posedge read_clk);
p_write_en = 0;
@(posedge read_clk);

p_read_en = 1;
@(posedge read_clk);
for (int i = 0; i < SIZE; i++) begin
  @(posedge read_clk);
  assert (p_read_data == i) else $error("test_smoke_writen_readn ERR %0d != p_read_data = %0d", i, p_read_data);
end

p_read_en = 0;
endtask

// task 03: Interleaved (ping-pong)
// - Write 1, read 1, repeatedly.
// - Different clocks (e.g., write 100 MHz, read 60 MHz).
// - Ensure operation does not depend on filling the FIFO.
task automatic test_interleaved(
  ref logic p_write_en,
  ref logic p_read_en,
  ref logic [BITS-1:0] p_write_data,
  ref logic [BITS-1:0] p_read_data,
  ref logic write_clk,
  ref logic read_clk
);

@(posedge read_clk);
for (int i = 0; i < SIZE; i++) begin
  p_write_en = 1;
  @(posedge read_clk);
  p_write_data = i;
  p_write_en = 0;
  @(posedge read_clk);
  p_write_en = 0;
  p_read_en = 1;
  @(posedge read_clk);
  p_read_en = 0;
  @(posedge read_clk);
  assert (p_read_data == i) else $error("test_interleaved ERR %0d != p_read_data = %0d", i, p_read_data);
end
endtask

// task 04: Write clock much faster than read
// - Example ratio 4:1 (write >> read).
// - Hit full multiple times.
// - No accepted write when full and no corruption.

// task 05: Read clock much faster than write
// - Example ratio 1:4 (read >> write).
// - Hit empty multiple times.
// - No accepted read when empty and no invalid data.

// task 06: Near-equal clocks
// - Example 100 MHz vs 99/101 MHz.
// - Cover phase drift and rare sync corner cases.

// task 07: Jitter / phase randomness
// - Apply small period variation (e.g., +/-1% to +/-5%).
// - Expose edge-alignment corner cases.

// task 08: Random burst traffic
// - Random wr_en/rd_en patterns.
// - Long bursts with long gaps.
// - Scoreboard validates all data.

// task 09: Burst fill/drain
// - Fill to full (or near full), drain to empty.
// - Repeat multiple cycles.
// - Check flag transitions are stable.

// task 10: Sustained throughput
// - Keep write/read active whenever possible.
// - Different clocks.
// - Verify 1 transaction/cycle when applicable.

// task 11: Overflow attempt (write while full)
// - Force p_write_en=1 while p_write_full=1 for many cycles.
// - Verify write pointer does not advance.
// - Verify memory/data is not corrupted.
// - Verify normal recovery after leaving full.

// task 12: Underflow attempt (read while empty)
// - Force p_read_en=1 while p_read_empty=1.
// - Verify read pointer does not advance.
// - Verify no data skipping.
// - Verify correct reads when new data arrives.

// task 13: Wrap-around (multiple turns)
// - Run at least 10x DEPTH transactions.
// - Cover multiple pointer wrap events.
// - Catch MSB/full/empty comparison bugs.

// task 14: Depth variants
// - Regress on small DEPTH (4 or 8), medium (16), optional larger (64).
// - Catch $clog2 and indexing bugs.

// task 15: Width variants
// - Regress with BITS=8 and BITS=32.
// - Catch packing and memory-width bugs.

// task 16: Simultaneous reset in both domains
// - Reset write/read together (nominal flow).
// - Check clean return to initial state.

// task 17: Asymmetric reset (one domain reset, other running)
// - Example: reset write while read keeps running.
// - Behavior must be supported or explicitly restricted.
// - Even if unsupported, avoid severe X/glitch behavior.

// task 18: Reset during traffic
// - Apply reset in the middle of writes/reads.
// - Characterize supported vs restricted behavior.
// - Verify controlled recovery after reset.
