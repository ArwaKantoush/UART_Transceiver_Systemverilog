module uart_rx #(
    parameter DATA_W = 8
)(
    input logic i_clk,
    input logic i_rst_n,
    input logic i_rx,
    input logic i_par_odd,
    input logic i_par_en,
    output logic [DATA_W-1:0]o_data,
    output logic o_parity_err,
    output logic o_valid,
    output logic o_busy,
    output logic o_frame_err
);
logic shift_en;
logic shift_done;
logic parity_bit;

Deserializer #(.DATA_W(DATA_W)) u_Deserializer (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_rx(i_rx),
    .i_shift_en(shift_en),
    .o_data(o_data),
    .o_shift_done(shift_done)
);

Parity_Checker #(.DATA_W(DATA_W)) u_Parity_Checker (
    .i_data(o_data),
    .i_parity_bit(parity_bit),
    .i_par_odd(i_par_odd),
    .i_par_en(i_par_en),
    .o_parity_err(o_parity_err)
);

FSM_RX u_FSM_RX (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_rx(i_rx),
    .i_par_en(i_par_en),
    .i_shift_done(shift_done),
    .o_valid(o_valid),
    .o_busy(o_busy),
    .o_frame_err(o_frame_err),
    .o_parity_bit(parity_bit),
    .o_shift_en(shift_en)
);
endmodule
