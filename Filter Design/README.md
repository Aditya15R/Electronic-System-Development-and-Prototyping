# FPGA Implementation of First-Order and Second-Order IIR Filters Using Verilog

## Overview

This project implements and compares **First-Order** and **Second-Order Infinite Impulse Response (IIR) Digital Filters** on an FPGA using fixed-point arithmetic.

The filters are designed in Verilog HDL and verified through behavioral simulation before FPGA deployment. The project demonstrates how recursive digital filters can be realized in hardware using delay elements, fixed-point multipliers, saturation logic, and truncation blocks.

The repository contains:

* First-Order IIR Filter
* Second-Order IIR Filter
* Supporting modules (Delay, Padding, Saturation, Truncation)
* Signal generators
* Behavioral simulation testbench

---

# Project Structure

```text
.
├── First_order_IIR_Filter.v
├── Second_Order_IIR_Filter.v
├── test_bench.v
└── README.md
```

| File                     | Description                            |
| ------------------------ | -------------------------------------- |
| IIR_Filter_First_Ordr.v  | First-order IIR filter implementation  |
| IIR_Filter_Second_Ordr.v | Second-order IIR filter implementation |
| tb.v                     | Behavioral simulation testbench        |
| README.md                | Project documentation                  |

---

# Theory

## Infinite Impulse Response (IIR) Filters

An IIR filter is a recursive digital filter whose output depends on:

* Present input sample
* Previous input samples
* Previous output samples

Unlike FIR filters, IIR filters contain feedback paths.

General form:

```text
y[n] = Σ b(k)x[n-k] + Σ a(k)y[n-k]
```

Advantages:

* Lower hardware cost
* Fewer multipliers
* Sharper frequency response
* Efficient FPGA implementation

---

# First-Order IIR Filter

## Difference Equation

```text
y[n] = b0·x[n]
     + b1·x[n−1]
     + a1·y[n−1]
```

### Coefficients

| Coefficient | Value    |
| ----------- | -------- |
| a1          | 0.997489 |
| b0          | 0.001255 |
| b1          | 0.001255 |

These coefficients implement a low-pass filter.

---

# Second-Order IIR Filter

## Difference Equation

```text
y[n] = b0·x[n]
     + b1·x[n−1]
     + b2·x[n−2]
     + a1·y[n−1]
     − a2·y[n−2]
```

### Coefficients

| Coefficient | Value    |
| ----------- | -------- |
| a1          | 1.764    |
| a2          | 0.7775   |
| b0          | 0.003495 |
| b1          | 0.00699  |
| b2          | 0.003495 |

These coefficients realize a second-order low-pass filter.

---

# Fixed-Point Representation

The filters are implemented entirely using fixed-point arithmetic.

## Why Fixed Point?

FPGA hardware does not efficiently support floating-point operations.

Fixed-point arithmetic:

* Uses fewer FPGA resources
* Consumes less power
* Provides deterministic timing
* Achieves higher operating frequencies

---

## Input Format

Input samples:

```text
Signed 10-bit
```

Range:

```text
-512 to +511
```

Equivalent format:

```text
Q1.9
```

Meaning:

* 1 Sign Bit
* 9 Fractional Bits

---

## Coefficient Format

First-order coefficients:

```text
Q1.18
```

Second-order coefficients:

```text
Q2.20
```

Higher precision is used to minimize coefficient quantization error.

---

## Output Format

Filter output:

```text
Q1.15
```

Range:

```text
-1.0 to +0.99997
```

Stored in:

```text
16-bit signed format
```

---

# Internal Filter Architecture

Each filter consists of:

## Delay Elements

Store previous samples:

```text
x[n−1]
x[n−2]
y[n−1]
y[n−2]
```

---

## Multipliers

Perform coefficient multiplication:

```text
b0*x[n]
b1*x[n−1]
b2*x[n−2]

a1*y[n−1]
a2*y[n−2]
```

---

## Padding

Multiplier outputs have different binary-point locations.

Padding aligns all operands before addition.

Example:

```verilog
{value, 6'b000000}
```

---

## Saturation

Prevents overflow.

Without saturation:

```text
32767 + 1
```

could wrap around to

```text
-32768
```

creating severe distortion.

The saturation block clips values to the maximum and minimum allowable range.

---

## Truncation

After accumulation, only the required bits are retained.

This converts:

```text
35-bit / 38-bit accumulator
```

into:

```text
16-bit output
```

for storage and transmission.

---

# Testbench Overview

The supplied testbench verifies the functionality of both filters before FPGA implementation.

The testbench generates:

## 1. Square Wave

Used to evaluate:

* Rise Time
* Settling Time
* Overshoot
* Filter Smoothing

Signal Levels:

```text
0x300
0x100
```

---

## 2. Sawtooth Wave

Generated using:

```text
0 → 1 → 2 → ... → 999 → 0
```

Used to evaluate:

* Continuous signal tracking
* Low-pass behavior
* Output smoothing

---

# Running Behavioral Simulation

## Step 1: Create a Vivado Project

Open Vivado and create a new RTL project.

---

## Step 2: Add Design Sources

Add:

```text
IIR_Filter_First_Ordr.v
IIR_Filter_Second_Ordr.v
```

and any supporting modules.

---

## Step 3: Add Simulation Source

Add:

```text
tb.v
```

as a Simulation Source.

---

## Step 4: Run Simulation

Select:

```text
Flow Navigator
    → Run Simulation
    → Run Behavioral Simulation
```

---

# Signals to Observe

In the waveform viewer, monitor:

## Input Signals

```text
squ
sw
```

---

## First-Order Filter Outputs

```text
y1sq
y1sw
```

---

## Second-Order Filter Outputs

```text
y2sq
y2sw
```

---

# Expected Results

## Square Wave Input

### First-Order Filter

Expected:

* Smooth transitions
* Slower rise time
* No sharp edges

---

### Second-Order Filter

Expected:

* Sharper filtering
* Better attenuation
* Longer settling time

---

## Sawtooth Input

### First-Order Filter

Expected:

* Rounded waveform
* Moderate smoothing

---

### Second-Order Filter

Expected:

* Stronger smoothing
* Greater attenuation of high-frequency components

---

# Comparing First and Second Order Filters

| Feature               | First Order  | Second Order |
| --------------------- | ------------ | ------------ |
| Complexity            | Low          | Moderate     |
| Delay Elements        | 1            | 2            |
| Feedback Terms        | 1            | 2            |
| Frequency Selectivity | Lower        | Higher       |
| Roll-off              | 20 dB/decade | 40 dB/decade |
| FPGA Resources        | Fewer        | More         |
| Filtering Performance | Moderate     | Better       |

---

# FPGA Implementation

After successful simulation:

1. Add FPGA constraint file (.xdc)
2. Run Synthesis
3. Run Implementation
4. Generate Bitstream
5. Program FPGA using JTAG

---

# Educational Objectives

This project demonstrates:

* FPGA-based DSP implementation
* Fixed-point arithmetic
* Recursive digital filters
* Delay elements
* Saturation arithmetic
* Quantization effects
* Hardware-efficient signal processing

---

# Future Improvements

Possible extensions include:

* Higher-order IIR filters
* Cascaded biquad sections
* Runtime coefficient updates
* FIR vs IIR comparison
* Real-time ADC/DAC signal filtering
* Audio equalizers
* FPGA-based DSP accelerators

---

# Author

Aditya Raj

Department of Electrical Engineering

Indian Institute of Technology Kharagpur
