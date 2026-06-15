# Implementation-of-PWM-based-BLDC-motor-control-for-solar-EV.
Implemented PWM-based BLDC motor control for solar EVs, enhancing the efficiency of speed regulation. Transitioned motor control from traditional microcontrollers to FPGA with Verilog HDL for improved performance. Realized high-precision speed control and minimal latency in vehicle operation.
# FPGA-Based Ultra-Low Latency BLDC Motor Controller

An industrial-grade, hardware-accelerated 3-Phase Brushless DC (BLDC) motor commutation controller implemented in Verilog HDL. This design replaces sequential microcontroller architectures to achieve nanosecond-level execution and zero-latency hardware feedback processing.
<img width="501" height="633" alt="image" src="https://github.com/user-attachments/assets/31a09439-89a6-4413-b8ea-66db8827e3d4" />



## ⚡ Architecture Comparison

| Feature | Traditional MCU Control | FPGA Verilog Implementation (This Project) |
| :--- | :--- | :--- |
| **Commutation Delay** | Microseconds (ISR latency, core overhead) | **Single clock cycle (20 nanoseconds)** |
| **Dead-Time Insertion**| Software loops or shared internal timers | **Dedicated, parallel hardware counters** |
| **Execution** | Sequential (one instruction at a time) | **Fully concurrent parallel logic execution** |

## 🛠️ Features
- **Parallel Hardware FSM:** Instantly decodes 3-phase Hall effect sensor inputs.
- **Parametric Dead-Time Safety Blocks:** Hardware protection circuit guarding against shoot-through short-circuits on the inverter bridge legs.
- **Highly Portable:** Fully synthesizable RTL ready for deployment on Xilinx, Intel, or Lattice FPGAs.

## 📂 Repository Structure
```text
├── rtl/
│   └── bldc_controller.v     # Core Synthesizable Commutation & Dead-time Module
├── testbench/
│   └── tb_bldc_controller.v  # Full System Testbench Simulation file
├── docs/
│   └── architecture_diag.png # Circuit Topology Map
└── README.md                 # Project Documentation

## 📈 Simulation and Verification
The design includes a complete testbench suite simulating a full 6-step commutation cycle. Waveform simulation tracking outputs can be viewed using any standard VCD viewer (such as GTKWave or ModelSim).
- **Hardware PWM Chopping Regulation:** Synchronous 8-bit dynamic voltage-speed control applied on high-side power switches.
- **Asynchronous Safe Fault Trip Loop:** Hardware line mapping bypasses processing to clear all gate outputs instantly (<20ns) during overcurrent.

