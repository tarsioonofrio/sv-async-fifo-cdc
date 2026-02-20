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


// ## A) Write clock domain (`write_clk`)

// 1. No write pointer advance when FULL
//    If `p_write_full` is asserted, then a write request must not advance the
//    write pointer. The write Gray pointer must also remain stable.
assert property (@(posedge write_clk) disable iff (!write_rst_n)
  (p_write_full && p_write_en) |=> ($stable(r_write_ptr_bin) && $stable(r_write_ptr_gray))
);

// 2. Write pointer increments by exactly one on an accepted write
//    When `p_write_en` is high and `p_write_full` is low (write accepted), the
//    write binary pointer must increase by exactly 1 on the next cycle.
assert property (@(posedge write_clk) disable iff (!write_rst_n)
  (!p_write_full && p_write_en) |=> (r_write_ptr_bin == $past(r_write_ptr_bin) + 1)
);

// 3. Gray pointer must match binary pointer encoding
//    At all times (outside reset), the write Gray pointer must equal
//    the Gray encoding of the write binary pointer.
assert property (@(posedge write_clk) disable iff (!write_rst_n)
  bin2gray(r_write_ptr_bin) == r_write_ptr_gray
);

// 4. Gray pointer changes by at most one bit per cycle
//    Between consecutive `write_clk` cycles, the write Gray pointer must
//    change by zero bits (no increment) or exactly one bit (one
//    increment). Any multi-bit Gray change indicates a bug.
assert property (@(posedge write_clk) disable iff (!write_rst_n)
  $countones($past(r_write_ptr_gray) ^ r_write_ptr_gray) <= 1
);

// 5. FULL flag must match the standard full condition
//    The registered/full output must equal the “full_next” condition
//    computed from the next write Gray pointer compared against the
//    synchronized read Gray pointer, using the classic two-MSB inversion
//    rule (Gray-domain full detection).
//    Explanation:
//    - FULL is predicted using w_write_ptr_gray_next (next write position).
//    - FULL is true only when:
//      1) w_write_ptr_gray_next[MSB] matches ~r_read_ptr_gray_sync2[MSB], and
//      2) w_write_ptr_gray_next[LSB] matches  r_read_ptr_gray_sync2[LSB].
//
//    Table example (3-bit Gray):
//    +----------------------+----------------------+----------------------+--------------------------+----------------------+-------------------+-----------------------+
//    | r_read_ptr_gray_sync2| w_write_ptr_gray_next| w_write_ptr_gray_next| ~r_read_ptr_gray_sync2   | w_write_ptr_gray_next| r_read_ptr_gray_  | p_write_full expected |
//    |                      |                      | [MSB]                | [MSB]                    | [LSB]                | sync2[LSB]        |                       |
//    +----------------------+----------------------+----------------------+--------------------------+----------------------+-------------------+-----------------------+
//    | 000                  | 110                  | 11                   | 11                       | 0                    | 0                 | 1                     |
//    | 000                  | 010                  | 01                   | 11                       | 0                    | 0                 | 0                     |
//    | 001                  | 111                  | 11                   | 11                       | 1                    | 1                 | 1                     |
//    | 001                  | 011                  | 01                   | 11                       | 1                    | 1                 | 0                     |
//    +----------------------+----------------------+----------------------+--------------------------+----------------------+-------------------+-----------------------+
assert property (@(posedge write_clk) disable iff (!write_rst_n)
  p_write_full == (
    (w_write_ptr_gray_next[SIZE_LOG2:SIZE_LOG2-1] == ~r_read_ptr_gray_sync2[SIZE_LOG2:SIZE_LOG2-1])
    &&
    (w_write_ptr_gray_next[SIZE_LOG2-2:0] == r_read_ptr_gray_sync2[SIZE_LOG2-2:0])
  )
);

// 6. No unknowns after reset
//    After reset is deasserted, `p_write_full` and the write pointers must
//    never be X/Z.
assert property (@(posedge write_clk)
  write_rst_n |-> !$isunknown(p_write_full) && !$isunknown(r_write_ptr_bin) && !$isunknown(r_write_ptr_gray)
);



// ## B) Read clock domain (`read_clk`)

// 7. No read pointer advance when EMPTY
//    If `p_read_empty` is asserted, then a read request must not advance
//    the read pointer. The read Gray pointer must also remain stable.
assert property (@(posedge read_clk) disable iff (!read_rst_n)
  (p_read_empty && p_read_en) |=> ($stable(r_read_ptr_bin) && $stable(r_read_ptr_gray))
);

// 8. Read pointer increments by exactly one on an accepted read
//    When `p_read_en` is high and `p_read_empty` is low (read accepted), the
//    read binary pointer must increase by exactly 1 on the next cycle.
assert property (@(posedge read_clk) disable iff (!read_rst_n)
  (!p_read_empty && p_read_en) |=> (r_read_ptr_bin == $past(r_read_ptr_bin) + 1)
);

// 9. Gray pointer must match binary pointer encoding
//    At all times (outside reset), the read Gray pointer must equal the
//    Gray encoding of the read binary pointer.
assert property (@(posedge read_clk) disable iff (!read_rst_n)
  bin2gray(r_read_ptr_bin) == r_read_ptr_gray
);

// 10. Gray pointer changes by at most one bit per cycle
//     Between consecutive `read_clk` cycles, the read Gray pointer must
//     change by zero bits (no increment) or exactly one bit (one
//     increment).
assert property (@(posedge read_clk) disable iff (!read_rst_n)
  $countones($past(r_read_ptr_gray) ^ r_read_ptr_gray) <= 1
);

// 11. EMPTY flag must match the standard empty condition
//     The registered/empty output must equal the “empty_next” condition
//     computed from the next read Gray pointer compared against the
//     synchronized write Gray pointer (Gray-domain empty detection).
assert property (@(posedge read_clk) disable iff (!read_rst_n)
  p_read_empty == (w_read_ptr_gray_next == r_write_ptr_gray_sync2)
);

// 12. No unknowns after reset
//     After reset is deasserted, `p_read_empty` and the read pointers must
//     never be X/Z.
assert property (@(posedge read_clk)
  read_rst_n |-> !$isunknown(p_read_empty) && !$isunknown(r_read_ptr_bin) && !$isunknown(r_read_ptr_gray)
);


// ## C) Optional “nice-to-have” assertions (strong portfolio bonus)

// 13. Synchronized remote Gray pointer changes by at most one bit per cycle
//     In each domain, the synchronized copy of the remote Gray pointer
//     should only change by zero or one bit per destination clock cycle.
//     (This is a sanity check; it helps catch wiring/logic errors.)


// 14. Flags only change on clock edges (no combinational glitching)
//     Ensure `p_write_full` only updates on `write_clk` edges and
//     `p_read_empty` only updates on `read_clk` edges (i.e., they are
//     registered outputs and
//     stable between edges).


// 15. If you expose a level/occupancy signal: bounds and monotonic behavior
//     If the FIFO reports “level”, assert it never exceeds DEPTH and
//     never underflows, and that it changes consistently with accepted
//     reads/writes.

endmodule
