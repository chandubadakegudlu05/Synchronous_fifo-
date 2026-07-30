//------------------------------------------------------------------------
// Title   : Synchronous FIFO
// Author  : Chandu B V
// Date    : 15/04/2026
// Description:
//   Parameterized synchronous FIFO with full/empty detection using the
//------------------------------------------------------------------------
module synchronous_fifo
  #(parameter fifo_depth = 8,
    parameter fifo_width = 32)
  (
    input  logic                   clk,
    input  logic                   reset,     // active-low async reset
    input  logic                   cs,
    input  logic                   wt_en,
    input  logic                   rd_en,
    input  logic [fifo_width-1:0]  data_in,
    output logic                   empty,
    output logic                   full,
    output logic [fifo_width-1:0]  data_out
  );

  localparam fifo_depth_log = $clog2(fifo_depth);

  logic [fifo_depth_log:0] wt_ptr;
  logic [fifo_depth_log:0] rd_ptr;

  logic [fifo_width-1:0] fifo [fifo_depth-1:0];

  assign empty = (rd_ptr == wt_ptr);
  assign full  = (rd_ptr == {~wt_ptr[fifo_depth_log], wt_ptr[fifo_depth_log-1:0]});

  // ---------------- Write logic ----------------
  always_ff @(posedge clk or negedge reset) begin
    if (!reset)
      wt_ptr <= '0;
    else if (cs && !full && wt_en) begin
      fifo[wt_ptr[fifo_depth_log-1:0]] <= data_in;
      wt_ptr <= wt_ptr + 1'b1;
    end
  end

  // ---------------- Read logic ----------------
  always_ff @(posedge clk or negedge reset) begin
    if (!reset)
      rd_ptr <= '0;
    else if (cs && !empty && rd_en) begin
      data_out <= fifo[rd_ptr[fifo_depth_log-1:0]];
      rd_ptr   <= rd_ptr + 1'b1;
    end
  end

endmodule
