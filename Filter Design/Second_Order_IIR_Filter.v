`timescale 1ns / 1ps

//=============================================================================
// MODULE NAME : IIR_Filter_Second_Ordr
//
// DESCRIPTION:
//   This module implements a Second-Order Infinite Impulse Response (IIR)
//   digital filter using fixed-point arithmetic for FPGA realization.
//
// FILTER DIFFERENCE EQUATION:
//
//   y[n] = b0·x[n]
//        + b1·x[n−1]
//        + b2·x[n−2]
//        + a1·y[n−1]
//        − a2·y[n−2]
//
// where:
//
//      x[n]    = current input sample
//      x[n−1]  = previous input sample
//      x[n−2]  = input sample delayed by two clocks
//
//      y[n−1]  = previous output sample
//      y[n−2]  = output sample delayed by two clocks
//
// This structure realizes a second-order recursive digital filter
// (biquad section) using:
//
//      • Two input delay elements
//      • Two output feedback delay elements
//      • Fixed-point multipliers
//      • Saturation protection
//      • Truncation logic
//
// The implementation is optimized for FPGA hardware where fixed-point
// arithmetic is significantly more resource-efficient than floating-point
// arithmetic.
//
// APPLICATIONS:
//
//      • Low-pass filters
//      • High-pass filters
//      • Band-pass filters
//      • Notch filters
//      • DSP systems
//      • Real-time signal processing
//
//=============================================================================

module IIR_Filter_Second_Ordr(
    input clk,
    input wire signed [9:0] x_n,
    output signed [15:0] y_out
);

    //-------------------------------------------------------------------------
    // FILTER COEFFICIENTS
    //
    // Stored in fixed-point format.
    //
    // These coefficients define the pole-zero locations and therefore
    // determine the frequency response of the filter.
    //-------------------------------------------------------------------------

    parameter a1 = 22'sb0111000011100101011000; // 1.764
    parameter a2 = 22'sb0011000111000010100011; // 0.7775

    parameter b0 = 22'sb0000000000111001010000; // 0.003495
    parameter b1 = 22'sb0000000001110010100001; // 0.00699
    parameter b2 = 22'sb0000000000111001010000; // 0.003495

    //-------------------------------------------------------------------------
    // DELAYED INPUT SAMPLES
    //
    // x_n_1 = x[n−1]
    // x_n_2 = x[n−2]
    //-------------------------------------------------------------------------

    wire signed [9:0] x_n_1;
    wire signed [9:0] x_n_2;

    //-------------------------------------------------------------------------
    // DELAYED OUTPUT SAMPLES
    //
    // y_out_1 = y[n−1]
    // y_out_2 = y[n−2]
    //-------------------------------------------------------------------------

    wire signed [15:0] y_out_1;
    wire signed [15:0] y_out_2;

    delay2_10 Dx12(clk, x_n,   x_n_1);
    delay2_10 Dx22(clk, x_n_1, x_n_2);

    delay2_16 Dy12(clk, y_out,   y_out_1);
    delay2_16 Dy22(clk, y_out_1, y_out_2);

    //-------------------------------------------------------------------------
    // FEEDFORWARD MULTIPLICATION TERMS
    //
    // b0·x[n]
    // b1·x[n−1]
    // b2·x[n−2]
    //-------------------------------------------------------------------------

    wire signed [31:0] x_n_b0;
    wire signed [31:0] x_n_1_b1;
    wire signed [31:0] x_n_2_b2;

    //-------------------------------------------------------------------------
    // FEEDBACK MULTIPLICATION TERMS
    //
    // a1·y[n−1]
    // a2·y[n−2]
    //-------------------------------------------------------------------------

    wire signed [37:0] y_out_1_a1;
    wire signed [37:0] y_out_2_a2;

    //-------------------------------------------------------------------------
    // Padded feedforward terms.
    //
    // Padding aligns the binary point of all signals before addition.
    //-------------------------------------------------------------------------

    wire signed [37:0] x_n_b0_pad;
    wire signed [37:0] x_n_1_b1_pad;
    wire signed [37:0] x_n_2_b2_pad;

    assign x_n_b0 = x_n * b0;
    pad2 p02(x_n_b0, x_n_b0_pad);

    assign x_n_1_b1 = x_n_1 * b1;
    pad2 p12(x_n_1_b1, x_n_1_b1_pad);

    assign x_n_2_b2 = x_n_2 * b2;
    pad2 p22(x_n_2_b2, x_n_2_b2_pad);

    //-------------------------------------------------------------------------
    // FEEDBACK MULTIPLICATIONS
    //-------------------------------------------------------------------------

    assign y_out_1_a1 = y_out_1 * a1;

    assign y_out_2_a2 = y_out_2 * a2;

    //-------------------------------------------------------------------------
    // FILTER ACCUMULATOR
    //
    // Implements:
    //
    // y[n] = b0x[n]
    //      + b1x[n−1]
    //      + b2x[n−2]
    //      + a1y[n−1]
    //      − a2y[n−2]
    //
    //-------------------------------------------------------------------------
    
    wire signed [37:0] y_out_temp;

    assign y_out_temp =
            x_n_b0_pad  +
            x_n_1_b1_pad +
            x_n_2_b2_pad +
            y_out_1_a1   -
            y_out_2_a2;

    //-------------------------------------------------------------------------
    // SATURATION STAGE
    //
    // Prevents overflow by limiting the internal accumulator to the
    // maximum and minimum representable values of the target Q1.15
    // output format.
    //-------------------------------------------------------------------------

    wire signed [37:0] y_out_sat;

    saturate2 S2(y_out_temp, y_out_sat);

    //-------------------------------------------------------------------------
    // TRUNCATION STAGE
    //
    // Converts the high-precision internal representation into a
    // 16-bit output suitable for storage and transmission.
    //-------------------------------------------------------------------------

    truncate2 T2(y_out_sat, y_out);

endmodule


//=============================================================================
// PADDING MODULE
//
// DESCRIPTION:
//
// Multiplier outputs are generated in a lower precision format.
// To align them with the accumulator format, six zeros are appended
// to the least significant side.
//
// Equivalent to:
//
//      value × 2^6
//
// This preserves the numerical value while moving the binary point.
//
//=============================================================================

module pad2(
    input wire signed [31:0] x,
    output wire signed [37:0] y
);

    assign y[37:0] = {x[31:0], 6'b000000};

endmodule


//=============================================================================
// SATURATION MODULE
//
// DESCRIPTION:
//
// Protects the filter from arithmetic overflow.
//
// If the accumulator exceeds the maximum representable value,
// it is clipped to MAX_VALUE.
//
// If it falls below the minimum representable value,
// it is clipped to MIN_VALUE.
//
// Saturation is preferred over wrap-around because wrap-around can
// severely distort signals and potentially destabilize recursive filters.
//
//=============================================================================

module saturate2(
    input wire signed [37:0] x,
    output signed [37:0] y
);

    // Maximum positive value for Q1.15 output

    parameter MAX_VALUE =
        38'sb000_11111111111111100000000000000000000;

    // Minimum negative value for Q1.15 output

    parameter MIN_VALUE =
        38'sb111_00000000000000000000000000000000000;

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
// Converts the 38-bit accumulator result into a 16-bit output.
//
// Internal calculations use additional precision to minimize
// quantization noise.
//
// After all computations are completed, only the required bits are
// retained to form the final Q1.15 output.
//
//=============================================================================

module truncate2(
    input wire [37:0] x,
    output wire [15:0] y
);

    assign y[15:0] = x[35:20];

endmodule


//=============================================================================
// 10-BIT DELAY ELEMENT
//
// DESCRIPTION:
//
// Implements a one-clock sample delay.
//
//      y[n] = x[n−1]
//
// Two instances of this module are cascaded to generate:
//
//      x[n−1]
//      x[n−2]
//
//=============================================================================

module delay2_10(
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
// Implements a one-clock sample delay for the recursive path.
//
// Two instances are cascaded to generate:
//
//      y[n−1]
//      y[n−2]
//
// required by the second-order feedback section.
//
//=============================================================================

module delay2_16(
    input clk,
    input wire signed [15:0] x,
    output reg signed [15:0] y = 0
);

    always @(posedge clk) begin
        y <= x;
    end

endmodule
