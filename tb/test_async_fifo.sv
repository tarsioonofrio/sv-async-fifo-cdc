`include "task.svh"

module tb;
  timeunit 1ns;
  timeprecision 1ps;

  localparam BITS=32; // Width of each FIFO entry.
  localparam SIZE=16; // Number of entries. **Recommended: power-of-two** for simpler pointer logic.

  // Write Domain (write_clk)
  logic write_clk;               // Write clock
  logic write_rst_n;             // Active-low write reset (async or sync — see notes)
  logic p_write_en;              // Write request (one entry per cycle when accepted)
  logic [BITS-1:0] p_write_data; // Data to write
  logic p_write_full;            // FIFO full flag (do not write when 1)
  // logic p_write_almost_full;          // (Optional) Programmable threshold
  // logic p_write_level;                // (Optional) Approximate fill level (write domain view)

  // Read Domain
  logic read_clk;               // Read clock
  logic read_rst_n;             // Active-low read reset
  logic p_read_en;              // Read request (one entry per cycle when accepted)
  logic [BITS-1:0] p_read_data; // Data read
  logic p_read_empty;           // FIFO empty flag (do not read when 1)
  // logic p_read_almost_empty;         // (Optional) Programmable threshold
  // logic p_read_level;                // (Optional) Approximate fill level (read domain view)

  logic clk, rstn;


  async_fifo
    #(
      .BITS(BITS),
      .SIZE(SIZE)
    ) dut (
      .write_clk(write_clk),
      .write_rst_n(write_rst_n),
      .p_write_en(p_write_en),
      .p_write_data(p_write_data),
      .p_write_full(p_write_full),
      .read_clk(read_clk),
      .read_rst_n(read_rst_n),
      .p_read_en(p_read_en),
      .p_read_data(p_read_data),
      .p_read_empty(p_read_empty)
    );


  initial clk = 0;
  always #0.5 clk = ~clk;

  initial write_clk = 0;
  always #0.314159265359 write_clk = ~write_clk;
  initial read_clk = 0;
  always #0.2718281828 read_clk = ~read_clk;


  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    test_reset_empty_full_start(
      write_rst_n,
      read_rst_n,
      p_read_en,
      p_write_en,
      p_write_full,
      p_read_empty,
      write_clk,
      read_clk
    );
    // Start processamento
    $display("=== Start processing ===");


    for (int i = 0; i < SIZE*2-1; i++) begin
      @(posedge write_clk);
      p_write_en <= 1;
      p_write_data <= i;
    end
    p_write_en <= 0;

    for (int i = 0; i < SIZE*2-1; i++) begin
      @(posedge read_clk);
      p_read_en <= 1;
      $display("Time %0t | Index = %0d | Output = %0d", $time, i, p_read_data);
    end
    p_read_en <= 0;

    $display("\n*** TIME %0f ***\n", $realtime);
    $display("=== No errors - End simulation ===");
    $finish;
  end


endmodule
