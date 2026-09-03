module Serializer #(
    parameter DATA_W = 8
) (
    input logic i_clk,
    input logic i_rst_n,
    input logic [DATA_W-1:0]i_data,
    input logic i_valid,
    input logic i_ser_en,
    input logic i_busy,
    output logic o_ser_data,
    output logic o_ser_done
);
logic [DATA_W-1:0]register;
logic [$clog2(DATA_W)-1:0]counter;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_ser_done <= 0;
        register <= 0;
        counter <= 0;
    end
    else if (i_valid && !i_ser_en && !i_busy) begin
            register <= i_data;
            o_ser_done <= 0;
            counter <= 0;
        end
    else if (i_ser_en) begin
        if (counter < DATA_W-2) begin
            register <= {1'b0,register[DATA_W-1:1]};
            o_ser_done <= 0;
            counter <= counter + 1;
        end
        else begin
            register <= {1'b0,register[DATA_W-1:1]};
            o_ser_done <= 1;
            counter <= 0;
        end
    end
    else begin
        o_ser_done <= 0;
    end
end

assign o_ser_data = (!i_rst_n)? 0 : register[0];

endmodule //Serializer
