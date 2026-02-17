module AsyncFifo
  #(
    parameter DATA_WIDTH=32, // Width of each FIFO entry.
    parameter DEPTH=16       // Number of entries. **Recommended: power-of-two** for simpler pointer logic.
  )
  (
    // Write Domain
    input  logic wr_clk,                   // Write clock
    input  logic wr_rst_n,                 // Active-low write reset (async or sync — see notes)
    input  logic wr_en,                    // Write request (one entry per cycle when accepted)
    input  logic [DATA_WIDTH-1:0] wr_data, // Data to write
    output logic wr_full,                  // FIFO full flag (do not write when 1)
    // output logic wr_almost_full,          // (Optional) Programmable threshold
    // output logic wr_level,                // (Optional) Approximate fill level (write domain view)
    // Read Domain
    input  logic rd_clk,                   // Read clock
    input  logic rd_rst_n,                 // Active-low read reset
    input  logic rd_en,                    // Read request (one entry per cycle when accepted)
    output logic [DATA_WIDTH-1:0] rd_data, // Data read
    output logic rd_empty                  // FIFO empty flag (do not read when 1)
    // output logic rd_almost_empty,         // (Optional) Programmable threshold
    // output logic rd_level,                // (Optional) Approximate fill level (read domain view)
    );

logic [DATA_WIDTH-1:0][$clog2(DEPTH+1):0] wr_fifo;
logic [$clog2(DEPTH+1):0] wr_ptr, rd_ptr;
logic logic_wr_full;
logic logic_rd_empty;

always_ff @(posedge wr_clk) begin
  if (!wr_rst_n) begin
    wr_fifo <= '{default: '0};
  end else if (wr_en && !wr_full) begin
    wr_fifo[wr_ptr] <= wr_data;
    wr_ptr <= wr_ptr + 1;
  end
end

always_ff @(posedge wr_clk) begin
  if (!rd_rst_n) begin
    // rd_fifo <= '{default: '0};
  end else if (rd_en && !logic_wr_full) begin
    rd_data <= wr_fifo[rd_ptr];
    rd_ptr <= rd_ptr + 1;
  end
end

always_comb begin
  logic_rd_empty = rd_ptr && wr_ptr;
  rd_empty = logic_rd_empty;

  logic_wr_full = rd_ptr == DEPTH;
  wr_full = logic_wr_full;
end

endmodule
