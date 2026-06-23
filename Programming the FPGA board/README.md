# Digital PWM Generator on FPGA using Verilog

## Overview

This project implements a **Digital Pulse Width Modulation (DPWM) Generator** on an FPGA using Verilog HDL. The duty cycle of the generated PWM waveform can be changed in real-time using an external switch available on the FPGA development board.

The design uses:

* A 100 MHz onboard clock
* A 9-bit PWM counter
* User-controlled duty cycle selection through a switch
* FPGA pin mapping through an XDC constraint file

---

## Folder Files

| File                | Description                                        |
| ------------------- | -------------------------------------------------- |
| `dpwm_assignment.v` | Verilog source code implementing the PWM generator |
| `constraints.xdc`   | FPGA pin assignments and timing constraints        |
| `README.md`         | Project documentation                              |

---

## PWM Operation

The PWM period is generated using a 9-bit counter that counts from **0 to 499**.

### Duty Cycle Selection

| Switch (`sw1`) | Threshold | Duty Cycle |
| -------------- | --------- | ---------- |
| 0              | 100       | 20%        |
| 1              | 300       | 60%        |

The output remains HIGH while:

```text
counter_pwm < duty_threshold
```

and LOW for the remainder of the PWM period.

---

## Hardware Connections

### Clock Input

| Signal | FPGA Pin |
| ------ | -------- |
| clk    | G4       |

Clock Frequency:

```text
100 MHz
```

---

### Switch Input

| Signal | FPGA Pin |
| ------ | -------- |
| sw1    | M1       |

Used to select PWM duty cycle.

---

### PWM Output

| Signal  | FPGA Pin |
| ------- | -------- |
| pwm_out | C1       |

This pin can be connected to:

* Oscilloscope
* Logic Analyzer
* DAC Interface
* External PWM-compatible circuits

---

# Vivado Workflow

## Step 1: Create a New Project

1. Open Xilinx Vivado.
2. Click **Create Project**.
3. Enter a project name.
4. Select **RTL Project**.
5. Click **Next**.

---

## Step 2: Add Verilog Source

1. Click **Add Sources**.
2. Select:

```text
pwm.v
```

3. Click **Finish**.

---

## Step 3: Add Constraint File

1. In Sources Window:

```text
Add Sources → Add Constraints
```

2. Select:

```text
constraints.xdc
```

3. Finish the wizard.

---

## Step 4: Select FPGA Device

Choose the FPGA device corresponding to your development board.

Example:

```text
Artix-7
Spartan-7
Kintex-7
```

depending on the board being used.

---

## Step 5: Run Synthesis

From the Flow Navigator:

```text
Run Synthesis
```

Vivado will:

* Parse Verilog code
* Check syntax
* Create RTL netlist

After completion:

```text
Open Synthesized Design
```

(optional)

---

## Step 6: Run Implementation

From Flow Navigator:

```text
Run Implementation
```

Vivado will perform:

* Optimization
* Placement
* Routing

After completion:

```text
Open Implemented Design
```

(optional)

---

## Step 7: Generate Bitstream

After successful implementation:

```text
Generate Bitstream
```

Vivado creates:

```text
project_name.runs/impl_1/*.bit
```

This `.bit` file contains the FPGA configuration data.

---

# Programming the FPGA Using JTAG

## Step 1: Connect Hardware

Connect:

* FPGA board
* USB-JTAG cable (or onboard USB programmer)

Power ON the board.

---

## Step 2: Open Hardware Manager

In Vivado:

```text
Flow Navigator → Open Hardware Manager
```

Click:

```text
Open Target
```

then:

```text
Auto Connect
```

Vivado should detect the FPGA device.

---

## Step 3: Program Device

Right-click the FPGA device.

Select:

```text
Program Device
```

Browse to:

```text
your_project.runs/impl_1/design.bit
```

Click:

```text
Program
```

---

## Step 4: Verify Operation

Observe the PWM signal on the output pin.

### Switch Position

#### SW1 = 0

Expected PWM:

```text
20% Duty Cycle
```

---

#### SW1 = 1

Expected PWM:

```text
60% Duty Cycle
```

---

Use an oscilloscope to verify:

```text
Duty Cycle
Frequency
Pulse Width
```

---

# Expected Results

| Switch Position | Duty Cycle |
| --------------- | ---------- |
| SW1 = 0         | 20%        |
| SW1 = 1         | 60%        |

The duty cycle should change immediately when the switch state changes.

---

# Applications

* LED Brightness Control
* Motor Speed Control
* Power Electronics
* DC-DC Converters
* FPGA-based Digital Control Systems
* Signal Generation Experiments

---

# Author

Aditya Raj
Department of Electrical Engineering
Indian Institute of Technology Kharagpur
