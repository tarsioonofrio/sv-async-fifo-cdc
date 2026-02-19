module async_fifo
  #(
    parameter BITS=32, // Width of each FIFO entry.
    parameter SIZE=16  // Number of entries. **Recommended: power-of-two** for simpler pointer logic.
  )
  (
    // Write Domain
    input  logic write_clk,               // Write clock
    input  logic write_rst_n,             // Active-low write reset (async or sync — see notes)
    input  logic p_write_en,              // Write request (one entry per cycle when accepted)
    input  logic [BITS-1:0] p_write_data, // Data to write
    output logic p_write_full,            // FIFO full flag (do not write when 1)
    // output logic p_write_almost_full,          // (Optional) Programmable threshold
    // output logic p_write_level,                // (Optional) Approximate fill level (write domain view)
    // Read Domain
    input  logic read_clk,               // Read clock
    input  logic read_rst_n,             // Active-low read reset
    input  logic p_read_en,              // Read request (one entry per cycle when accepted)
    output logic [BITS-1:0] p_read_data, // Data read
    output logic p_read_empty            // FIFO empty flag (do not read when 1)
    // output logic p_read_almost_empty,         // (Optional) Programmable threshold
    // output logic p_read_level,                // (Optional) Approximate fill level (read domain view)
    );


localparam SIZE_LOG2 = $clog2(SIZE);

logic [SIZE-1:0][BITS-1:0] r_fifo;

logic [SIZE_LOG2:0] r_write_ptr_bin;
logic [SIZE_LOG2:0] w_write_ptr_bin_next;
logic [SIZE_LOG2:0] r_write_ptr_gray;
logic [SIZE_LOG2:0] w_write_ptr_gray_next;
logic [SIZE_LOG2:0] w_write_ptr_bin_sync;
logic [SIZE_LOG2:0] r_write_ptr_gray_sync1;
logic [SIZE_LOG2:0] r_write_ptr_gray_sync2;

logic [SIZE_LOG2:0] r_read_ptr_bin;
logic [SIZE_LOG2:0] w_read_ptr_bin_next;
logic [SIZE_LOG2:0] r_read_ptr_gray;
logic [SIZE_LOG2:0] w_read_ptr_gray_next;
logic [SIZE_LOG2:0] w_read_ptr_bin_sync;
logic [SIZE_LOG2:0] r_read_ptr_gray_sync1;
logic [SIZE_LOG2:0] r_read_ptr_gray_sync2;

logic w_write_full;
logic w_read_empty;


always_ff @(posedge write_clk) begin
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

assign w_write_ptr_bin_next = r_write_ptr_bin + (SIZE_LOG2+1)'(p_write_en && !w_write_full);
assign w_write_ptr_gray_next = (w_write_ptr_bin_next >> 1) ^ w_write_ptr_bin_next;

always_ff @(posedge read_clk) begin
  if (!read_rst_n) begin
    r_read_ptr_bin <= 0;
    r_read_ptr_gray <= 0;
  end else begin
    if (p_read_en && !w_read_empty) begin
      p_read_data <= r_fifo[r_read_ptr_bin[SIZE_LOG2-1:0]];
    end
    r_read_ptr_bin <= w_read_ptr_bin_next;
    r_read_ptr_gray <= w_read_ptr_gray_next;
  end
end

assign w_read_ptr_bin_next = r_read_ptr_bin + (SIZE_LOG2+1)'(p_read_en && !w_read_empty);
assign w_read_ptr_gray_next = (w_read_ptr_bin_next >> 1) ^ w_read_ptr_bin_next;


always_ff @(posedge write_clk) begin
  if (!write_rst_n) begin
    r_read_ptr_gray_sync1 <= 0;
    r_read_ptr_gray_sync2 <= 0;
  end else begin
    r_read_ptr_gray_sync1 <= r_read_ptr_gray;
    r_read_ptr_gray_sync2 <= r_read_ptr_gray_sync1;
  end
end

always_ff @(posedge read_clk) begin
  if (!read_rst_n) begin
    r_write_ptr_gray_sync1 <= 0;
    r_write_ptr_gray_sync2 <= 0;
  end else begin
    r_write_ptr_gray_sync1 <= r_write_ptr_gray;
    r_write_ptr_gray_sync2 <= r_write_ptr_gray_sync1;
  end
end

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

endmodule
