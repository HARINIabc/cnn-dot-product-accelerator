`timescale 1ns/1ps
`default_nettype none

module mac #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire clear,

    input  wire signed [DATA_WIDTH-1:0] a,
    input  wire signed [DATA_WIDTH-1:0] b,
    output reg  signed [ACC_WIDTH-1:0]  acc_out
);

    localparam PROD_WIDTH = 2 * DATA_WIDTH;

    wire signed [PROD_WIDTH-1:0] product;
    assign product = a * b;

    always @(posedge clk) begin
        if (rst || clear) begin
            acc_out <= '0;
        end else if (en) begin
            acc_out <= acc_out + product;
        end
    end

endmodule

`default_nettype wire


