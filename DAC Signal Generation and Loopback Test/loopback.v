`timescale 1ns / 1ps

//-----------------------------------------------------------------------------
// Module Name : loopback
//
// Description :
//   This module performs a complete ADC-DAC loopback test on the FPGA
//   control board.
//
//   The design has two primary functions:
//
//   1. Sawtooth Waveform Generation (DAC3)
//      - A 12-bit digital sawtooth waveform is generated internally
//        using an incrementing counter.
//      - The waveform is sent to DAC3, producing an analog sawtooth
//        signal at the DAC output.
//
//   2. ADC-to-DAC Loopback (DAC1)
//      - The analog sawtooth output from DAC3 is physically connected
//        to ADC1 on the control board.
//      - ADC1 samples the analog signal and converts it into a
//        10-bit two's-complement digital value.
//      - The FPGA receives this sampled data and converts it into
//        the format required by DAC1.
//      - DAC1 reconstructs the signal, allowing observation of the
//        complete ADC → FPGA → DAC signal path.
//
// Purpose :
//   This experiment validates the complete signal acquisition and
//   reconstruction chain:
//
//      FPGA → DAC3 → Analog Signal → ADC1 → FPGA → DAC1
//
//   By comparing the outputs of DAC3 and DAC1, it is possible to
//   evaluate:
//
//      • ADC conversion accuracy
//      • DAC reconstruction accuracy
//      • Quantization effects
//      • Offset and gain errors
//      • Signal distortion
//      • End-to-end latency through the signal chain
//
//   This loopback architecture serves as a foundation for future
//   digital signal processing (DSP) experiments where the sampled
//   signal can be filtered, modified, or analyzed before being
//   transmitted back through the DAC.
//
// Inputs :
//   clk        - 100 MHz FPGA system clock.
//   adc_data1  - 10-bit two's-complement data from ADC1.
//
// Outputs :
//   dac_data1  - Reconstructed signal sent to DAC1.
//   dac_data3  - Internally generated sawtooth waveform sent to DAC3.
//
//-----------------------------------------------------------------------------
module loopback (
    input clk,                       // 100 MHz FPGA Clock
    input [9:0] adc_data1,           // ADC1 sampled data (10-bit two's complement)

    // DAC1 output after ADC → FPGA → DAC loopback path
    output reg [11:0] dac_data1 = 0,

    // DAC3 output used to generate the reference sawtooth waveform
    output reg [11:0] dac_data3 = 0
);

    //-------------------------------------------------------------------------
    // Clock Divider
    //
    // The FPGA operates at 100 MHz while the ADC and DAC devices are driven
    // at an effective sampling rate of 25 MHz.
    //
    // A 2-bit counter generates a clock enable pulse once every four clock
    // cycles, resulting in a 25 MHz update rate.
    //-------------------------------------------------------------------------
    reg [1:0] clk_div = 0;
    wire clk_25mhz;

    always @(posedge clk) begin
        clk_div <= clk_div + 1;
    end

    // Clock enable pulse asserted once every four clock cycles
    assign clk_25mhz = (clk_div == 2'b11);

    // ADC and DAC sampling clocks
    assign clk_adc1 = clk_25mhz;
    assign clk_dac1 = clk_25mhz;
    assign clk_dac3 = clk_25mhz;

    //-------------------------------------------------------------------------
    // Sawtooth Waveform Generator (DAC3)
    //
    // A 12-bit counter continuously increments at the 25 MHz sampling rate.
    //
    // Output sequence:
    //     0 → 1 → 2 → ... → 4095 → 0 → ...
    //
    // The DAC converts this digital ramp into an analog sawtooth waveform.
    //
    // This waveform acts as the reference signal for the loopback test.
    //-------------------------------------------------------------------------
    always @(posedge clk) begin
        if (clk_25mhz) begin
            dac_data3 <= dac_data3 + 1'b1;
        end
    end

    //-------------------------------------------------------------------------
    // ADC to DAC Loopback Path (DAC1)
    //
    // ADC1 provides data in 10-bit two's-complement format.
    //
    // DAC1 expects data in 12-bit offset-binary format.
    //
    // Conversion Process:
    //
    // 1. Invert the MSB
    //      Two's Complement → Offset Binary
    //
    // 2. Append two zero LSBs
    //      10-bit → 12-bit scaling
    //
    // Conversion:
    //
    //      DAC_Data = {~ADC_MSB, ADC_Data[8:0], 2'b00}
    //
    // The reconstructed waveform is then transmitted through DAC1.
    //-------------------------------------------------------------------------
    always @(posedge clk) begin
        if (clk_25mhz) begin
            dac_data1 <= {~adc_data1[9], adc_data1[8:0], 2'b00};
        end
    end

endmodule
