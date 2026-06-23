`timescale 1ns / 1ps

//-----------------------------------------------------------------------------
// Module Name : Sawtooth_Generator
// Description :
//   Generates an 8-bit digital sawtooth waveform.
//
// Operation :
//   - The output register 'sawtooth' is initialized to 0.
//   - On every positive edge of the clock signal, the output value
//     increments by 1.
//   - After reaching its maximum value (255), the 8-bit register
//     overflows and automatically wraps around to 0.
//   - This repeating count sequence (0 → 255 → 0 → ...) forms a
//     digital sawtooth waveform.
//
// Inputs :
//   clk      - System clock.
//
// Outputs :
//   sawtooth - 8-bit sawtooth waveform output.
//
//-----------------------------------------------------------------------------
module Sawtooth_Generator (
  input wire clk ,
  output reg [7:0] sawtooth = 0
  );

  // Increment the sawtooth value on every rising edge of the clock.
  // The 8-bit counter naturally rolls over from 255 to 0, producing
  // a periodic sawtooth waveform.
  always @ (posedge clk) begin
    sawtooth = sawtooth + 1;
  end

endmodule
