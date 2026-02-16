module sync_fifo
  #(
    parameter DATA_WIDTH=32, // Width of each FIFO entry.
    parameter DEPTH=16,      // Number of entries. **Recommended: power-of-two** for simpler pointer logic.
  )
  (
    // Write Domain (wr_clk)
    input  wr_clk,                  // Write clock
    input  wr_rst_n,                // Active-low write reset (async or sync — see notes)
    input  wr_en,                   // Write request (one entry per cycle when accepted)
    input  wr_data[DATA_WIDTH-1:0], // Data to write
    output wr_full,                 // FIFO full flag (do not write when 1)
    output wr_almost_full,          // (Optional) Programmable threshold
    output wr_level,                // (Optional) Approximate fill level (write domain view)
    input  rd_clk,                  // Read clock
    input  rd_rst_n,                // Active-low read reset
    input  rd_en,                   // Read request (one entry per cycle when accepted)
    output rd_data[DATA_WIDTH-1:0], // Data read
    output rd_empty,                // FIFO empty flag (do not read when 1)
    output rd_almost_empty,         // (Optional) Programmable threshold
    output rd_level,                // (Optional) Approximate fill level (read domain view)
    );

logic [DATA_WIDTH-1:0] fifo[$clog2(DEPTH+1):0];

always_ff (posedge wr_clk) begin
  if (!wr_rst_n) begin
    fifo <= '{default: '0};
  end

end

endmodule
