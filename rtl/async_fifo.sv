module AsyncFifo
  #(
    parameter BITS=32, // Width of each FIFO entry.
    parameter SIZE=16       // Number of entries. **Recommended: power-of-two** for simpler pointer logic.
  )
  (
    // Write Domain
    input  logic wr_clk,             // Write clock
    input  logic wr_rst_n,           // Active-low write reset (async or sync — see notes)
    input  logic wr_en,              // Write request (one entry per cycle when accepted)
    input  logic [BITS-1:0] wr_data, // Data to write
    output logic wr_full,            // FIFO full flag (do not write when 1)
    // output logic wr_almost_full,          // (Optional) Programmable threshold
    // output logic wr_level,                // (Optional) Approximate fill level (write domain view)
    // Read Domain
    input  logic rd_clk,             // Read clock
    input  logic rd_rst_n,           // Active-low read reset
    input  logic rd_en,              // Read request (one entry per cycle when accepted)
    output logic [BITS-1:0] rd_data, // Data read
    output logic rd_empty            // FIFO empty flag (do not read when 1)
    // output logic rd_almost_empty,         // (Optional) Programmable threshold
    // output logic rd_level,                // (Optional) Approximate fill level (read domain view)
    );


localparam SIZE_LOG2 = $clog2(SIZE);

logic [SIZE-1:0][BITS-1:0] fifo;
logic [SIZE_LOG2:0] wr_ptr, rd_ptr;
logic logic_wr_full;
logic logic_rd_empty;

always_ff @(posedge wr_clk) begin
  if (!wr_rst_n) begin
    fifo <= '{default: '0};
    wr_ptr <= 0;
  end else if (wr_en && !wr_full) begin
    fifo[wr_ptr[SIZE_LOG2-1:0]] <= wr_data;
    wr_ptr <= wr_ptr + 1;
  end
end

always_ff @(posedge wr_clk) begin
  if (!rd_rst_n) begin
    // rd_fifo <= '{default: '0};
    rd_ptr <= 0;
  end else if (rd_en && !logic_rd_empty) begin
    rd_data <= fifo[rd_ptr[SIZE_LOG2-1:0]];
    rd_ptr <= rd_ptr + 1;
  end
end

assign logic_rd_empty = wr_ptr[SIZE_LOG2:0] == rd_ptr[SIZE_LOG2:0];
assign rd_empty = logic_rd_empty;

assign logic_wr_full = (wr_ptr[SIZE_LOG2] != rd_ptr[SIZE_LOG2]) && (wr_ptr[SIZE_LOG2-1:0] == rd_ptr[SIZE_LOG2-1:0]);
assign wr_full = logic_wr_full;

endmodule
