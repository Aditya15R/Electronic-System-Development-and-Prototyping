`timescale 1ns / 1ps

//-----------------------------------------------------------------------------
// Module Name : Delay
// Description :
//   Implements a one-clock-cycle delay element.
//   On every rising edge of the clock, the input sample is stored
//   and presented at the output during the next clock cycle.
//
// Inputs :
//   clk - System clock.
//   x   - Current input sample.
//
// Outputs :
//   y   - Delayed version of input sample.
//-----------------------------------------------------------------------------

module Delay (
    input clk,
    input [7:0] x,
    output reg [7:0] y = 0
);

always @(posedge clk) begin
    y <= x;
end

endmodule


//-----------------------------------------------------------------------------
// Module Name : FIR_Filter
// Description :
//   Implements a 4-tap Finite Impulse Response (FIR) filter.
//
//   Transfer Function:
//
//      y[n] = (3x[n] + 3x[n-1] + x[n-2] + x[n-3]) / 8
//
//   Filter Coefficients:
//
//      h = [3/8, 3/8, 1/8, 1/8]
//
//   Three delay blocks are used to generate previous input samples
//   x[n−1], x[n−2], and x[n−3]. The weighted sum of the current and
//   delayed samples is computed on each rising edge of the clock.
//
// Inputs :
//   clk - System clock.
//   x   - Current 8-bit input sample.
//
// Outputs :
//   y   - Filtered 8-bit output sample.
//-----------------------------------------------------------------------------

module FIR_Filter(
    input clk,
    input [7:0] x,
    output reg [7:0] y = 0
);

    // Delayed versions of the input signal
    wire [7:0] x1, x2, x3;

    // Generate x[n-1], x[n-2], and x[n-3]
    Delay d1(.clk(clk), .x(x),  .y(x1));
    Delay d2(.clk(clk), .x(x1), .y(x2));
    Delay d3(.clk(clk), .x(x2), .y(x3));

    // Compute FIR filter output
    always @(posedge clk) begin
        y = (3*x + 3*x1 + 1*x2 + 1*x3)/8;
    end

endmodule
