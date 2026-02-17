module tb;
  timeunit 1ns;
  timeprecision 1ps;

  localparam DATA_WIDTH=32; // Width of each FIFO entry.
  localparam DEPTH=16;      // Number of entries. **Recommended: power-of-two** for simpler pointer logic.

  // Write Domain (wr_clk)
  logic wr_clk;                  // Write clock
  logic wr_rst_n;                // Active-low write reset (async or sync — see notes)
  logic wr_en;                   // Write request (one entry per cycle when accepted)
  logic [DATA_WIDTH-1:0] wr_data; // Data to write
  logic wr_full;                 // FIFO full flag (do not write when 1)
  // logic wr_almost_full;          // (Optional) Programmable threshold
  // logic wr_level;                // (Optional) Approximate fill level (write domain view)

  // Read Domain
  logic rd_clk;                  // Read clock
  logic rd_rst_n;                // Active-low read reset
  logic rd_en;                   // Read request (one entry per cycle when accepted)
  logic [DATA_WIDTH-1:0] rd_data; // Data read
  logic rd_empty;                // FIFO empty flag (do not read when 1)
  // logic rd_almost_empty;         // (Optional) Programmable threshold
  // logic rd_level;                // (Optional) Approximate fill level (read domain view)

  logic clk, rstn;


  AsyncFifo
    #(
      .DATA_WIDTH(DATA_WIDTH),
      .DEPTH(DEPTH)
    ) dut (
      .wr_clk(clk),
      .wr_rst_n(rstn),
      .wr_en(wr_en),
      .wr_data(wr_data),
      .wr_full(wr_full),
      .rd_clk(clk),
      .rd_rst_n(rstn),
      .rd_en(rd_en),
      .rd_data(rd_data),
      .rd_empty(rd_empty)
    );


  initial clk = 0;
  always #0.5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    rstn = 0;
    @(posedge clk);
    rstn = 1;
    rd_en <= 0;
    wr_en <= 0;
    @(posedge clk);

    // Start processamento
    $display("=== Start processing ===");

    wr_en <= 1;

    for (int i = 0; i < DATA_WIDTH; i++) begin
      @(posedge clk);
      wr_data <= i;
    end

    wr_en <= 0;
    rd_en <= 1;

    for (int i = 0; i < DATA_WIDTH; i++) begin
      @(posedge clk);
      $display("Time %0t | Index = %0d | Output = %0d", $time, i, rd_data);
    end
    wr_en <= 1;

    $display("\n*** TIME %0f ***\n", $realtime);
    $display("=== No errors - End simulation ===");
    $finish;
  end


endmodule
