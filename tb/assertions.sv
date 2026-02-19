module async_fifo_sva #(
  parameter int SIZE_LOG2 = 5
) (
  // clocks/resets
  input logic write_clk, write_rst_n,
  input logic read_clk, read_rst_n,

  input logic p_write_en, p_write_full,
  input logic p_read_en, p_read_empty,

  input logic [SIZE_LOG2:0] r_write_ptr_bin, r_write_ptr_gray,
  input logic [SIZE_LOG2:0] r_read_ptr_bin, r_read_ptr_gray,
  input logic [SIZE_LOG2:0] w_write_ptr_gray_next, w_read_ptr_gray_next,
  input logic [SIZE_LOG2:0] r_read_ptr_gray_sync2, // into write domain
  input logic [SIZE_LOG2:0] r_write_ptr_gray_sync2 // into read domain
);

function automatic logic [SIZE_LOG2:0] bin2gray(input logic [SIZE_LOG2:0] b);
  return (b >> 1) ^ b;
endfunction


// ## A) Write clock domain (`wr_clk`)

// 1. No write pointer advance when FULL
//    If `wr_full` is asserted, then a write request must not advance the
//    write pointer. The write Gray pointer must also remain stable.
assert property (@(posedge write_clk) disable iff (!write_rst_n)
  (p_write_full && p_write_en) |-> ($stable(r_write_ptr_bin) && $stable(r_write_ptr_gray))
);

// 2. Write pointer increments by exactly one on an accepted write
//    When `wr_en` is high and `wr_full` is low (write accepted), the
//    write binary pointer must increase by exactly 1 on the next cycle.
assert property (@(posedge write_clk) disable iff (!write_rst_n)
  (p_write_full && p_write_en) |-> (r_write_ptr_bin == ($past(r_write_ptr_bin + 1)))
);

// 3. Gray pointer must match binary pointer encoding
//    At all times (outside reset), the write Gray pointer must equal
//    the Gray encoding of the write binary pointer.
assert property (@(posedge write_clk) disable iff (!write_rst_n)
  (p_write_full && p_write_en) |-> (bin2gray(r_write_ptr_bin) == r_write_ptr_gray)
);

// 4. Gray pointer changes by at most one bit per cycle
//    Between consecutive `wr_clk` cycles, the write Gray pointer must
//    change by zero bits (no increment) or exactly one bit (one
//    increment). Any multi-bit Gray change indicates a bug.
assert property (@(posedge write_clk) disable iff (!write_rst_n)
  (p_write_full && p_write_en) |-> ($onehot($past(r_write_ptr_gray) ^ r_write_ptr_gray))
);

// 5. FULL flag must match the standard full condition
//    The registered/full output must equal the “full_next” condition
//    computed from the next write Gray pointer compared against the
//    synchronized read Gray pointer, using the classic two-MSB inversion
//    rule (Gray-domain full detection).


// 6. No unknowns after reset
//    After reset is deasserted, `wr_full` and the write pointers must
//    never be X/Z.



// ## B) Read clock domain (`rd_clk`)

// 7. No read pointer advance when EMPTY
//    If `rd_empty` is asserted, then a read request must not advance
//    the read pointer. The read Gray pointer must also remain stable.
assert property (@(posedge read_clk) disable iff (!read_rst_n)
  (p_read_empty && p_read_en) |-> ($stable(r_read_ptr_bin) && $stable(r_read_ptr_gray))
);

// 8. Read pointer increments by exactly one on an accepted read
//    When `rd_en` is high and `rd_empty` is low (read accepted), the
//    read binary pointer must increase by exactly 1 on the next cycle.
assert property (@(posedge read_clk) disable iff (!read_rst_n)
  (p_read_empty && p_read_en) |-> (r_read_ptr_bin == ($past(r_read_ptr_bin + 1)))
);

// 9. Gray pointer must match binary pointer encoding
//    At all times (outside reset), the read Gray pointer must equal the
//    Gray encoding of the read binary pointer.
assert property (@(posedge read_clk) disable iff (!read_rst_n)
  (p_read_empty && p_read_en) |-> (bin2gray(r_read_ptr_bin) == r_read_ptr_gray)
);

// 10. Gray pointer changes by at most one bit per cycle
//     Between consecutive `rd_clk` cycles, the read Gray pointer must
//     change by zero bits (no increment) or exactly one bit (one
//     increment).
assert property (@(posedge read_clk) disable iff (!read_rst_n)
  (p_read_empty && p_read_en) |-> ($onehot($past(r_read_ptr_gray) ^ r_read_ptr_gray))
);

// 11. EMPTY flag must match the standard empty condition
//     The registered/empty output must equal the “empty_next” condition
//     computed from the next read Gray pointer compared against the
//     synchronized write Gray pointer (Gray-domain empty detection).


// 12. No unknowns after reset
//     After reset is deasserted, `rd_empty` and the read pointers must
//     never be X/Z.


// ## C) Optional “nice-to-have” assertions (strong portfolio bonus)

// 13. Synchronized remote Gray pointer changes by at most one bit per cycle
//     In each domain, the synchronized copy of the remote Gray pointer
//     should only change by zero or one bit per destination clock cycle.
//     (This is a sanity check; it helps catch wiring/logic errors.)


// 14. Flags only change on clock edges (no combinational glitching)
//     Ensure `wr_full` only updates on `wr_clk` edges and `rd_empty` only
//     updates on `rd_clk` edges (i.e., they are registered outputs and
//     stable between edges).


// 15. If you expose a level/occupancy signal: bounds and monotonic behavior
//     If the FIFO reports “level”, assert it never exceeds DEPTH and
//     never underflows, and that it changes consistently with accepted
//     reads/writes.

endmodule
