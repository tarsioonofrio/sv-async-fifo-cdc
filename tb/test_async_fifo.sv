module tb;
  timeunit 1ns;
  timeprecision 1ps;

  localparam BITS=32; // Width of each FIFO entry.
  localparam SIZE=16; // Number of entries. **Recommended: power-of-two** for simpler pointer logic.

  // Write Domain (wr_clk)
  logic wr_clk;             // Write clock
  logic wr_rst_n;           // Active-low write reset (async or sync — see notes)
  logic wr_en;              // Write request (one entry per cycle when accepted)
  logic [BITS-1:0] wr_data; // Data to write
  logic wr_full;            // FIFO full flag (do not write when 1)
  // logic wr_almost_full;          // (Optional) Programmable threshold
  // logic wr_level;                // (Optional) Approximate fill level (write domain view)

  // Read Domain
  logic rd_clk;             // Read clock
  logic rd_rst_n;           // Active-low read reset
  logic rd_en;              // Read request (one entry per cycle when accepted)
  logic [BITS-1:0] rd_data; // Data read
  logic rd_empty;           // FIFO empty flag (do not read when 1)
  // logic rd_almost_empty;         // (Optional) Programmable threshold
  // logic rd_level;                // (Optional) Approximate fill level (read domain view)

  logic clk, rstn;


  async_fifo
    #(
      .BITS(BITS),
      .SIZE(SIZE)
    ) dut (
      .wr_clk(wr_clk),
      .wr_rst_n(wr_rst_n),
      .wr_en(wr_en),
      .wr_data(wr_data),
      .wr_full(wr_full),
      .rd_clk(rd_clk),
      .rd_rst_n(rd_rst_n),
      .rd_en(rd_en),
      .rd_data(rd_data),
      .rd_empty(rd_empty)
    );


  initial clk = 0;
  always #0.5 clk = ~clk;

  initial wr_clk = 0;
  always #0.314159265359 wr_clk = ~wr_clk;
  initial rd_clk = 0;
  always #0.2718281828 rd_clk = ~rd_clk;


  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    wr_rst_n = 0;
    rd_rst_n = 0;
    @(posedge clk);
    wr_rst_n = 1;
    rd_rst_n = 1;
    rd_en <= 0;
    wr_en <= 0;
    @(posedge clk);

    // Start processamento
    $display("=== Start processing ===");


    for (int i = 0; i < SIZE*2-1; i++) begin
      @(posedge wr_clk);
      wr_en <= 1;
      wr_data <= i;
    end
    wr_en <= 0;

    for (int i = 0; i < SIZE*2-1; i++) begin
      @(posedge rd_clk);
      rd_en <= 1;
      $display("Time %0t | Index = %0d | Output = %0d", $time, i, rd_data);
    end
    rd_en <= 0;

    $display("\n*** TIME %0f ***\n", $realtime);
    $display("=== No errors - End simulation ===");
    $finish;
  end


endmodule
