
`define WIDTH 8
`define DEPTH 16

module tb;

  reg clk = 0, rst = 0, wr = 0, re = 0;
  reg  [`WIDTH-1:0] in_data;
  wire [`WIDTH-1:0] out_data;
  wire full, empty, almost_full, almost_empty, overflow, underflow;

  // Instantiate the FIFO
  FIFO #(.WIDTH(`WIDTH), .DEPTH(`DEPTH)) dut (
    .i_clk(clk),
    .i_rst(rst),
    .i_wr(wr),
    .i_re(re),
    .i_data(in_data),
    .o_full(full),
    .o_empty(empty),
    .o_almost_full(almost_full),
    .o_almost_empty(almost_empty),
    .o_overflow(overflow),
    .o_underflow(underflow),
    .o_data(out_data)
  );

  // Clock generation
  always #2 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    $monitor($time, " rst=%b, wr=%b, re=%b, in_data=%0d, out_data=%0d, full=%b, empty=%b, almost_full=%b, almost_empty=%b, overflow=%b, underflow=%b", rst, wr, re, in_data, out_data, full, empty, almost_full, almost_empty, overflow, underflow);

    test_case_1(1);
    test_case_2(2);
    test_case_3(1);
    test_case_4(1);
    test_case_5(1);
    test_case_6(1);
    

    #100;
    $finish;
  end

  // Delay task
  task delay(input integer d);
    repeat (d) @(posedge clk);
  endtask

  // Write task
  task write(input integer n);
    begin
      for (integer i = 0; i < n; i++) begin
        @(posedge clk);
        wr = 1;
        re = 0;
        in_data = $random;
      end
      wr = 0;
    end
  endtask

  // Read task
  task read(input integer n);
    begin
      for (integer i = 0; i < n; i++) begin
        @(posedge clk);
        wr = 0;
        re = 1;
      end
      re = 0;
    end
  endtask

  // Reset task
  task reset_fifo;
    begin
      rst = 1;
      delay(1);
      rst = 0;
    end
  endtask

  // Test cases

  task test_case_1(input integer n); // Write + Read
    begin
      reset_fifo();
      repeat (n) begin
        write(1);
        read(1);
      end
    end
  endtask

  task test_case_2(input integer n); // Reset
    begin
      repeat (n) begin
        write(3);
        read(3);
        reset_fifo();
        read(3);
      end
    end
  endtask

  task test_case_3(input integer n); // Empty flag
    begin
      reset_fifo();
      repeat (n) begin
        write(1);
        read(1);
      end
    end
  endtask

  task test_case_4(input integer n); // Full flag
    begin
      reset_fifo();
      write(n);
      read(n);
    end
  endtask

  task test_case_5(input integer n); // Almost empty
    begin
      reset_fifo();
      repeat (n) begin
        write(`DEPTH/5);
        read(1);
        write(1);
        read(1);
      end
    end
  endtask



  task test_case_6(input integer n); // Almost full
    begin
      reset_fifo();
      repeat (n) begin
        write((4*`DEPTH)/5);
        read(1);
        write(1);
        read(1);
      end
    end
  endtask

endmodule
