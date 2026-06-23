# FPGA-Based Voltage Mode Control of Buck Converter using Digital PID Controller

## Overview

This project implements a **Digital Closed-Loop Voltage Mode Controller** for a DC-DC Buck Converter using an FPGA. The controller is realized entirely in Verilog HDL and uses a **Digital PID (Proportional-Integral-Derivative) Controller** to regulate the converter output voltage.

The converter output voltage is continuously measured using an ADC and compared against a reference voltage. The resulting error signal is processed by the digital PID controller, which dynamically adjusts the PWM duty cycle to force the output voltage to track the desired reference.

Unlike an open-loop converter where the duty cycle remains fixed, this design automatically compensates for disturbances, load changes, and input voltage variations.

---

# Project Objectives

The purpose of this project is to:

* Implement a digital voltage-mode controller on FPGA.
* Regulate buck converter output voltage using feedback.
* Demonstrate closed-loop control principles.
* Implement PID control using fixed-point arithmetic.
* Realize the controller using recursive filter (IIR) techniques.
* Validate controller performance experimentally.
* Study transient and steady-state response.
* Compare digital control with traditional analog controllers.

---

# Folder Structure

```text
.
├── Buck_PID.v
├── constraints.xdc
├── README.md
```

| File            | Description                                    |
| --------------- | ---------------------------------------------- |
| Buck_PID.v      | Complete digital PID controller implementation |
| constraints.xdc | FPGA pin assignments                           |
| README.md       | Project documentation                          |

---

# System Architecture

```text
                Reference Voltage
                       │
                       ▼
                 Error Generator
                       │
                       ▼
                Digital PID
                       │
                       ▼
                PWM Generator
                       │
                       ▼
                Buck Converter
                       │
                       ▼
                     ADC
                       │
                       └───────────── Feedback
```

The control loop continuously updates the PWM duty cycle based on the measured output voltage.

---

# Voltage Mode Control

In Voltage Mode Control:

```text
Error = Vref − Vout
```

where:

* Vref = Desired Output Voltage
* Vout = Measured Output Voltage

The controller attempts to minimize this error by adjusting the converter duty cycle.

---

# Why Use a PID Controller?

A PID controller combines three control actions:

```text
u(t) = Kp·e(t)
     + Ki∫e(t)dt
     + Kd(de(t)/dt)
```

where:

| Term             | Purpose                                 |
| ---------------- | --------------------------------------- |
| Proportional (P) | Responds to present error               |
| Integral (I)     | Eliminates steady-state error           |
| Derivative (D)   | Improves damping and transient response |

The combination provides:

* Fast response
* Good stability
* Small steady-state error
* Reduced overshoot

---

# Digital PID as an IIR Filter

One of the most important aspects of this project is that the PID controller is implemented using concepts similar to an **Infinite Impulse Response (IIR) Filter**.

## Why?

A digital controller is fundamentally a discrete-time system.

The controller output depends not only on the current error but also on previous errors and previous controller states.

For example:

```text
u[n] = f(
          e[n],
          e[n−1],
          e[n−2],
          u[n−1]
        )
```

This recursive behavior is identical to the operation of an IIR filter.

---

## IIR Filter Representation

A first-order IIR filter can be written as:

```text
y[n] = b0x[n] + b1x[n−1] + a1y[n−1]
```

Similarly, the PID controller stores:

```text
Previous Error
Previous Error Difference
Previous Integral State
```

and recursively computes:

```text
Control Output
```

Thus the controller effectively behaves as a recursive digital filter.

---

# PID Controller Implementation

The implemented controller consists of:

## Proportional Term

```text
Vp = Kp × Error
```

Provides immediate corrective action.

---

## Integral Term

```text
Vi = Vi_previous + Ki × Error
```

Accumulates error over time.

Eliminates steady-state offset.

---

## Derivative Term

```text
Vd = Kd × (Error[n] − Error[n−1])
```

Predicts future error trend.

Improves transient performance.

---

## Controller Output

```text
Vcontrol = Vp + Vi + Vd
```

This output determines the PWM duty cycle.

---

# Fixed Point Arithmetic

Since FPGA hardware does not efficiently support floating-point operations, all controller coefficients are represented using fixed-point formats.

Example:

```verilog
Kpd = 1.64
Kid = 0.12
Kdd = 4.88
```

are stored as binary fixed-point constants.

Benefits:

* Faster hardware implementation
* Lower resource utilization
* Deterministic timing
* Easier FPGA synthesis

---

# Anti-Windup Protection

Integral accumulation can grow indefinitely during large disturbances.

To prevent this:

```verilog
MAX_int
MIN_int
```

are used to limit the integral state.

This technique is called:

```text
Integral Anti-Windup
```

and improves controller recovery after saturation.

