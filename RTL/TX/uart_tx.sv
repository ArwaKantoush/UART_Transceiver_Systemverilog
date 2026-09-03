module uart_tx #(
    parameter DATA_W = 8
) (
    input logic i_clk,
    input logic i_rst_n,
    input logic [DATA_W-1:0]i_data,
    input logic i_valid,
    input logic i_par_en,
    input logic i_par_odd,
    output logic o_tx,
    output logic o_busy
);
logic PARITY_BIT;
logic SER_EN;
logic SER_DATA;
logic SER_DONE;
logic [1:0]SEL;

Parity_Calculator #(.DATA_W(DATA_W)) u_Parity_Calculator (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_data(i_data),
    .i_valid(i_valid),
    .i_par_en(i_par_en),
    .i_par_odd(i_par_odd),
    .i_busy(o_busy),
    .o_parity_bit(PARITY_BIT)
);

Serializer #(.DATA_W(DATA_W)) u_Serializer (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_data(i_data),
    .i_valid(i_valid),
    .i_ser_en(SER_EN),
    .i_busy(o_busy),
    .o_ser_data(SER_DATA),
    .o_ser_done(SER_DONE)
);

MUX u_MUX (
    .i_ser_data(SER_DATA),
    .i_parity_bit(PARITY_BIT),
    .i_sel(SEL),
    .o_tx(o_tx)
);

FSM_TX u_FSM_TX (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_valid(i_valid),
    .i_par_en(i_par_en),
    .i_ser_done(SER_DONE),
    .o_ser_en(SER_EN),
    .o_busy(o_busy),
    .o_sel(SEL)
);

endmodule //uart_tx
