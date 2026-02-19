module async_fifo
  #(
    parameter BITS=32, // Width of each FIFO entry.
    parameter SIZE=16  // Number of entries. **Recommended: power-of-two** for simpler pointer logic.
  )
  (
    // Write Domain
    input  logic wr_clk,               // Write clock
    input  logic wr_rst_n,             // Active-low write reset (async or sync — see notes)
    input  logic p_wr_en,              // Write request (one entry per cycle when accepted)
    input  logic [BITS-1:0] p_wr_data, // Data to write
    output logic p_wr_full,            // FIFO full flag (do not write when 1)
    // output logic p_wr_almost_full,          // (Optional) Programmable threshold
    // output logic p_wr_level,                // (Optional) Approximate fill level (write domain view)
    // Read Domain
    input  logic rd_clk,               // Read clock
    input  logic rd_rst_n,             // Active-low read reset
    input  logic p_rd_en,              // Read request (one entry per cycle when accepted)
    output logic [BITS-1:0] p_rd_data, // Data read
    output logic p_rd_empty            // FIFO empty flag (do not read when 1)
    // output logic p_rd_almost_empty,         // (Optional) Programmable threshold
    // output logic p_rd_level,                // (Optional) Approximate fill level (read domain view)
    );


localparam SIZE_LOG2 = $clog2(SIZE);

logic [SIZE-1:0][BITS-1:0] r_fifo;

logic [SIZE_LOG2:0] r_wr_ptr_bin;
logic [SIZE_LOG2:0] w_wr_ptr_bin_next;
logic [SIZE_LOG2:0] r_wr_ptr_gray;
logic [SIZE_LOG2:0] w_wr_ptr_bin_sync;
logic [SIZE_LOG2:0] r_wr_ptr_gray_sync1;
logic [SIZE_LOG2:0] r_wr_ptr_gray_sync2;

logic [SIZE_LOG2:0] r_rd_ptr_bin;
logic [SIZE_LOG2:0] w_rd_ptr_bin_next;
logic [SIZE_LOG2:0] r_rd_ptr_gray;
logic [SIZE_LOG2:0] w_rd_ptr_bin_sync;
logic [SIZE_LOG2:0] r_rd_ptr_gray_sync1;
logic [SIZE_LOG2:0] r_rd_ptr_gray_sync2;

logic w_wr_full;
logic w_rd_empty;


always_ff @(posedge wr_clk) begin
  if (!wr_rst_n) begin
    r_wr_ptr_bin <= 0;
    r_wr_ptr_gray <= 0;
  end else if (p_wr_en && !w_wr_full) begin
    r_fifo[r_wr_ptr_bin[SIZE_LOG2-1:0]] <= p_wr_data;
    r_wr_ptr_bin <= r_wr_ptr_bin + 1;
  end
  r_wr_ptr_gray <= (w_wr_ptr_bin_next >> 1) ^ w_wr_ptr_bin_next;
end
assign w_wr_ptr_bin_next = r_wr_ptr_bin + (SIZE_LOG2+1)'(p_wr_en && !w_wr_full);

always_ff @(posedge rd_clk) begin
  if (!rd_rst_n) begin
    r_rd_ptr_bin <= 0;
    r_rd_ptr_gray <= 0;
  end else if (p_rd_en && !w_rd_empty) begin
    p_rd_data <= r_fifo[r_rd_ptr_bin[SIZE_LOG2-1:0]];
    r_rd_ptr_bin <= r_rd_ptr_bin + 1;
  end
  r_rd_ptr_gray <= (w_rd_ptr_bin_next >> 1) ^ w_rd_ptr_bin_next;
end
assign w_rd_ptr_bin_next = r_rd_ptr_bin + (SIZE_LOG2+1)'(p_rd_en && !w_rd_empty);


always_ff @(posedge wr_clk) begin
  if (!wr_rst_n) begin
    r_rd_ptr_gray_sync1 <= 0;
    r_rd_ptr_gray_sync2 <= 0;
  end else begin
    r_rd_ptr_gray_sync1 <= r_rd_ptr_gray;
    r_rd_ptr_gray_sync2 <= r_rd_ptr_gray_sync1;
  end
end

always_ff @(posedge rd_clk) begin
  if (!rd_rst_n) begin
    r_wr_ptr_gray_sync1 <= 0;
    r_wr_ptr_gray_sync2 <= 0;
  end else begin
    r_wr_ptr_gray_sync1 <= r_wr_ptr_gray;
    r_wr_ptr_gray_sync2 <= r_wr_ptr_gray_sync1;
  end
end

generate
  for (genvar i = 0; i < SIZE_LOG2+1; i++) begin: gen_wr_ptr_bin_sync
    assign w_wr_ptr_bin_sync[i] = ^(r_wr_ptr_gray_sync2 >> i);
  end

  for (genvar i = 0; i < SIZE_LOG2+1; i++) begin: gen_rd_ptr_bin_sync
    assign w_rd_ptr_bin_sync[i] = ^(r_rd_ptr_gray_sync2 >> i);
  end
endgenerate

assign w_rd_empty = w_wr_ptr_bin_sync[SIZE_LOG2:0] == r_rd_ptr_bin[SIZE_LOG2:0];
assign p_rd_empty = w_rd_empty;

assign w_wr_full = (r_wr_ptr_bin[SIZE_LOG2] != w_rd_ptr_bin_sync[SIZE_LOG2]) && (r_wr_ptr_bin[SIZE_LOG2-1:0] == w_rd_ptr_bin_sync[SIZE_LOG2-1:0]);
assign p_wr_full = w_wr_full;

endmodule
