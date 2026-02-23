module async_fifo
  #(
    parameter BITS=32, // Width of each FIFO entry.
    parameter SIZE=16  // Number of entries. **Recommended: power-of-two** for simpler pointer logic.
  )
  (
    // Write Domain
    input  logic write_clk,               // Write clock
    input  logic write_rst_n,             // Active-low asynchronous write reset
    input  logic p_write_en,              // Write request (one entry per cycle when accepted)
    input  logic [BITS-1:0] p_write_data, // Data to write
    output logic p_write_full,            // FIFO full flag (do not write when 1)
    // output logic p_write_almost_full,          // (Optional) Programmable threshold
    // output logic p_write_level,                // (Optional) Approximate fill level (write domain view)
    // Read Domain
    input  logic read_clk,               // Read clock
    input  logic read_rst_n,             // Active-low asynchronous read reset
    input  logic p_read_en,              // Read request (one entry per cycle when accepted)
    output logic [BITS-1:0] p_read_data, // Data read
    output logic p_read_empty            // FIFO empty flag (do not read when 1)
    // output logic p_read_almost_empty,         // (Optional) Programmable threshold
    // output logic p_read_level,                // (Optional) Approximate fill level (read domain view)
  );

  timeunit 1ns;
  timeprecision 1ps;

  localparam bit SIZE_IS_POW2 = (SIZE > 1) && ((SIZE & (SIZE - 1)) == 0);

  generate
    if (!SIZE_IS_POW2) begin : gen_bad_size
      initial $fatal(1, "SIZE (%0d) must be a power of two and > 1", SIZE);
    end
  endgenerate

  localparam SIZE_LOG2 = $clog2(SIZE);

  logic [SIZE-1:0][BITS-1:0] r_fifo;

  logic [SIZE_LOG2:0] r_write_ptr_bin;
  logic [SIZE_LOG2:0] w_write_ptr_bin_next;
  logic [SIZE_LOG2:0] r_write_ptr_gray;
  logic [SIZE_LOG2:0] w_write_ptr_gray_next;
  logic [SIZE_LOG2:0] w_write_ptr_bin_sync;
  logic [SIZE_LOG2:0] r_write_ptr_gray_sync2;

  logic [SIZE_LOG2:0] r_read_ptr_bin;
  logic [SIZE_LOG2:0] w_read_ptr_bin_next;
  logic [SIZE_LOG2:0] r_read_ptr_gray;
  logic [SIZE_LOG2:0] w_read_ptr_gray_next;
  logic [SIZE_LOG2:0] w_read_ptr_bin_sync;
  logic [SIZE_LOG2:0] r_read_ptr_gray_sync2;

  logic w_write_full;
  logic w_read_empty;


  always_ff @(posedge write_clk or negedge write_rst_n) begin
    if (!write_rst_n) begin
      r_write_ptr_bin <= 0;
      r_write_ptr_gray <= 0;
    end else begin
      if (p_write_en && !w_write_full) begin
        r_fifo[r_write_ptr_bin[SIZE_LOG2-1:0]] <= p_write_data;
      end
      r_write_ptr_bin <= w_write_ptr_bin_next;
      r_write_ptr_gray <= w_write_ptr_gray_next;
    end
  end

  assign w_write_ptr_bin_next = (p_write_en && !w_write_full) ? r_write_ptr_bin + 1: r_write_ptr_bin;
  assign w_write_ptr_gray_next = (w_write_ptr_bin_next >> 1) ^ w_write_ptr_bin_next;

  always_ff @(posedge read_clk or negedge read_rst_n) begin
    if (!read_rst_n) begin
      r_read_ptr_bin <= 0;
      r_read_ptr_gray <= 0;
      p_read_data <= 0;
    end else begin
      if (p_read_en && !w_read_empty) begin
        p_read_data <= r_fifo[r_read_ptr_bin[SIZE_LOG2-1:0]];
      end
      r_read_ptr_bin <= w_read_ptr_bin_next;
      r_read_ptr_gray <= w_read_ptr_gray_next;
    end
  end

  assign w_read_ptr_bin_next = (p_read_en && !w_read_empty) ? r_read_ptr_bin + 1: r_read_ptr_bin;
  assign w_read_ptr_gray_next = (w_read_ptr_bin_next >> 1) ^ w_read_ptr_bin_next;


  sync_2ff #(.WIDTH(SIZE_LOG2+1)) sync_read_to_write (
    .clk(write_clk),
    .rst_n(write_rst_n),
    .p_d(r_read_ptr_gray),
    .p_q(r_read_ptr_gray_sync2)
  );

  sync_2ff #(.WIDTH(SIZE_LOG2+1)) sync_write_to_read (
    .clk(read_clk),
    .rst_n(read_rst_n),
    .p_d(r_write_ptr_gray),
    .p_q(r_write_ptr_gray_sync2)
  );

  generate
    for (genvar i = 0; i < SIZE_LOG2+1; i++) begin: gen_write_ptr_bin_sync
      assign w_write_ptr_bin_sync[i] = ^(r_write_ptr_gray_sync2 >> i);
    end

    for (genvar i = 0; i < SIZE_LOG2+1; i++) begin: gen_read_ptr_bin_sync
      assign w_read_ptr_bin_sync[i] = ^(r_read_ptr_gray_sync2 >> i);
    end
  endgenerate

  assign w_read_empty = w_write_ptr_bin_sync[SIZE_LOG2:0] == r_read_ptr_bin[SIZE_LOG2:0];
  assign p_read_empty = w_read_empty;

  assign w_write_full = (r_write_ptr_bin[SIZE_LOG2] != w_read_ptr_bin_sync[SIZE_LOG2]) && (r_write_ptr_bin[SIZE_LOG2-1:0] == w_read_ptr_bin_sync[SIZE_LOG2-1:0]);
  assign p_write_full = w_write_full;

`ifndef SYNTHESIS
  async_fifo_sva #(
    .SIZE_LOG2(SIZE_LOG2)
  ) u_async_fifo_sva (
    .write_clk(write_clk),
    .write_rst_n(write_rst_n),
    .read_clk(read_clk),
    .read_rst_n(read_rst_n),
    .p_write_en(p_write_en),
    .p_write_full(p_write_full),
    .p_read_en(p_read_en),
    .p_read_empty(p_read_empty),
    .r_write_ptr_bin(r_write_ptr_bin),
    .r_write_ptr_gray(r_write_ptr_gray),
    .r_read_ptr_bin(r_read_ptr_bin),
    .r_read_ptr_gray(r_read_ptr_gray),
    .w_write_ptr_gray_next(w_write_ptr_gray_next),
    .w_read_ptr_gray_next(w_read_ptr_gray_next),
    .r_read_ptr_gray_sync2(r_read_ptr_gray_sync2),
    .r_write_ptr_gray_sync2(r_write_ptr_gray_sync2)
  );
`endif

endmodule
