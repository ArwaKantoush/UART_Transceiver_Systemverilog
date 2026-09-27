# Parameterized Cycle-Accurate UART Core (SystemVerilog)

[![SystemVerilog](https://img.shields.io/badge/Language-SystemVerilog-blue.svg)](https://en.wikipedia.org/wiki/SystemVerilog)
[![Lint](https://img.shields.io/badge/Questa_Lint-STARC_Clean-brightgreen.svg)]()
[![Verification](https://img.shields.io/badge/Simulation-Self--Checking_TB-brightgreen.svg)]()
[![Synthesis](https://img.shields.io/badge/FPGA-Synthesizable-orange.svg)]()

A modular, fully parameterized, and cycle-accurate **UART (Universal Asynchronous Receiver/Transmitter) IP Core** implemented in synthesizable SystemVerilog. The project includes independent Transmitter (`uart_tx`) and Receiver (`uart_rx`) modules, deterministic FSM controllers, dynamic parity calculation/checking, error injection verification, and compliance with **STARC** coding rules via static lint analysis.
📑 Table of ContentsArchitecture & Key FeaturesRepository StructureProtocol & Frame SequenceModule DescriptionsLinting & Code QualityVerification & SimulationSynthesis & Resource UtilizationHow to Run SimulationDocumentation🚀 Architecture & Key FeaturesCycle-Accurate Timing: Each bit period spans exactly one system clock cycle (fully synchronous core design).Parameterized Datapath: Configurable payload width via DATA_W (default is 8 bits).Dynamic Parity Support: Runtime-configurable parity enable (i_par_en) and odd/even mode selection (i_par_odd).Comprehensive Error Detection:Parity error detection (o_parity_err).Framing error detection (o_frame_err) checking for valid stop bit assertions.Robust FSM Control: Moore state machines isolating the datapath registers, rejecting overlapping writes during transmission (o_busy), and delivering data via a clean single-cycle pulse ("flag-and-deliver").Production-Grade Code Quality: Verified with Siemens Questa Lint against STARC guidelines with zero syntax errors and zero inferred latches.📁 Repository StructurePlaintext├── RTL/
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
⏱ Protocol & Frame SequenceThe UART frame consists of:Idle State: Serial line held high (1'b1).Start Bit: Driven low (1'b0) for one clock cycle.Data Payload: Transmitted LSB-first (DATA_W bits).Parity Bit (Optional): Automatically inserted when i_par_en = 1'b1 (supports even or odd modes).Stop Bit: Driven high (1'b1) for one clock cycle.Plaintext       ┌──────┐                                 ┌──────┐
Line:  │ IDLE │ START │ D0 │ D1 │ ... │ D7 │ PAR │ STOP │ IDLE │
───────┘      └───────┴────┴────┴─────┴────┴─────┴──────┴───────
🔍 Module Descriptions1. Transmitter (uart_tx)Serializer.sv: Parallel-In Serial-Out (PISO) shift register shifting rightward (LSB-first) on i_ser_en.Parity_Calculator.sv: Dynamically calculates and latches parity on valid non-busy requests using (^i_data) ^ i_par_odd.MUX.sv: Routes Start bit (2'b00), Serial Data (2'b01), Parity bit (2'b10), or Stop/Idle (2'b11) to o_tx.FSM_TX.sv: 5-state Moore FSM (IDLE, START, DATA, PARITY, STOP). Rejects incoming requests while o_busy = 1.2. Receiver (uart_rx)Deserializer.sv: Serial-In Parallel-Out (SIPO) shift register capturing incoming bits into MSB upon i_shift_en.Parity_Checker.sv: Compares the received parity bit against the computed reduction of the deserialized byte.FSM_RX.sv: 5-state FSM (IDLE, DATA, PARITY, STOP, PULSE). Masks false starts during active transmission and asserts single-cycle pulses on o_valid, o_parity_err, and o_frame_err.🛡 Linting & Code QualityStatic lint analysis was conducted using Siemens Questa Lint compliant with STARC guidelines:Syntax Errors: 0Inferred Latches: 0Notices: Parameter naming reuse warnings across modular hierarchies (DATA_W) were fully analyzed and resolved.🧪 Verification & SimulationFunctional verification was executed using self-checking testbenches in QuestaSim:Test Scenarios Covered:Parity disabled transmission & reception.Alternating even and odd parity transactions.Deliberate parity error injection & flag validation.Deliberate framing error injection (corrupted stop bit).Back-to-back continuous frame transfers.Result: 100% Data Delivery verified by the automated scoreboard with RESULT: PASS.📊 Synthesis & Resource UtilizationThe design was elaborated and synthesized into FPGA primitives:Receiver (uart_rx)ResourceUsedAvailableUtilization (%)Slice LUTs14303,600< 0.01%Slice Registers18607,200< 0.01%Bonded IOBs176002.83%BUFGCTRL1323.12%Transmitter (uart_tx)ResourceUsedAvailableUtilization (%)Slice LUTs23303,600< 0.01%Slice Registers16607,200< 0.01%Bonded IOBs156002.50%BUFGCTRL1323.12%💻 How to Run SimulationYou can run the automated verification flows in QuestaSim / ModelSim using the provided .do scripts:Run Full Duplex Loopback Testbench:Bashvsim -do Scripts/run_RX_TX.do
Run Transmitter Testbench:Bashvsim -do Scripts/run_TX.do
📄 DocumentationFor full implementation details, elaboration schematics, and linting logs, refer to the complete report:👉 UART_Report.pdf👩‍💻 AuthorArwa Ashraf KantoushElectronics & Communications Engineering
