`timescale 1ns / 1ps

//=============================================================================
// MODULE NAME : buck
//
// DESCRIPTION:
//   This module implements an Open-Loop Digital Controller for a Buck
//   Converter on an FPGA.
//
// PURPOSE:
//   The primary objective of this design is to generate a fixed-duty-cycle
//   PWM signal to drive the switching device (MOSFET) of a buck converter
//   and experimentally observe the resulting output voltage.
//
// Unlike a closed-loop controller, no feedback control algorithm is used.
// The duty cycle remains constant irrespective of changes in output voltage,
// load conditions, or disturbances.
//
// This experiment is typically performed as an initial validation step
// before implementing closed-loop voltage or current control.
//
// OPEN-LOOP TEST OBJECTIVES:
//
//   • Generate a fixed PWM duty cycle.
//   • Drive the buck converter switch.
//   • Measure converter output voltage.
//   • Observe converter startup behavior.
//   • Verify whether output settles to the expected DC value.
//   • Compare measured output with theoretical value:
//
//          Vout = D × Vin
//
//     where:
//
//          D = Duty Cycle
//          Vin = Input Supply Voltage
//
//   • Establish a baseline for future closed-loop control experiments.
//
// FPGA INTERFACES:
//
//   ADC1:
//      Used to monitor one analog quantity
//      (typically output voltage).
//
//   ADC2:
//      Used to monitor another analog quantity
//      (typically output current or another test point).
//
//   DAC2 & DAC3:
//      Used to visualize ADC measurements on an oscilloscope.
//
// PWM:
//      Drives the gate driver / MOSFET of the buck converter.
//
//=============================================================================

module buck(
    input clk,

    // ADC Inputs (10-bit Two's Complement Format)
    input [9:0] adc_1,
    input [9:0] adc_2,

    // PWM Output for Buck Converter Switching
    output PWM,

    // Converter Control Signals
    output FCCM,
    output EN,

    // ADC/DAC Sampling Clocks
    output clk_adc1,
    output clk_dac3,
    output clk_dac2,

    // DAC Outputs (12-bit Offset Binary Format)
    output [11:0] dac_3,
    output [11:0] dac_2
);

    // PWM GENERATOR
    // Generates a fixed duty-cycle PWM waveform used to control the
    // buck converter switching transistor.
    
    PWM20 DUTY(clk, PWM);

    // CLOCK GENERATION
    // Generates synchronized sampling clocks for:
    //      ADC1
    //      ADC2
    //      DAC2
    //      DAC3
  
    clocksource CLK(
        clk,
        clk_adc1,
        clk_adc2,
        clk_dac3,
        clk_dac2
    );

    // FCCM (Forced Continuous Conduction Mode)
    // Logic High enables continuous conduction operation.
    
    assign FCCM = 1;

    // Converter Enable Signal
    // Logic High enables the power stage.
    
    assign EN = 1;

    // ADC TO DAC DATA CONVERSION
    // ADC Data Format: 10-bit Two's Complement
    // DAC Data Format: 12-bit Offset Binary
    // Conversion Method:
    //      1. Invert sign bit
    //      2. Append two LSBs
    // This allows real-time visualization of ADC signals on an oscilloscope
    // through DAC outputs.
    
    assign dac_3[11:0] = {~adc_1[9], adc_1[8:0], 2'b00};

    assign dac_2[11:0] = {~adc_2[9], adc_2[8:0], 2'b00};

endmodule

//=============================================================================
// PWM GENERATOR MODULE
//
// MODULE NAME : PWM20
//
// DESCRIPTION:
//   Generates a fixed duty-cycle PWM waveform for open-loop buck
//   converter operation.
//
// PWM PRINCIPLE:
//
//      Counter counts from 0 to 1999.
//
//      PWM = HIGH  when counter < 400
//      PWM = LOW   otherwise
//
// Therefore:
//
//      Period Counts = 2000
//      High Counts   = 400
//
// DUTY CYCLE:
//
//      D = 400 / 2000
//        = 0.20
//        = 20%
//
// Thus this module generates a constant 20% duty-cycle PWM signal.
//
// THEORETICAL BUCK OUTPUT:
//
//      Vout = D × Vin
// Example:
//      Vin = 12 V
//      Vout ≈ 0.2 × 12
//            = 2.4 V
//
// Actual output depends on:
//
//      • Switching losses
//      • Inductor resistance
//      • MOSFET losses
//      • Load current
//=============================================================================

module PWM20(
    input clk,
    output reg duty
);

    // PWM Counter
    reg [10:0] counter = 0;
  
    always @(posedge clk) begin
        // PWM Period Counter
        if(counter == 1999) begin
            counter <= 0;
        end
        else begin
            counter = counter + 1;
        end
        
        // Duty-Cycle Comparison
        // HIGH for first 400 counts
        // LOW  for remaining counts
        
        if(counter <= 399) begin
            duty <= 1;
        end
        else begin
            duty <= 0;
        end
    end
endmodule


//=============================================================================
// CLOCK GENERATION MODULE
//
// MODULE NAME : clocksource
//
// DESCRIPTION:
//   Generates slower clocks required by ADC and DAC devices from the
//   FPGA system clock.
//
// PURPOSE:
//
//   ADCs and DACs often operate at sampling frequencies lower than the
//   FPGA master clock frequency.
//
// This module provides synchronized clock signals for:
//
//      • ADC1
//      • ADC2
//      • DAC2
//      • DAC3
//
// All peripherals share the same divided clock.
//
//=============================================================================

module clocksource(

    input clk,

    output clk_adc1,
    output clk_adc2,

    output clk_dac3,
    output clk_dac2

);

    // Divider Counter
    reg [1:0] count = 0;
    
    // Divided Clock
    reg div_clk = 0;

    always @(posedge clk) begin

        // Clock Division Logic
        if(count == 2) begin
            div_clk = ~div_clk;
        end
        count = count + 1;
    end

    // Clock Distribution
    assign clk_adc1 = div_clk;
    assign clk_adc2 = div_clk;

    assign clk_dac3 = div_clk;
    assign clk_dac2 = div_clk;

endmodule
