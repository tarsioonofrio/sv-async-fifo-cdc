
module tb;
  timeunit 1ns;
  timeprecision 1ps;

  localparam BITS=32; // Width of each FIFO entry.
  localparam SIZE=16; // Number of entries. **Recommended: power-of-two** for simpler pointer logic.

  localparam WRITE_HALF_PERIOD_NS = 0.314159265359;
  localparam READ_HALF_PERIOD_NS = 0.2718281828;

  `include "task.svh"

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

  realtime write_half_period_ns, read_half_period_ns;

  int unsigned error_count = 0;
  // plusargs
  string testname;
  int seed;

  task automatic task_reset();
    test_reset_empty_full_start(
      error_count,
      write_rst_n,
      read_rst_n,
      p_write_en,
      p_read_en,
      p_write_full,
      p_read_empty,
      write_clk,
      read_clk
    );
  endtask


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
  always #write_half_period_ns write_clk = ~write_clk;
  initial read_clk = 0;
  always #read_half_period_ns read_clk = ~read_clk;


  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    // defaults
    testname = "";
    seed     = 7;

    void'($value$plusargs("TEST=%s", testname));
    void'($value$plusargs("SEED=%d", seed));

    write_half_period_ns = WRITE_HALF_PERIOD_NS;
    read_half_period_ns = READ_HALF_PERIOD_NS;

    $display("=== Testbench starting: TEST=%s SEED=%0d ===", testname, seed);

    if (testname == "") begin
      task_reset();
      test_smoke_writen_readn(
        error_count,
        p_write_en,
        p_read_en,
        p_write_data,
        p_read_data,
        write_clk,
        read_clk
      );
      task_reset();
      test_interleaved(
        error_count,
        p_write_en,
        p_read_en,
        p_write_full,
        p_read_empty,
        p_write_data,
        p_read_data,
        write_clk,
        read_clk
      );
      task_reset();
      test_write_clock_faster(
        error_count,
        write_half_period_ns,
        read_half_period_ns,
        p_write_en,
        p_read_en,
        p_write_full,
        p_read_empty,
        p_write_data,
        p_read_data,
        write_clk,
        read_clk
      );
      task_reset();
      test_read_clock_faster(
        error_count,
        write_half_period_ns,
        read_half_period_ns,
        p_write_en,
        p_read_en,
        p_write_full,
        p_read_empty,
        p_write_data,
        p_read_data,
        write_clk,
        read_clk
      );
    end else if (testname == "reset") begin
      task_reset();
    end else if (testname == "smoke") begin
      task_reset();
      test_smoke_writen_readn(
        error_count,
        p_write_en,
        p_read_en,
        p_write_data,
        p_read_data,
        write_clk,
        read_clk
      );
    end else if (testname == "interleaved") begin
      task_reset();
      test_interleaved(
        error_count,
        p_write_en,
        p_read_en,
        p_write_full,
        p_read_empty,
        p_write_data,
        p_read_data,
        write_clk,
        read_clk
      );
    end else if (testname == "write-clock-faster") begin
      task_reset();
      test_write_clock_faster(
        error_count,
        write_half_period_ns,
        read_half_period_ns,
        p_write_en,
        p_read_en,
        p_write_full,
        p_read_empty,
        p_write_data,
        p_read_data,
        write_clk,
        read_clk
      );
    end else if (testname == "read-clock-faster") begin
      task_reset();
      test_read_clock_faster(
        error_count,
        write_half_period_ns,
        read_half_period_ns,
        p_write_en,
        p_read_en,
        p_write_full,
        p_read_empty,
        p_write_data,
        p_read_data,
        write_clk,
        read_clk
      );
    end else begin
      $fatal(1, "Unknown TEST=%s. Valid: reset|smoke|interleaved|write-clock-faster|read-clock-faster", testname);
    end

    $display("\n*** TIME %0f ***\n", $realtime);

    if (error_count != 0) begin
      $fatal(1, "TEST FAILED: %0d error(s)", error_count);
    end else begin
      $display("TEST PASSED");
      $finish;
    end
  end


endmodule
