module Deserializer #(
    parameter DATA_W = 8
) (
    input logic i_clk,
    input logic i_rst_n,
    input logic i_rx,
    input logic i_shift_en,
    output logic [DATA_W-1:0]o_data,
    output logic o_shift_done
);
logic [$clog2(DATA_W)-1:0]counter;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_data <= 0;
        o_shift_done <= 0;
    end
    else if (i_shift_en) begin
        if (counter < DATA_W-2) begin
            o_data <= {i_rx,o_data[DATA_W-1:1]};
            o_shift_done <= 0;
            counter <= counter + 1;
        end
        else begin
            o_data <= {i_rx,o_data[DATA_W-1:1]};
            o_shift_done <= 1;
            counter <= 0;
        end
    end
    else begin
        counter <= 0;
    end
end

endmodule
