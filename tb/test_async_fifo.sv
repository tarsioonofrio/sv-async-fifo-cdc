
module tb
  #(
    parameter int BITS = 32, // Width of each FIFO entry.
    parameter int SIZE = 16, // Number of entries. **Recommended: power-of-two** for simpler pointer logic.
    parameter string NAME = "",
    parameter int SEED = 7,
    parameter int TIMEOUT_NS = 200000
  );
  timeunit 1ns;
  timeprecision 1ps;

  localparam WRITE_HALF_PERIOD_NS = 0.314159265359;
  localparam READ_HALF_PERIOD_NS = 0.2718281828;

  typedef struct {
    int unsigned error_count;
  } tb_counters_t;

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

  tb_counters_t counters[string];
  tb_counters_t c_reset;
  tb_counters_t c_smoke;
  tb_counters_t c_interleaved;
  tb_counters_t c_write_clock_faster;
  tb_counters_t c_read_clock_faster;

  task automatic task_reset();
    c_reset = '{default: 0};
    test_reset_empty_full_start(
      c_reset,
      write_rst_n,
      read_rst_n,
      p_write_en,
      p_read_en,
      p_write_full,
      p_read_empty,
      write_clk,
      read_clk
    );
    counters["test_reset_empty_full_start"] = c_reset;
  endtask


`ifdef GATE_LEVEL
  async_fifo dut (
`else
  async_fifo
    #(
      .BITS(BITS),
      .SIZE(SIZE)
    ) dut (
`endif
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
    #(TIMEOUT_NS * 1ns);
    $fatal(1, "TB timeout after %0d ns (NAME=%s)", TIMEOUT_NS, NAME);
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    write_half_period_ns = WRITE_HALF_PERIOD_NS;
    read_half_period_ns = READ_HALF_PERIOD_NS;

    $display("=== Testbench starting: TEST=%s SEED=%0d ===", NAME, SEED);

    if (NAME == "") begin
      task_reset();
      c_smoke = '{default: 0};
      test_smoke_writen_readn(
        c_smoke,
        p_write_en,
        p_read_en,
        p_write_data,
        p_read_data,
        write_clk,
        read_clk
      );
      counters["test_smoke_writen_readn"] = c_smoke;
      task_reset();
      c_interleaved = '{default: 0};
      test_interleaved(
        c_interleaved,
        p_write_en,
        p_read_en,
        p_write_full,
        p_read_empty,
        p_write_data,
        p_read_data,
        write_clk,
        read_clk
      );
      counters["test_interleaved"] = c_interleaved;
      task_reset();
      c_write_clock_faster = '{default: 0};
      test_write_clock_faster(
        c_write_clock_faster,
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
      counters["test_write_clock_faster"] = c_write_clock_faster;
      task_reset();
      c_read_clock_faster = '{default: 0};
      test_read_clock_faster(
        c_read_clock_faster,
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
      counters["test_read_clock_faster"] = c_read_clock_faster;
    end else if (NAME == "reset") begin
      task_reset();
    end else if (NAME == "smoke") begin
      task_reset();
      c_smoke = '{default: 0};
      test_smoke_writen_readn(
        c_smoke,
        p_write_en,
        p_read_en,
        p_write_data,
        p_read_data,
        write_clk,
        read_clk
      );
      counters["test_smoke_writen_readn"] = c_smoke;
    end else if (NAME == "interleaved") begin
      task_reset();
      c_interleaved = '{default: 0};
      test_interleaved(
        c_interleaved,
        p_write_en,
        p_read_en,
        p_write_full,
        p_read_empty,
        p_write_data,
        p_read_data,
        write_clk,
        read_clk
      );
      counters["test_interleaved"] = c_interleaved;
    end else if (NAME == "write-clock-faster") begin
      task_reset();
      c_write_clock_faster = '{default: 0};
      test_write_clock_faster(
        c_write_clock_faster,
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
      counters["test_write_clock_faster"] = c_write_clock_faster;
    end else if (NAME == "read-clock-faster") begin
      task_reset();
      c_read_clock_faster = '{default: 0};
      test_read_clock_faster(
        c_read_clock_faster,
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
      counters["test_read_clock_faster"] = c_read_clock_faster;
    end else begin
      $fatal(1, "Unknown TEST=%s. Valid: reset|smoke|interleaved|write-clock-faster|read-clock-faster", NAME);
    end

    $display("\n*** TIME %0f ***\n", $realtime);
    $display("TB PARAMETERS:");
    $display("  NAME=%s", NAME);
    $display("  SEED=%0d", SEED);
    $display("  BITS=%0d", BITS);
    $display("  SIZE=%0d", SIZE);

    begin
      int unsigned total_errors;
      total_errors = 0;
      $display("SCORE BOARD (ERRORS):");
      foreach (counters[k]) begin
        $display("  %s = %0d", k, counters[k].error_count);
        total_errors += counters[k].error_count;
      end
      $display("  TOTAL = %0d", total_errors);

      if (total_errors != 0) begin
        $fatal(1, "TEST FAILED: %0d error(s)", total_errors);
      end else begin
        $display("TEST PASSED");
        $finish;
      end
    end
  end


endmodule
