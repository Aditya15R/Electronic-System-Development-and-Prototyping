# FPGA-Based Open Loop Buck Converter Controller

## Overview

This project implements an **Open-Loop Digital Controller for a DC-DC Buck Converter** using Verilog HDL on an FPGA platform.

The controller generates a fixed-duty-cycle PWM signal that drives the switching MOSFET of the buck converter. Since the system operates in **open loop**, no feedback regulation is used. The output voltage depends entirely on the applied PWM duty cycle and the converter input voltage.

The project also includes:

* PWM generation logic
* ADC/DAC interfacing
* Clock generation for peripheral devices
* Real-time monitoring of converter signals through DAC outputs

This design is typically used as the first stage of power electronics controller development before implementing closed-loop voltage or current regulation.

---

# Folder Structure

```text
.
├── open_loop.v
├── open_loop_constraints.xdc
└── README.md
```

| File            | Description                    |
| --------------- | ------------------------------ |
| buck.v          | Main Open Loop Buck Controller |
| constraints.xdc | FPGA pin assignments           |
| README.md       | Project documentation          |

---

# Open Loop Buck Converter Theory

## What is a Buck Converter?

A Buck Converter is a DC-DC power converter that reduces a higher DC voltage to a lower DC voltage.

Example:

```text
Input Voltage  = 12V
Output Voltage = 5V
```

The converter consists of:

* MOSFET switch
* Diode / synchronous switch
* Inductor
* Output capacitor
* Load

---

## Principle of Operation

The output voltage of an ideal buck converter is:

```text
Vout = D × Vin
```

where:

* Vout = Output Voltage
* Vin = Input Voltage
* D = PWM Duty Cycle

Example:

```text
Vin = 12V
Duty Cycle = 20%

Vout = 0.20 × 12
     = 2.4V
```

---

# Open Loop Control

In this project:

```text
Duty Cycle = Fixed
```

There is:

* No voltage feedback
* No current feedback
* No PID controller
* No compensation network

Therefore:

```text
PWM → Buck Converter → Output Voltage
```

The FPGA only generates the PWM waveform.

---

# Objectives of the Experiment

This design is intended to:

* Verify PWM generation
* Drive the buck converter MOSFET
* Observe converter startup behavior
* Measure output voltage
* Validate theoretical duty-cycle relationships
* Establish a baseline for future closed-loop control

---

# System Architecture

```text
                FPGA
                  │
                  │
          ┌───────▼────────┐
          │ PWM Generator  │
          └───────┬────────┘
                  │
                  ▼
           Buck Converter
                  │
                  ▼
          Output Voltage
                  │
        ┌─────────┴─────────┐
        ▼                   ▼
      ADC1                ADC2
        │                   │
        ▼                   ▼
      DAC3                DAC2
        │                   │
        ▼                   ▼
   Oscilloscope       Oscilloscope
```

---

# PWM Generation

The module `PWM20` generates the switching signal.

## Counter Configuration

```verilog
counter = 0 → 1999
```

Total counts:

```text
2000 counts
```

PWM HIGH duration:

```text
0 → 399
```

High counts:

```text
400 counts
```

Therefore:

```text
Duty Cycle = 400 / 2000
           = 20%
```

---

# ADC and DAC Interface

The controller continuously monitors external analog signals using ADC channels.

## ADC Format

The ADC outputs data in:

```text
10-bit Two's Complement
```

Format:

```text
[ Sign | Data ]
```

Range:

```text
-512 to +511
```

---

## DAC Format

The DAC accepts:

```text
12-bit Offset Binary
```

Range:

```text
0 to 4095
```

Mid-scale:

```text
2048
```

---

# ADC to DAC Conversion

To visualize ADC signals on an oscilloscope:

```verilog
{~adc[9], adc[8:0], 2'b00}
```

is used.

The conversion:

1. Inverts the sign bit
2. Preserves magnitude bits
3. Appends two zeros

This converts:

```text
10-bit Two's Complement
```

into

```text
12-bit Offset Binary
```

for DAC output.

---

# Clock Generation

The module `clocksource` generates clocks for:

```text
ADC1
ADC2
DAC2
DAC3
```

All devices share a common divided clock.

This ensures:

* Synchronized sampling
* Stable DAC updates
* Reliable ADC acquisition

---

# Hardware Connections

## FPGA Connections

Connect:

| FPGA Signal | Hardware Connection         |
| ----------- | --------------------------- |
| PWM         | Gate Driver Input           |
| EN          | Enable Pin                  |
| FCCM        | FCCM Pin                    |
| ADC1        | Output Voltage Sense        |
| ADC2        | Current Sense / Test Signal |
| DAC3        | Oscilloscope CH1            |
| DAC2        | Oscilloscope CH2            |

---

# Vivado Workflow

## Step 1: Create Project

Open Vivado and create a new RTL project.

---

## Step 2: Add Source File

Add:

```text
buck.v
```

under Design Sources.

---

## Step 3: Add Constraint File

Add:

```text
constraints.xdc
```

under Constraints.

---

## Step 4: Run Synthesis

```text
Flow Navigator
    → Run Synthesis
```

Wait until synthesis completes successfully.

---

## Step 5: Run Implementation

```text
Flow Navigator
    → Run Implementation
```

Verify timing closure.

---

## Step 6: Generate Bitstream

```text
Flow Navigator
    → Generate Bitstream
```

Vivado generates:

```text
project_name.bit
```

---

# Programming the FPGA

## Connect Hardware

* Power ON FPGA board
* Connect USB-JTAG cable
* Connect buck converter board

---

## Open Hardware Manager

```text
Vivado
    → Open Hardware Manager
```

---

## Connect to Target

```text
Open Target
    → Auto Connect
```

Vivado should detect the FPGA device.

---

## Program Device

```text
Program Device
    → Select .bit File
    → Program
```

After programming:

```text
PWM signal starts immediately
```

---

# Experimental Procedure

## Step 1

Apply DC input voltage to the buck converter.

Example:

```text
Vin = 12V
```

---

## Step 2

Program FPGA.

---

## Step 3

Observe PWM waveform on oscilloscope.

Verify:

```text
Duty Cycle ≈ 20%
```

---

## Step 4

Measure converter output voltage.

Expected:

```text
Vout ≈ D × Vin
```

Example:

```text
Vout ≈ 2.4V
```

---

## Step 5

Observe DAC outputs.

DAC outputs reproduce ADC measurements and allow monitoring of:

* Output voltage
* Inductor current
* Other sensed signals

---

# Expected Results

For an ideal converter:

```text
Vout = D × Vin
```

With:

```text
D = 20%
Vin = 12V
```

Expected:

```text
Vout ≈ 2.4V
```

Practical measurements may differ due to:

* MOSFET losses
* Diode losses
* Inductor resistance
* Capacitor ESR
* Load current
* Switching dead time

---

# Conclusions

This experiment demonstrates:

* FPGA-based PWM generation
* Open-loop buck converter operation
* ADC/DAC interfacing
* Real-time signal monitoring
* Verification of duty-cycle versus output-voltage relationship

The design serves as the foundation for future development of:

* Closed-loop voltage control
* Current-mode control
* PI/PID controllers
* Digital power electronics systems

---

# Future Work

Possible extensions:

* Variable duty-cycle control
* Closed-loop voltage regulation
* PI controller implementation
* PID controller implementation
* Current control loop
* Soft-start functionality
* Over-current protection
* Over-voltage protection
* FPGA-based digital power supply

---

# Author

Aditya Raj

Department of Electrical Engineering

Indian Institute of Technology Kharagpur