---

# Output Saturation

The controller output is also limited:

```verilog
MAX
MIN
```

This prevents:

* Invalid duty cycles
* Overflow
* Hardware instability

---

# PWM Generation

The controller output is converted into a PWM waveform.

## Principle

```text
Counter < Vcontrol
```

→ PWM = HIGH

```text
Counter ≥ Vcontrol
```

→ PWM = LOW

The duty cycle automatically changes according to controller output.

---

# Reference Signal

A square-wave reference is intentionally generated:

```text
0.2 pu ↔ 0.3 pu
```

The buck converter output should follow these transitions.

This allows measurement of:

* Rise Time
* Settling Time
* Overshoot
* Steady-State Error
* Tracking Accuracy

---

# Designing PID Gains using MATLAB PID Tuner

The controller gains are not fixed and can be redesigned for any converter.

---

## Step 1: Obtain Converter Model

Develop a transfer function model of the buck converter:

```text
G(s) = Vout(s) / Duty(s)
```

using:

* State-space modeling
* Small-signal averaging
* MATLAB Simulink
* Control System Toolbox

---

## Step 2: Open PID Tuner

In MATLAB:

```matlab
pidTuner(G,'PID')
```

or

```matlab
pidTuner(tf_model)
```

---

## Step 3: Specify Requirements

Tune according to desired:

* Rise Time
* Settling Time
* Overshoot
* Phase Margin
* Bandwidth
* Robustness

---

## Step 4: Export Gains

MATLAB generates:

```text
Kp
Ki
Kd
```

---

## Step 5: Convert to Fixed Point

Convert floating-point gains into FPGA fixed-point format.

Example:

```text
Kp = 1.64
Ki = 0.12
Kd = 4.88
```

↓

```verilog
21'b...
```

---

## Step 6: Update Verilog Parameters

Replace:

```verilog
parameter Kpd = ...
parameter Kid = ...
parameter Kdd = ...
```

with new values.

Recompile and program FPGA.

---

# Vivado Workflow

## Create Project

Create a new RTL project.

---

## Add Sources

Add:

```text
Buck_PID.v
```

---

## Add Constraints

Add:

```text
constraints.xdc
```

---

## Run Synthesis

```text
Flow Navigator
 → Run Synthesis
```

---

## Run Implementation

```text
Flow Navigator
 → Run Implementation
```

---

## Generate Bitstream

```text
Flow Navigator
 → Generate Bitstream
```

---

# FPGA Programming

Connect:

* FPGA Board
* Buck Converter Board
* USB JTAG Cable

Open:

```text
Hardware Manager
```

Then:

```text
Open Target
 → Auto Connect
```

Select:

```text
Program Device
```

Load:

```text
project.bit
```

and program the FPGA.

---

# Experimental Verification

## Oscilloscope Measurements

Observe:

### Channel 1

Reference Voltage

### Channel 2

Buck Converter Output Voltage

---

## Expected Result

The converter output should follow the reference square wave.

Example:

```text
Reference

0.3 ────────┐      ┌────────
            │      │
0.2 ────────└──────┘────────
```

Output:

```text
           /───────\
          /
_________/
```

with:

* Small overshoot
* Fast settling
* Minimal steady-state error

---

# Performance Metrics

Evaluate:

| Metric             | Description          |
| ------------------ | -------------------- |
| Rise Time          | Speed of response    |
| Settling Time      | Time to stabilize    |
| Overshoot          | Peak above reference |
| Steady-State Error | Final tracking error |
| Phase Margin       | Stability margin     |
| Bandwidth          | Control speed        |

---

# Applications

This architecture can be extended to:

* DC-DC Buck Converters
* Boost Converters
* Buck-Boost Converters
* Battery Chargers
* Motor Drives
* Renewable Energy Systems
* Digital Power Supplies
* FPGA-Based Power Electronics Controllers

---

# Future Improvements

Possible future work includes:

* PI Controller Implementation
* Adaptive PID Control
* Gain Scheduling
* Current Mode Control
* Cascaded Voltage/Current Loops
* State-Space Control
* Model Predictive Control (MPC)
* FPGA DSP Slice Optimization

---

# Conclusion

This project demonstrates the complete implementation of a Digital Voltage Mode Controller for a Buck Converter using FPGA hardware. The controller uses a PID algorithm realized through recursive IIR-filter-like structures and fixed-point arithmetic, making it suitable for real-time digital control applications. Controller gains can be designed and tuned using MATLAB PID Tuner, converted into fixed-point representations, and directly deployed onto FPGA hardware. The design serves as a practical foundation for advanced digital power electronics and embedded control systems.

---

# Author

Aditya Raj

Department of Electrical Engineering

Indian Institute of Technology Kharagpur
