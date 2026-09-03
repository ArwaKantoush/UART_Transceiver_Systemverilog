module Parity_Calculator #(
    parameter DATA_W = 8
) (
    input logic i_clk,
    input logic i_rst_n,
    input logic [DATA_W-1:0]i_data,
    input logic i_valid,
    input logic i_par_en,
    input logic i_par_odd,
    input logic i_busy,
    output logic o_parity_bit
);

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_parity_bit <= 0;
    end
    else begin
        if (i_valid && i_par_en && !i_busy) begin
            o_parity_bit <= (^i_data)^i_par_odd;
        end
    end
end

endmodule //Parity_Calculator
