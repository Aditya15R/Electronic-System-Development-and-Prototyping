`timescale 1ns / 1ps

//=============================================================================
// FPGA-BASED CLOSED-LOOP VOLTAGE MODE CONTROL OF BUCK CONVERTER
//
// DESCRIPTION:
//
// This design implements a Digital PID Controller for closed-loop voltage
// regulation of a Buck Converter using FPGA hardware.
//
// The controller continuously measures the converter output voltage through
// the ADC, compares it with a desired reference voltage, and adjusts the PWM
// duty cycle accordingly.
//
// Unlike the open-loop controller where the duty cycle remains fixed, this
// design dynamically changes the duty cycle to force the converter output
// voltage to track the reference signal.
//
// CONTROL LOOP:
//
//          Vref
//            │
//            ▼
//      Error Computation
//            │
//            ▼
//      Digital PID Controller
//            │
//            ▼
//        PWM Generator
//            │
//            ▼
//       Buck Converter
//            │
//            ▼
//           ADC
//            │
//            └───────────────┘
//
// The objective of this experiment is to demonstrate:
//
//      • Closed-loop voltage regulation
//      • Reference tracking
//      • Digital PID implementation
//      • FPGA-based digital control
//      • IIR filter realization of controllers
//      • Dynamic duty-cycle adjustment
//
//=============================================================================



//=============================================================================
// CLOCK GENERATION MODULE
//
// DESCRIPTION:
//
// Generates two clock signals:
//
//      adc_clk
//          Used by ADC sampling circuitry.
//
//      sw_clk
//          Used by the digital controller.
//
// The controller is intentionally updated at a slower rate than the FPGA
// master clock.
//
// This mimics practical digital control systems where:
//
//      Sampling Frequency << FPGA Clock Frequency
//
//=============================================================================

module clk_gen(
    input clk,
    output adc_clk,
    output sw_clk
);

    reg [1:0] count1 = 0;
    reg [9:0] count2 = 0;

    reg div_clk1 = 0;
    reg div_clk2 = 0;

    always @(posedge clk)
    begin

        // ADC Clock Divider
        
        if(count1 == 3)
            count1 <= 0;
        else
            count1 <= count1 + 1;

        if(count1 <= 1)
            div_clk1 <= 1;
        else
            div_clk1 <= 0;

        // Controller Clock Divider
        
        if(count2 == 499)
            count2 <= 0;
        else
            count2 <= count2 + 1;

        if(count2 <= 249)
            div_clk2 <= 1;
        else
            div_clk2 <= 0;

    end

    assign sw_clk  = div_clk2;
    assign adc_clk = div_clk1;

endmodule


//=============================================================================
// REFERENCE SIGNAL GENERATOR
//
// DESCRIPTION:
//
// Generates a square-wave reference voltage.
//
// The buck converter output is expected to follow this reference.
//
// Reference Levels:
//
//      V1 = 0.2 pu
//      V2 = 0.3 pu
//
// The controller should continuously regulate the output voltage and
// force it to transition between these two levels.
//
// This allows evaluation of:
//
//      • Rise Time
//      • Settling Time
//      • Steady-State Error
//      • Overshoot
//      • Controller Stability
//
//=============================================================================

module v_ref(
    input clk,
    output signed [9:0] v_ref
);

    // Reference Voltage Levels
    
    parameter V1 = 10'sb0001011000; // 0.2
    parameter V2 = 10'sb0010000111; // 0.3

    reg V_clk = 0;
    reg [22:0] count = 0;

    always @(posedge clk)
    begin
        count <= count + 1;
        // Periodically toggle reference level
        if(count == 499999)
        begin
            V_clk <= ~V_clk;
            count <= 0;
        end
    end

    // Square Wave Reference
    
    assign v_ref = V_clk ? V1 : V2;
endmodule


//=============================================================================
// DIGITAL PID CONTROLLER
//
// DESCRIPTION:
//
// Implements:
//
//      u[n] = Kp·e[n]
//           + Ki∫e[n]
//           + Kd(de[n]/dt)
//
// where:
//
//      e[n] = Vref - Vout
//
// The controller output determines the PWM duty cycle.
//
// This module can also be interpreted as a discrete-time recursive filter,
// making it closely related to IIR filter implementations.
//
//=============================================================================

module PID(
    input sw_clk,
    input signed [9:0] error,
    output signed [11:0] v_control
);

    // PID Gains
    
    parameter Kpd = 21'sb0001_10100101111101110; // Kp = 1.64
    parameter Kid = 21'sb0000_00100001001001010; // Ki = 0.12
    parameter Kdd = 21'sb0100_11100011001101101; // Kd = 4.88

    // Controller Output Limits
    // Prevents duty-cycle overflow.
    
    parameter MAX = 31'sb00000_00111101110000000000000000;
    parameter MIN = 31'sb00000_00000000101000000000000000;

    // Integral Anti-Windup Limits
    // Prevents uncontrolled growth of integral term.
    
    parameter MAX_int = 31'sb00000_11111111110000000000000000;
    parameter MIN_int = 31'sb11111_00000000000000000000000000;

    // Internal Variables
    
    wire signed [30:0] vp;
    wire signed [30:0] vi;
    wire signed [30:0] vd;

    wire signed [30:0] vi_t;

    wire signed [30:0] vc_temp;

    wire signed [30:0] v_con;

    // Previous Error Samples
    // Required for derivative action.
    
    reg signed [9:0] error1 = 0;
    reg signed [9:0] error2 = 0;

    // Integral Memory
    
    reg signed [30:0] vi_1 = 0;

    // Proportional Term
    // Responds to present error.
    
    assign vp = Kpd * error1;

    // Integral Term
    // Eliminates steady-state error.
    
    assign vi_t = Kid * error1 + vi_1;

    assign vi = (vi_t > MAX) ? MAX : (vi_t < MIN) ? MIN : vi_t;

    // Derivative Term
    // Predicts future error.
    // Improves damping and transient response.

    assign vd = (error1 - error2) * Kdd;

    // PID Summation
    
    assign vc_temp = vp + vi + vd;

    // Controller State Update
    
    always @(posedge sw_clk)
    begin
        error1 <= error;
        error2 <= error1;
        vi_1 <= vi;
    end

    // Output Saturation
  
    assign v_con = (vc_temp > MAX) ? MAX : (vc_temp < MIN) ? MIN : vc_temp;

    // Fixed-Point Conversion
    // Extract useful bits for PWM generation.
    
    assign v_control[11] = v_con[30];

    assign v_control[10:0] = v_con[25:15];

endmodule


//=============================================================================
// PWM GENERATOR
//
// DESCRIPTION:
//
// Converts controller output into PWM duty cycle.
//
// Higher control output:
//
//      → Higher duty cycle
//      → Higher converter output voltage
//
// Lower control output:
//
//      → Lower duty cycle
//      → Lower converter output voltage
//
// Thus the PID controller regulates converter output indirectly by
// modifying PWM duty ratio.
//
//=============================================================================

module PWM(
    input clk,
    input signed [11:0] v_control,
    output pwm
);

    reg signed [11:0] count = 0;
    reg duty = 0;

    always @(posedge clk)
    begin
        // PWM Counter
        if(count == 499)
            count <= 0;
        else
            count <= count + 1;

        // Duty Cycle Comparison
        if(count < v_control)
            duty <= 1;
        else
            duty <= 0;
    end

    assign pwm = duty;
endmodule


//=============================================================================
// TOP MODULE : Buck_PID
//
// DESCRIPTION:
//
// Top-level module implementing closed-loop voltage mode control
// of a buck converter.
//
// CONTROL ALGORITHM:
//      1. ADC measures converter output voltage
//      2. Reference generator creates square-wave reference
//      3. Error computed:Error = Vref − Vout
//      4. PID controller processes error
//      5. Controller output determines PWM duty cycle
//      6. Buck converter output changes
//      7. Loop repeats continuously
//
// EXPECTED RESULT:
// The converter output voltage should follow the square-wave reference
// signal with minimal:
//      • Steady-state error
//      • Overshoot
//      • Settling time
//
// This demonstrates successful digital closed-loop control.
//
//=============================================================================

module Buck_PID(
    input clk,
    input signed [9:0] adc_data,
    output clk_adc,
    output pwm,
    output FCCM,
    output EN
);

    // Power Stage Enable Signals
    assign FCCM = 1;
    assign EN = 1;

    // Error Signal
    wire signed [9:0] error;

    // Reference Signal
    wire signed [9:0] Vref;

    // Controller Clock
    wire sw_clk;

    clk_gen c(
        clk,
        clk_adc,
        sw_clk
    );

    // Reference Generator
    
    v_ref vr(
        clk,
        Vref
    );

    // Error Computation
    assign error = Vref - adc_data;

    // PID Controller
    wire signed [11:0] v_control;

    PID p(
        sw_clk,
        error,
        v_control
    );

    // PWM Generator
    
    PWM d(
        clk,
        v_control,
        pwm
    );

endmodule
