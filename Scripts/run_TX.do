vlib work
vlog Parity_Calculator.sv Serializer.sv FSM.sv MUX.sv uart_tx.sv uart_tx_tb.sv
vsim -voptargs=+acc work.uart_tx_tb
add wave *
run -all
#quit -sim
