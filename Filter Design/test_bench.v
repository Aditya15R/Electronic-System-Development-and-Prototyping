`timescale 1ns / 1ps

//=============================================================================
// TESTBENCH FOR FIRST-ORDER AND SECOND-ORDER IIR FILTERS
//
// DESCRIPTION:
//   This testbench is used to verify the functionality of both the
//   First-Order and Second-Order IIR filters through behavioral simulation
//   before FPGA implementation.
//
// The testbench generates multiple test signals:
//
//   1. Square Wave
//   2. Sawtooth Wave
//   3. Sine Wave (DDS based)
//
// and applies them to the filter modules to observe:
//
//      • Time-domain response
//      • Transient response
//      • Steady-state response
//      • Smoothing characteristics
//      • Relative performance of first and second order filters
//
// The primary objective is to verify that:
//
//      - The filters are functionally correct.
//      - Delay elements operate correctly.
//      - Recursive feedback paths are stable.
//      - Fixed-point arithmetic behaves as expected.
//      - Output waveforms match theoretical expectations.
//
//=============================================================================



//=============================================================================
// FILTER WRAPPER MODULE
//
// DESCRIPTION:
//
// Instantiates:
//
//      • First-Order IIR Filter
//      • Second-Order IIR Filter
//
// Both filters receive the same input signal.
//
// Outputs:
//
//      y1 -> First-order filter output
//      y2 -> Second-order filter output
//
// This allows direct comparison of filter responses.
//
//=============================================================================

module Filter(
    input clk,
    input [9:0] x,
    output [15:0] y1,
    output [15:0] y2
);

    // First-order IIR filter
    IIR_Filter_First_Ordr f1(clk, x, y1);

    // Second-order IIR filter
    IIR_filter f2(clk, x, y2);

endmodule


//=============================================================================
// SAWTOOTH WAVE GENERATOR
//
// DESCRIPTION:
//
// Generates a periodic sawtooth waveform to be used as the filter input.
//
// Operation:
//
//      0 → 1 → 2 → ... → 999 → 0
//
// A prescaler is used to slow down the waveform so that the transient
// response of the filters can be easily observed during simulation.
//
//=============================================================================

module sawtooth(
    input clk,
    output reg [9:0] counter = 0
);

    // Prescaler reduces waveform frequency
    reg [5:0] prescaler = 0;
    always @(posedge clk) begin
        // Increment waveform every 50 clock cycles
        if (prescaler == 49) begin
            prescaler <= 0;
            // Sawtooth reset
            if (counter == 999)
                counter <= 0;
            else
                counter <= counter + 1;
        end
        else begin
            prescaler <= prescaler + 1;
        end
    end
endmodule



//=============================================================================
// CLOCK DIVIDER
//
// DESCRIPTION:
//
// Generates a slower clock from the 100 MHz simulation clock.
//
// Used for:
//      • Frequency scaling
//      • Signal generation experiments
//      • Future DSP experiments
//
// Output:
//      clk_25
//=============================================================================

module clkgen(
    input clk,
    output clk_25
);

    reg [8:0] count = 0;
    reg myclk = 0;
    always @(posedge clk) begin
        if(count == 499) begin
            count = 0;
            myclk = ~myclk;
        end
        else begin
            count = count + 1;
        end
    end
    assign clk_25 = myclk;
endmodule

//=============================================================================
// TESTBENCH
//
// DESCRIPTION:
//
// Main simulation environment.
//
// Generates:
//      • 100 MHz system clock
//      • Square wave test signal
//      • Sawtooth wave test signal
//
// Instantiates:
//      • First-order IIR filter
//      • Second-order IIR filter
//
// The outputs can be observed in Vivado Simulation Waveform Viewer
// to compare filter performance.
//=============================================================================

module tb();
  
    // Clock Signals
    reg clk;
    wire clk25;
  
    // Input Test Signals
  
    // Square wave input
    reg [9:0] squ;

    // Sawtooth input
    wire [9:0] sw;

    // Filter Outputs

    // Square wave responses
    wire [15:0] y1sq;
    wire [15:0] y2sq;

    // Sawtooth responses
    wire [15:0] y1sw;
    wire [15:0] y2sw;

    wire rst;
    assign rst = 1'b0;

    // 100 MHz Clock Generation
    // Clock Period = 10 ns

    initial begin
        clk = 0;
    end

    always begin
        #5 clk = ~clk;
    end

    //---------------------------------------------------------------------
    // Square Wave Generation
    //
    // Alternates between:
    //
    //      0x300
    //      0x100
    //
    // This approximates a step input and allows observation of:
    //
    //      • Rise time
    //      • Settling time
    //      • Overshoot
    //      • Filter smoothing
    //
    //---------------------------------------------------------------------

    initial begin
        squ = 10'h300;
    end
    always begin
        #250000 squ = 10'h100;
        #250000 squ = 10'h300;
    end
  
    // Sawtooth Generator Instance
  
    sawtooth s1(clk, sw);

    //---------------------------------------------------------------------
    // Filter Testing
    //
    // F1:
    //      Filters Square Wave
    //
    // F2:
    //      Filters Sawtooth Wave
    //
    //---------------------------------------------------------------------

    Filter F1(clk, squ, y1sq, y2sq);

    Filter F2(clk, sw, y1sw, y2sw);

    // Clock Divider Instance  

    clkgen c1(clk, clk25);
endmodule
