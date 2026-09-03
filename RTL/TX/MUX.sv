module MUX #(
    parameter START_BIT = 0,
    parameter STOP_BIT = 1
) (
    input logic i_ser_data,
    input logic i_parity_bit,
    input logic [1:0]i_sel,
    output logic o_tx
);

always_comb begin
    case (i_sel)
        2'b00 : begin
            o_tx = START_BIT;
        end
        2'b01 : begin
            o_tx = i_ser_data;
        end
        2'b10 : begin
            o_tx = i_parity_bit;
        end
        2'b11 : begin
            o_tx = STOP_BIT;
        end
        default : begin
            o_tx = STOP_BIT;
        end
    endcase
end

endmodule //MUX
