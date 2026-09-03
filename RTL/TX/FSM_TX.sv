module FSM_TX (
    input logic i_clk,
    input logic i_rst_n,
    input logic i_valid,
    input logic i_par_en,
    input logic i_ser_done,
    output logic o_ser_en,
    output logic o_busy,
    output logic [1:0]o_sel
);
typedef enum logic [2:0] { IDLE, START, DATA, PARITY, STOP } state;
state cs,ns;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        cs <= IDLE;
    end
    else begin
        cs <= ns;
    end
end

always_comb begin
    case (cs)
        IDLE : begin
            o_ser_en = 0;
            o_busy = 0;
            o_sel = 2'b11;
            if (i_valid) begin
                ns = START;
            end
            else begin
                ns = IDLE;
            end
        end
        START : begin
            o_ser_en = 0;
            o_busy = 1;
            o_sel = 2'b00;
            ns = DATA;
        end
        DATA : begin
            o_ser_en = 1;
            o_busy = 1;
            o_sel = 2'b01;
            if (i_ser_done) begin
                if (i_par_en) begin
                    ns = PARITY;
                end
                else begin
                    ns = STOP;
                end
            end
            else begin
                ns = DATA;
            end
        end
        PARITY : begin
            o_ser_en = 0;
            o_busy = 1;
            o_sel = 2'b10;
            ns = STOP;
        end
        STOP : begin
            o_ser_en = 0;
            o_busy = 1;
            o_sel = 2'b11;
            ns = IDLE;
        end
        default : begin
            o_ser_en = 0;
            o_busy = 0;
            o_sel = 2'b11;
            ns = IDLE;
        end
    endcase
end
endmodule //FSM
