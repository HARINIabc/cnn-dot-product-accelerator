`timescale 1ns/1ps
initial begin
  // expected golden result
  int signed expected = 0;
  for (int i = 0; i < N; i++) begin
      expected += a_arr[i] * b_arr[i];
  end

  @(posedge clk);
  if (dot_out !== expected) begin
    $fatal("FAIL: expected %0d got %0d", expected, dot_out);
  end else begin
    $display("PASS: result %0d", dot_out);
  end
end

module mac_array_4_tb;

  reg clk;
  reg rst;
  reg valid_in;
  reg start;
  wire valid_out;

  reg signed [7:0] a [0:3];
  reg signed [7:0] b [0:3];

  wire signed [31:0] acc_out [0:3];
  wire signed [35:0] dot_out;

  // Instantiate 4-MAC array
  mac_array #(.NUM_MACS(4)) dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .valid_in(valid_in),
    .valid_out(valid_out),
    .a(a),
    .b(b),
    .acc_out(acc_out),
    .dot_out(dot_out)
  );

  // Clock (10 ns period)
  always #5 clk = ~clk;

  integer i;

  initial begin
    // Waveform
    $dumpfile("mac_array_4.vcd");
    $dumpvars(0, mac_array_4_tb);

    // Init
    clk      = 0;
    rst      = 1;
    start    = 0;
    valid_in = 0;

    for (i = 0; i < 4; i = i + 1) begin
      a[i] = 0;
      b[i] = 0;
    end

    // Release reset
    #10 rst = 0;

    // ---- START NEW WINDOW ----
    #10 start = 1;   // clear MAC accumulators
    #10 start = 0;

    // ---- VALID DATA PHASE ----
    #10 valid_in = 1;

    // Cycle 1
    a[0] = 1;  b[0] = 2;
    a[1] = 2;  b[1] = 3;
    a[2] = 3;  b[2] = 4;
    a[3] = 4;  b[3] = 5;

    #10;

    // Cycle 2
    a[0] = -1; b[0] = 2;
    a[1] =  1; b[1] = 1;
    a[2] =  0; b[2] = 5;
    a[3] = -2; b[3] = 3;

    // ---- FREEZE ----
    #10 valid_in = 0;

    // Observe frozen output
    #30 $finish;
  end

  // Monitor control + output
  initial begin
    $monitor(
      "t=%0t | start=%b valid_in=%b valid_out=%b | dot=%d",
      $time, start, valid_in, valid_out, dot_out
    );
  end

endmodule

