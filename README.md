# Parameterized Cycle-Accurate UART Core (SystemVerilog)

[![Language](https://img.shields.io/badge/Language-SystemVerilog-blue.svg)](https://en.wikipedia.org/wiki/SystemVerilog)
[![Lint](https://img.shields.io/badge/Questa_Lint-STARC_Clean-brightgreen.svg)]()
[![Verification](https://img.shields.io/badge/Simulation-Self--Checking_TB-brightgreen.svg)]()
[![Synthesis](https://img.shields.io/badge/FPGA-Synthesizable-orange.svg)]()

A modular, fully parameterized, and cycle-accurate **UART (Universal Asynchronous Receiver/Transmitter) IP Core** implemented in synthesizable SystemVerilog. The architecture features independent transmitter (`uart_tx`) and receiver (`uart_rx`) modules, modular datapath partitioning, deterministic FSM control, dynamic parity calculation/checking, error detection, and compliance with **STARC** coding guidelines via static lint analysis.

---

## 📑 Table of Contents

* [Architecture & Key Features](#-architecture--key-features)
* [Repository Structure](#-repository-structure)
* [Protocol & Frame Sequence](#-protocol--frame-sequence)
* [Module Descriptions](#-module-descriptions)
* [Linting & Code Quality](#-linting--code-quality)
* [Verification & Simulation](#-verification--simulation)
* [Synthesis & Resource Utilization](#-synthesis--resource-utilization)
* [How to Run Simulation](#-how-to-run-simulation)
* [Documentation](#-documentation)

---

## 🚀 Architecture & Key Features

* **Cycle-Accurate Timing**: Each bit period spans exactly one system clock cycle (fully synchronous core design).
* **Parameterized Datapath**: Configurable payload width via `DATA_W` (default is 8 bits).
* **Dynamic Parity Support**: Runtime-configurable parity enable (`i_par_en`) and odd/even mode selection (`i_par_odd`).
* **Comprehensive Error Detection**:
>       Parity error detection (`o_parity_err`).
>       Framing error detection (`o_frame_err`) checking for valid stop bit assertion.


* **Robust FSM Control**: Moore state machines isolating datapath registers, rejecting overlapping writes during transmission (`o_busy`), and delivering data via a single-cycle pulse ("flag-and-deliver").
* **Production-Grade Code Quality**: Verified with Siemens Questa Lint against STARC guidelines with **zero syntax errors and zero inferred latches**.

---

## 📁 Repository Structure

```text
├── RTL/
│   ├── RX/
│   │   ├── Deserializer.sv      # SIPO shift register with bit counter
│   │   ├── FSM_RX.sv            # Receiver Moore FSM controller
│   │   ├── Parity_Checker.sv    # Combinational XOR reduction parity checker
│   │   └── uart_rx.sv           # Receiver top wrapper
│   └── TX/
│       ├── FSM_TX.sv            # Transmitter Moore FSM controller
│       ├── MUX.sv               # 4-to-1 serial line output multiplexer
│       ├── Parity_Calculator.sv # Dynamic parity calculation & latch
│       ├── Serializer.sv        # PISO shift register with bit counter
│       └── uart_tx.sv           # Transmitter top wrapper
├── Scripts/
│   ├── run_RX_TX.do             # QuestaSim automation DO-script for loopback TB
│   └── run_TX.do                # QuestaSim automation DO-script for TX TB
├── Testbench/
│   ├── uart_loopback_tb.sv      # Full-duplex self-checking loopback testbench
│   └── uart_tx_tb.sv            # Transmitter verification testbench
├── .gitignore
├── LICENSE
├── README.md
└── UART_Report.pdf              # Comprehensive design, lint & synthesis report

```

---

## ⏱ Protocol & Frame Sequence

The UART frame consists of:

1. **Idle State**: Serial line held high (`1'b1`).
2. **Start Bit**: Driven low (`1'b0`) for one clock cycle.
3. **Data Payload**: Transmitted LSB-first (`DATA_W` bits).
4. **Parity Bit (Optional)**: Automatically inserted when `i_par_en = 1'b1` (supports even or odd modes).
5. **Stop Bit**: Driven high (`1'b1`) for one clock cycle.

```text
       ┌──────┐                                  ┌──────┐
Line:  │ IDLE │ START │ D0 │ D1 │ ... │ D7 │ PAR │ STOP │ IDLE │
───────┘      └───────┴────┴────┴─────┴────┴─────┴──────┴───────

```

---

## 🔍 Module Descriptions

### 1. Transmitter (`uart_tx`)

* **`Serializer.sv`**: Parallel-In Serial-Out (PISO) shift register shifting rightward (LSB-first) on `i_ser_en`.
* **`Parity_Calculator.sv`**: Dynamically calculates and latches parity on valid non-busy requests using `(^i_data) ^ i_par_odd`.
* **`MUX.sv`**: Routes Start bit (`2'b00`), Serial Data (`2'b01`), Parity bit (`2'b10`), or Stop/Idle (`2'b11`) to `o_tx`.
* **`FSM_TX.sv`**: 5-state Moore FSM (`IDLE`, `START`, `DATA`, `PARITY`, `STOP`). Rejects incoming requests while `o_busy = 1`.

### 2. Receiver (`uart_rx`)

* **`Deserializer.sv`**: Serial-In Parallel-Out (SIPO) shift register capturing incoming bits into MSB upon `i_shift_en`.
* **`Parity_Checker.sv`**: Compares the received parity bit against the computed reduction of the deserialized byte.
* **`FSM_RX.sv`**: 5-state FSM (`IDLE`, `DATA`, `PARITY`, `STOP`, `PULSE`). Masks false starts during active transmission and asserts single-cycle pulses on `o_valid`, `o_parity_err`, and `o_frame_err`.

---

## 🛡 Linting & Code Quality

Static lint analysis was conducted using **Siemens Questa Lint** compliant with **STARC** guidelines:

* **Syntax Errors**: 0
* **Inferred Latches**: 0
* **Rule Checks**: Clean design style with parameter duplicate notices analyzed and resolved.

---

## 🧪 Verification & Simulation

Functional verification was executed using self-checking testbenches in **QuestaSim**:

* **Test Scenarios Covered**:
       * Parity disabled transmission & reception.
       * Alternating even and odd parity transactions.
       * Deliberate parity error injection & flag validation.
       * Deliberate framing error injection (corrupted stop bit).
       * Back-to-back continuous frame transfers.


* **Result**: `100% Data Delivery` verified by the automated scoreboard with **`RESULT: PASS`**.

---

## 📊 Synthesis & Resource Utilization

The design was elaborated and synthesized into FPGA primitives:

### Receiver (`uart_rx`)

| Resource | Used | Available | Utilization (%) |
| --- | --- | --- | --- |
| **Slice LUTs** | 14 | 303,600 | < 0.01% |
| **Slice Registers** | 18 | 607,200 | < 0.01% |
| **Bonded IOBs** | 17 | 600 | 2.83% |
| **BUFGCTRL** | 1 | 32 | 3.12% |

### Transmitter (`uart_tx`)

| Resource | Used | Available | Utilization (%) |
| --- | --- | --- | --- |
| **Slice LUTs** | 23 | 303,600 | < 0.01% |
| **Slice Registers** | 16 | 607,200 | < 0.01% |
| **Bonded IOBs** | 15 | 600 | 2.50% |
| **BUFGCTRL** | 1 | 32 | 3.12% |

---

## 💻 How to Run Simulation

You can run the automated verification flows in **QuestaSim / ModelSim** using the provided `.do` scripts:

### Run Full Duplex Loopback Testbench:

```bash
vsim -do Scripts/run_RX_TX.do

```

### Run Transmitter Testbench:

```bash
vsim -do Scripts/run_TX.do

```

---

## 📄 Documentation

For full implementation details, elaboration schematics, and linting logs, refer to the complete report:
👉 **[`UART_Report.pdf`](UART_Report.pdf)**

---

## 👩‍💻 Author

**Arwa Ashraf Kantoush**

*Electronics & Communications Engineering*
