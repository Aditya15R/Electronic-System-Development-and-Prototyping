`timescale 1ns / 1ps

//-----------------------------------------------------------------------------
// Module Name : tb_ADC_to_DAC
//
// Description :
//   Testbench for functional verification of the ADC-to-DAC loopback
//   design using behavioral simulation.
//
// Purpose :
//   Before generating the FPGA bitstream and testing the design on
//   hardware, this testbench is used to verify the correctness of:
//
//      • Sawtooth waveform generation
//      • ADC to DAC data conversion
//      • Two's complement to offset binary conversion
//      • Data scaling from 10-bit ADC format to 12-bit DAC format
//      • End-to-end digital signal flow
//
//   The testbench creates a virtual loopback environment by feeding
//   the internally generated DAC3 output back to the ADC input after
//   performing the inverse format conversion.
//
// Loopback Path in Simulation:
//
//      DAC3 Output
//            |
//            |
//            ▼
//      Reverse Conversion
//            |
//            ▼
//      ADC Input
//            |
//            ▼
//      ADC_to_DAC Module
//            |
//            ▼
//      DAC1 Output
//
//   This mimics the actual hardware setup where the analog output of
//   DAC3 is physically connected to ADC1 using a jumper wire.
//
// Verification Goals :
//   - Verify correct sawtooth waveform generation.
//   - Verify proper ADC-to-DAC format conversion.
//   - Verify scaling between 10-bit ADC and 12-bit DAC.
//   - Confirm that DAC1 reconstructs the original waveform.
//   - Detect functional errors before synthesis and implementation.
//
//-----------------------------------------------------------------------------
module tb_ADC_to_DAC();

    //-------------------------------------------------------------------------
    // Testbench Inputs
    //-------------------------------------------------------------------------
    
    // 100 MHz system clock
    reg clk;

    // Simulated ADC input data
    reg [9:0] adc1_data;

    //-------------------------------------------------------------------------
    // Testbench Outputs
    //-------------------------------------------------------------------------
    
    // Internally generated sawtooth waveform
    wire [11:0] dac3_out;

    // Reconstructed DAC output after loopback processing
    wire [11:0] dac1_out;

    //-------------------------------------------------------------------------
    // Instantiate the Design Under Test (DUT)
    //-------------------------------------------------------------------------
    
    ADC_to_DAC uut (
        .clk(clk),
        .adc1_data(adc1_data),
        .dac3_out(dac3_out),
        .dac1_out(dac1_out)
    );

    //-------------------------------------------------------------------------
    // Clock Generation
    //
    // Generates a 100 MHz clock with a period of 10 ns.
    //
    //      Frequency = 100 MHz
    //      Period    = 10 ns
    //
    //-------------------------------------------------------------------------
    initial begin
        clk = 0;

        // Toggle clock every 5 ns
        forever #5 clk = ~clk;
    end

    //-------------------------------------------------------------------------
    // Virtual ADC Loopback
    //
    // The actual hardware setup connects:
    //
    //      DAC3 Output ---> ADC1 Input
    //
    // through an analog signal path.
    //
    // During behavioral simulation, analog hardware is not present.
    // Therefore, an inverse conversion is performed to emulate the
    // ADC sampling process.
    //
    // Reverse Conversion:
    //
    //      DAC Offset Binary (12-bit)
    //                    ↓
    //      Two's Complement (10-bit)
    //
    // The MSB is inverted and the two least significant bits are
    // discarded, effectively reversing the conversion implemented
    // inside the DUT.
    //
    //-------------------------------------------------------------------------
    always @(*) begin

        // Reverse conversion:
        //
        // DAC Format:
        //     12-bit Offset Binary
        //
        // ADC Format:
        //     10-bit Two's Complement
        //
        // Remove two LSBs and invert MSB
        adc1_data = {~dac3_out[11], dac3_out[10:2]};

    end

endmodule
