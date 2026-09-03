module FSM_RX(
    input logic i_clk,
    input logic i_rst_n,
    input logic i_rx,
    input logic i_par_en,
    input logic i_shift_done,
    output logic o_valid,
    output logic o_busy,
    output logic o_frame_err,
    output logic o_parity_bit,
    output logic o_shift_en
);
typedef enum logic [2:0] { IDLE, DATA, PARITY, STOP, PULSE } state;
state cs,ns;
logic err;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        cs <= IDLE;
        o_frame_err <= 0;
    end
    else begin
        cs <= ns;
        o_frame_err <= err;
    end
end

always_comb begin
    case (cs)
        IDLE : begin
            o_valid = 0;
            o_shift_en = 0;
            o_parity_bit = 0;
            err = 0;
            if (!i_rx) begin
                o_busy = 1;
                ns = DATA;
            end
            else begin
                o_busy = 0;
                ns = IDLE;
            end
        end
        DATA : begin
            o_busy = 1;
            o_valid = 0;
            o_shift_en = 1;
            if (i_shift_done) begin
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
            o_parity_bit = i_rx;
            o_busy = 1;
            o_valid = 0;
            o_shift_en = 0;
            ns = STOP;
        end
        STOP : begin
            o_busy = 1;
            o_valid = 0;
            o_shift_en = 0;
            if (i_rx) begin
                err = 0;
            end
            else begin
                err = 1;
            end
            ns = PULSE;
        end
        PULSE : begin
            o_busy = 0;
            o_valid = 1;
            o_shift_en = 0;
            ns = IDLE;
        end
        default : begin
            o_busy = 0;
            o_valid = 0;
            o_shift_en = 0;
            o_parity_bit = 0;
            err = 0;
            ns = IDLE;
        end
    endcase
end
endmodule
