module Parity_Checker #(
    parameter DATA_W = 8
) (
    input logic [DATA_W-1:0]i_data,
    input logic i_parity_bit,
    input logic i_par_odd,
    input logic i_par_en,
    output logic o_parity_err
);
assign o_parity_err = (!i_par_en)? 0 :(i_parity_bit !== (^i_data)^i_par_odd)? 1 : 0;
endmodule
