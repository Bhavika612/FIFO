module FIFO #(parameter WIDTH = 8, DEPTH = 16)(
    input                  i_clk,
    input                  i_rst,
    input                  i_wr,
    input                  i_re,
    input      [WIDTH-1:0] i_data,
    output reg             o_full,
    output reg             o_empty,
    output reg             o_almost_full,
    output reg             o_almost_empty,
    output reg             o_overflow,
    output reg             o_underflow,
    output reg [WIDTH-1:0] o_data
);

  reg [WIDTH-1:0] memory [0:DEPTH-1];
  reg [$clog2(DEPTH):0] w_ptr = 0;
  reg [$clog2(DEPTH):0] r_ptr = 0;

  // Write and read operations
  always @(posedge i_clk) begin
    o_overflow  <= 0;
    o_underflow <= 0;

    if (i_rst) begin
      w_ptr <= 0;
      r_ptr <= 0;
      o_data <= 0;
      for (integer i = 0; i < DEPTH; i = i + 1)
        memory[i] <= 0;
    end else begin
      
      if (i_wr && !o_full) begin
        memory[w_ptr[$clog2(DEPTH)-1:0]] <= i_data;
        w_ptr <= w_ptr + 1;
      end else if (i_wr && o_full) begin
        o_overflow <= 1;
      end

      if (i_re && !o_empty) begin
        o_data <= memory[r_ptr[$clog2(DEPTH)-1:0]];
        r_ptr <= r_ptr + 1;
      end else if (i_re && o_empty) begin
        o_underflow <= 1;
      end
    end
  end

  // Flag logic
  always @(*) begin
    o_empty = (w_ptr == r_ptr);
    o_full  = ((w_ptr - r_ptr) == DEPTH);

    o_almost_empty = ((w_ptr - r_ptr) <= (DEPTH / 5)) && !o_empty;

    o_almost_full = (real'(w_ptr - r_ptr) >= ((4.0 * DEPTH) / 5.0)) && !o_full;
  end

endmodule
