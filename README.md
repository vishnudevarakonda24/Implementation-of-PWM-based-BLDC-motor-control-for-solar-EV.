# Implementation-of-PWM-based-BLDC-motor-control-for-solar-EV.
Implemented PWM-based BLDC motor control for solar EVs, enhancing the efficiency of speed regulation. Transitioned motor control from traditional microcontrollers to FPGA with Verilog HDL for improved performance. Realized high-precision speed control and minimal latency in vehicle operation.
# Ultra-Low Latency FPGA-Based 3-Phase BLDC Motor Controller

An industrial-grade, hardware-accelerated 3-Phase Brushless DC (BLDC) motor commutation controller implemented in highly optimized, ultra-compressed Verilog HDL. 

## 🎯 Project Motivation & Purpose

Industrial automation systems, electric vehicles (EVs), and high-precision robotics require incredibly fast and reliable motor control. Traditional systems rely heavily on microcontrollers (MCUs) to decode sensor inputs and drive power inverter circuits. However, MCUs struggle with built-in speed bottlenecks:

1. **Interrupt Latency:** Processing physical Hall sensor signals through software Interrupt Service Routines (ISRs) introduces microsecond-level delays. At high operational RPMs, this lag causes late phase switching, which wastes power and heats up the motor.
2. **Software-Reliant Safety:** Relying on software routines to generate dead-time or handle overcurrent faults leaves power MOSFETs vulnerable to catastrophic short-circuits ("shoot-through") if the code freezes.

### The Solution: Hardware Acceleration
This project eliminates these limitations by migrating the entire control pipeline onto an **FPGA using Verilog HDL**. By handling the logic in dedicated hardware, execution latency drops from microseconds down to **less than 20 nanoseconds (a single clock cycle)**. This results in smooth, high-efficiency motor rotation, hardware-enforced protection, and absolute system reliability.

---

## ⚡ Architectural Comparison

| Performance Metric | Traditional MCU Architecture | FPGA Parallel Architecture (This Project) |
| :--- | :--- | :--- |
| **Commutation Response** | Microseconds (Sequential ISR Core) | **Nanoseconds (1 Clock Cycle via Wire Switching)** |
| **Dead-Time Insertion** | Shared Peripheral / Software Loops | **Dedicated Parallel Hardware Safety Counters** |
| **Overcurrent Fault Loop** | Software polling or shared analog pins | **Asynchronous Direct Hardware Circuit Override** |
| **System Reliability** | Susceptible to core freezes/lockups | **Deterministic Hardware Execution Path** |

---

## 🛠️ Key Technical Features

* **Deterministic 6-Step Commutation State Machine:** An ultra-fast, combinational lookup logic block that decodes rotor positions instantly from 3-phase Hall effect sensors.
* **Dynamic PWM High-Side Chopping:** Integrated an 8-bit digital free-running comparator loop to regulate motor velocity without wasting CPU processing cycles.
* **Cross-Conduction Protection (Dead-Time Insertion):** Built-in parallel hardware safety counters. They track the active gate pins to guarantee that the high-side and low-side transistors on an inverter bridge leg never turn on simultaneously, eliminating shoot-through short circuits.
* **Instant Asynchronous Fault Handling:** A hardwired emergency line that immediately bypasses the state machine logic during a fault. It drops all gate outputs to zero within a single clock cycle (<20ns) to protect physical power components.

---

## 📂 Core Source Files

* `rtl/bldc_controller.v`: Ultra-compressed, high-density synthesizable logic featuring parallel leg arrays and custom dead-time mapping.
* `testbench/tb_bldc_controller.v`: Comprehensive simulation script modeling variable motor speeds and unexpected overcurrent faults.

https://github.com/user-attachments/assets/f08fe364-3fe8-43c7-973f-6c790652f4e3



https://github.com/user-attachments/assets/6a21e2fd-1895-4e67-b85b-c34cd12c0b23



https://github.com/user-attachments/assets/3ce414ba-d336-45f5-a7a0-175c8b4e2937

<img width="1600" height="1201" alt="WhatsApp Image 2026-06-15 at 23 01 55" src="https://github.com/user-attachments/assets/0a8befee-5caf-4857-afb2-073a56ad7ad9" />
<img width="1600" height="1201" alt="WhatsApp Image 2026-06-15 at 23 01 54" src="https://github.com/user-attachments/assets/fabdbb13-361b-4c1f-8353-afd1a512766d" />
<img width="720" height="1280" alt="WhatsApp Image 2026-06-15 at 23 00 15" src="https://github.com/user-attachments/assets/f3391d47-bc25-4a70-86bd-0eaa420ed08b" />
