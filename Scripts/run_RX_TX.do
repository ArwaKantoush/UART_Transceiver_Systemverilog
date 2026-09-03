vlib work
vlog Parity_Calculator.sv Serializer.sv FSM_TX.sv MUX.sv uart_tx.sv Deserializer.sv Parity_Checker.sv FSM_RX.sv uart_rx.sv uart_loopback_tb.sv
vsim -voptargs=+acc work.uart_grading_tb
add wave *
run -all
#quit -sim
