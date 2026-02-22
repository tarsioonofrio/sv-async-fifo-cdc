module sync_2ff
  #(
    parameter int WIDTH = 1
  )
  (
    input  logic clk,
    input  logic rst_n,
    input  logic [WIDTH-1:0] p_d,
    output logic [WIDTH-1:0] p_q
  );

  (* ASYNC_REG = "TRUE" *) logic [WIDTH-1:0] r_ff1;
  (* ASYNC_REG = "TRUE" *) logic [WIDTH-1:0] r_ff2;

  timeunit 1ns;
  timeprecision 1ps;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      r_ff1 <= '0;
      r_ff2 <= '0;
    end else begin
      r_ff1 <= p_d;
      r_ff2 <= r_ff1;
    end
  end

  assign p_q = r_ff2;

endmodule
