`timescale 1ns / 1ps

//=============================================================================
// MODULE NAME : IIR_Filter_First_Ordr
//
// DESCRIPTION:
//   This module implements a First-Order Infinite Impulse Response (IIR)
//   digital filter using fixed-point arithmetic.
//
// FILTER DIFFERENCE EQUATION:
//
//      y[n] = b0·x[n] + b1·x[n−1] + a1·y[n−1]
//
// where:
//
//      x[n]   = current input sample
//      x[n−1] = previous input sample
//      y[n−1] = previous output sample
//      y[n]   = current output sample
//
// The filter is implemented in Direct Form-I structure using:
//
//      • Input delay element
//      • Output feedback delay element
//      • Fixed-point multipliers
//      • Saturation logic
//      • Truncation logic
//
// This implementation is intended for FPGA realization and uses
// fixed-point arithmetic instead of floating-point arithmetic to
// reduce hardware resource utilization.
//
// COEFFICIENTS:
//
//      a1 = 0.997489
//      b0 = 0.001255
//      b1 = 0.001255
//
// These coefficients correspond to a first-order low-pass IIR filter.
//
// INPUT FORMAT:
//
//      x[n] : 10-bit signed fixed-point sample
//
// OUTPUT FORMAT:
//
//      y[n] : 16-bit signed fixed-point sample
//
//=============================================================================

module IIR_Filter_First_Ordr(
    input clk,
    input wire signed [9:0] x_n,
    output signed [15:0] y_out
);

    //---------------------------------------------------------------------
    // Filter coefficients stored in fixed-point format.
    //
    // Q1.18 representation:
    //
    //      1 Sign Bit
    //      18 Fractional Bits
    //
    //---------------------------------------------------------------------

    parameter a1 = 19'sb0_111111110101101101; // 0.997489
    parameter b0 = 19'sb0_000000000101001000; // 0.001255
    parameter b1 = 19'sb0_000000000101001000; // 0.001255

    //---------------------------------------------------------------------
    // Delay Elements
    //
    // x_n_1  = x[n−1]
    // y_out_1 = y[n−1]
    //---------------------------------------------------------------------

    wire signed [9:0] x_n_1;
    wire signed [15:0] y_out_1;

    delay1_10 Dx1(clk, x_n, x_n_1);
    delay1_16 Dy1(clk, y_out, y_out_1);

    //---------------------------------------------------------------------
    // Feedforward Path
    //
    // Computes:
    //
    //      b0·x[n]
    //      b1·x[n−1]
    //---------------------------------------------------------------------

    wire signed [28:0] x_n_b0;
    assign x_n_b0 = x_n * b0;

    wire signed [34:0] x_n_b0_pad;
    pad1 p01(x_n_b0, x_n_b0_pad);

    wire signed [28:0] x_n_1_b1;
    assign x_n_1_b1 = x_n_1 * b1;

    wire signed [34:0] x_n_1_b1_pad;
    pad1 p11(x_n_1_b1, x_n_1_b1_pad);

    //---------------------------------------------------------------------
    // Feedback Path
    //
    // Computes:
    //
    //      a1·y[n−1]
    //---------------------------------------------------------------------

    wire signed [34:0] y_out_1_a1;
    assign y_out_1_a1 = y_out_1 * a1;

    //---------------------------------------------------------------------
    // Accumulator
    //
    // Implements:
    //
    //      y[n] = b0x[n] + b1x[n−1] + a1y[n−1]
    //---------------------------------------------------------------------

    wire signed [34:0] y_out_temp;

    assign y_out_temp =
            x_n_b0_pad +
            x_n_1_b1_pad +
            y_out_1_a1;

    //---------------------------------------------------------------------
    // Saturation Logic
    //
    // Prevents overflow when the accumulator exceeds the allowable
    // Q1.15 output range.
    //---------------------------------------------------------------------

    wire signed [34:0] y_out_sat;

    saturate1 S1(y_out_temp, y_out_sat);

    //---------------------------------------------------------------------
    // Truncation
    //
    // Converts internal high-precision result into a 16-bit output.
    //---------------------------------------------------------------------

    truncate1 T1(y_out_sat, y_out);

endmodule


//=============================================================================
// PADDING MODULE
//
// DESCRIPTION:
//
// Extends a 29-bit multiplication result to a 35-bit value.
//
// Six zero bits are appended to align all operands to the same
// fixed-point format before addition.
//
// Equivalent to multiplying by:
//
//      2^6 = 64
//
//=============================================================================

module pad1(
    input wire signed [28:0] x,
    output wire signed [34:0] y
);

    assign y[34:0] = {x[28:0], 6'b000000};

endmodule


//=============================================================================
// SATURATION MODULE
//
// DESCRIPTION:
//
// Limits the internal filter output to the maximum and minimum
// representable values of the target Q1.15 format.
//
// This prevents arithmetic overflow and wrap-around effects that
// could destabilize the filter.
//
//=============================================================================

module saturate1(
    input wire signed [34:0] x,
    output signed [34:0] y
);

    //---------------------------------------------------------------------
    // Maximum positive value of Q1.15
    //---------------------------------------------------------------------

    parameter MAX_VALUE =
        35'sb00_111111111111111000000000000000000;

    //---------------------------------------------------------------------
    // Minimum negative value of Q1.15
    //---------------------------------------------------------------------

    parameter MIN_VALUE =
        35'sb11_000000000000000000000000000000000;

    assign y =
        (x > MAX_VALUE) ? MAX_VALUE :
        (x < MIN_VALUE) ? MIN_VALUE :
        x;

endmodule


//=============================================================================
// TRUNCATION MODULE
//
// DESCRIPTION:
//
// Extracts the final 16-bit output from the internal 35-bit
// fixed-point accumulator.
//
// This operation removes excess fractional bits while preserving
// the most significant bits of the filtered signal.
//
//=============================================================================

module truncate1(
    input wire [34:0] x,
    output wire [15:0] y
);

    assign y[15:0] = x[33:18];

endmodule


//=============================================================================
// 10-BIT DELAY ELEMENT
//
// DESCRIPTION:
//
// Implements a one-sample delay:
//
//      y[n] = x[n−1]
//
// Used to store the previous input sample.
//
//=============================================================================

module delay1_10(
    input clk,
    input wire signed [9:0] x,
    output reg signed [9:0] y = 0
);

    always @(posedge clk) begin
        y <= x;
    end

endmodule


//=============================================================================
// 16-BIT DELAY ELEMENT
//
// DESCRIPTION:
//
// Implements a one-sample delay:
//
//      y[n] = x[n−1]
//
// Used to store the previous filter output sample required by
// the feedback path of the IIR filter.
//
//=============================================================================

module delay1_16(
    input clk,
    input wire signed [15:0] x,
    output reg signed [15:0] y = 0
);

    always @(posedge clk) begin
        y <= x;
    end

endmodule
