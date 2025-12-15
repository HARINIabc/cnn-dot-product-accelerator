`timescale 1ns/1ps

module mac_array #(
    parameter NUM_MACS = 4
)(
    input  wire clk,
    input  wire rst,

    input  wire start,      // NEW: start a window
    input  wire valid_in,   // data valid

    input  wire signed [7:0]  a [0:NUM_MACS-1],
    input  wire signed [7:0]  b [0:NUM_MACS-1],

    output wire signed [31:0] acc_out [0:NUM_MACS-1],
    output reg  signed [35:0] dot_out,
    output reg  valid_out
);

    // Clear MACs on start pulse
    wire clear;
    assign clear = start;

    // ---------------- MAC ARRAY ----------------
    genvar i;
    generate
        for (i = 0; i < NUM_MACS; i = i + 1) begin : MACS
            mac mac_i (
                .clk(clk),
                .rst(rst),
                .en(valid_in),
                .clear(clear),
                .a(a[i]),
                .b(b[i]),
                .acc_out(acc_out[i])
            );
        end
    endgenerate
    // -------------------------------------------

    // -------- DOT PRODUCT + VALID PIPELINE -----
    integer j;
    reg signed [35:0] sum;

    always @(posedge clk) begin
        if (rst) begin
            dot_out   <= 0;
            valid_out <= 0;
        end else begin
            valid_out <= valid_in;

            if (valid_in) begin
                sum = 0;
                for (j = 0; j < NUM_MACS; j = j + 1) begin
                    sum = sum + acc_out[j];
                end
                dot_out <= sum;
            end
        end
    end
    // -------------------------------------------

endmodule
