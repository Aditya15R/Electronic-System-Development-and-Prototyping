`timescale 1ns / 1ps

//-----------------------------------------------------------------------------
// Module Name : dpwm
// Description :
//   Implements a Digital Pulse Width Modulation (DPWM) generator whose
//   duty cycle is selected using an external switch connected to the FPGA.
//
// Functionality :
//   - A 9-bit counter generates a repeating PWM period of 500 clock cycles.
//   - The input switch (sw1) determines the duty cycle of the PWM signal.
//   - Depending on the switch position, one of two duty-cycle thresholds
//     is selected.
//   - The PWM output remains HIGH while the counter value is less than
//     the selected threshold and LOW otherwise.
//
// Duty Cycle Selection :
//   sw1 = 0  --> duty_threshold = 100
//               Duty Cycle = 100/500 = 20%
//
//   sw1 = 1  --> duty_threshold = 300
//               Duty Cycle = 300/500 = 60%
//
// PWM Characteristics :
//   Counter Range : 0 to 499
//   PWM Period    : 500 clock cycles
//   Resolution    : 1/500 of the PWM period
//
// Inputs :
//   clk     - System clock.
//   sw1     - External FPGA switch used to select duty cycle.
//
// Outputs :
//   pwm_out - PWM waveform with duty cycle determined by sw1.
//
// Applications :
//   - LED brightness control
//   - Motor speed control
//   - Power electronics experiments
//   - Digital modulation and waveform generation
//-----------------------------------------------------------------------------
module dpwm (
    input clk,
    input sw1,
    output reg pwm_out
);

    // Counter used to generate the PWM time base
    reg [8:0] counter_pwm = 0;

    // Threshold value that determines the duty cycle
    reg [8:0] duty_threshold;

    // Combinational logic for selecting duty cycle
    // based on the external switch position
    always @(*) begin
        if (sw1)
            duty_threshold = 9'd300;  // 60% duty cycle
        else
            duty_threshold = 9'd100;  // 20% duty cycle
    end

    // PWM generation logic
    // Counter increments every clock cycle and resets
    // after reaching 499, creating a PWM period of 500 clocks
    always @(posedge clk) begin

        // Generate PWM time base
        if (counter_pwm < 9'd499) begin
            counter_pwm <= counter_pwm + 1;
        end
        else begin
            counter_pwm <= 0;
        end

        // Generate PWM output
        // Output remains HIGH until the counter reaches
        // the selected duty-cycle threshold
        if (counter_pwm < duty_threshold)
            pwm_out <= 1'b1;
        else
            pwm_out <= 1'b0;
    end

endmodule
