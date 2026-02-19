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

endmodule
