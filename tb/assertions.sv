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


// ===== WR domain asserts =====
// 1) no ptr advance when full
assert property (@(posedge write_clk) disable iff (!write_rst_n)
  (p_write_full && p_write_en) |-> ($stable(r_write_ptr_bin) && $stable(r_write_ptr_gray))
);

// 2) Write pointer increments by exactly one on an accepted write
assert property (@(posedge write_clk) disable iff (!write_rst_n)
  (p_write_full && p_write_en) |-> (r_write_ptr_bin == ($past(r_write_ptr_bin + 1)))
);

// 3) Gray pointer must match binary pointer encoding
assert property (@(posedge write_clk) disable iff (!write_rst_n)
  (p_write_full && p_write_en) |-> (bin2gray(r_write_ptr_bin) == r_write_ptr_gray)
);

// 4) Gray pointer changes by at most one bit per cycle
assert property (@(posedge write_clk) disable iff (!write_rst_n)
  (p_write_full && p_write_en) |-> ($onehot($past(r_write_ptr_gray) ^ r_write_ptr_gray))
);

endmodule
