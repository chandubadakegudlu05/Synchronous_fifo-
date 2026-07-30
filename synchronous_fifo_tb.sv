//------------------------------------------------------------------------
// Title   : Synchronous FIFO Testbench
// Author  : Chandu B V
// Date    : 15/04/2026
//------------------------------------------------------------------------
module synchronous_fifo_tb;

  parameter fifo_depth = 8;
  parameter fifo_width = 32;

  logic clk, reset, cs, wt_en, rd_en;
  logic [fifo_width-1:0] data_in;
  logic empty, full;
  logic [fifo_width-1:0] data_out;

  integer i;

  synchronous_fifo #(.fifo_depth(fifo_depth), .fifo_width(fifo_width)) dut (
    .clk(clk), .reset(reset), .cs(cs), .wt_en(wt_en), .rd_en(rd_en),
    .data_in(data_in), .empty(empty), .full(full), .data_out(data_out)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    #800 $finish;
  end

  // Write task
  task automatic write_data(input [fifo_width-1:0] d_in);
    begin
      @(posedge clk);
      cs = 1; wt_en = 1;
      data_in = d_in;
      $display("[%0t] write_data: data_in=%0d full=%0b", $time, data_in, full);
      @(posedge clk);
      cs = 1; wt_en = 0;
    end
  endtask

  // Read task
  task automatic read_data();
    begin
      @(posedge clk);
      cs = 1; rd_en = 1;
      @(posedge clk);
      $display("[%0t] read_data: data_out=%0d empty=%0b", $time, data_out, empty);
      cs = 1; rd_en = 0;
    end
  endtask

  // Stimulus
  initial begin
    reset = 0; rd_en = 0; wt_en = 0; cs = 0;
    @(posedge clk);
    reset = 1;

    $display("%0t \n SCENARIO 1: basic write/read", $time);
    write_data(1);
    write_data(10);
    write_data(100);
    read_data();
    read_data();
    read_data();
    read_data();

    $display("%0t \n SCENARIO 2: interleaved write/read", $time);
    for (i = 0; i < fifo_depth; i++) begin
      write_data(2**i);
      read_data();
    end

    $display("%0t \n SCENARIO 3: fill then drain (full/empty flag test)", $time);
    for (i = 0; i < fifo_depth; i++) begin
      write_data(4**i);
    end
    for (i = 0; i < fifo_depth; i++) begin
      read_data();
    end
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, synchronous_fifo_tb);
  end

endmodule
