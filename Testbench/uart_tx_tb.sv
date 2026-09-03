module uart_tx_tb ();
parameter DATA_W = 8;
logic i_clk;
logic i_rst_n;
logic [DATA_W-1:0]i_data;
logic i_valid;
logic i_par_en;
logic i_par_odd;
logic o_tx;
logic o_tx_exp;
logic o_busy;
logic o_busy_exp;

uart_tx #(.DATA_W(DATA_W)
    ) dut ( .i_clk(i_clk),
            .i_rst_n(i_rst_n),
            .i_data(i_data),
            .i_valid(i_valid),
            .i_par_en(i_par_en),
            .i_par_odd(i_par_odd),
            .o_tx(o_tx),
            .o_busy(o_busy)
);

initial begin
    i_clk = 1;
    forever begin
        #1 i_clk = ~i_clk;
    end
end

integer i;
initial begin
    i_rst_n = 0;
    i_data = 8'b0000_0000; i_valid = 0; i_par_en = 0; i_par_odd = 0;
    o_tx_exp = 1; o_busy_exp = 0;
    @(negedge i_clk);
    if (o_tx !== o_tx_exp || o_busy !== o_busy_exp) begin
        $display("ERROR!");
        //$stop;
    end

    i_rst_n = 1;
    i_data = 8'b1010_0101; i_valid = 1; i_par_en = 0; i_par_odd = 0;
    for (i = 0 ; i < 10 ; i = i + 1) begin
        if (i==0) begin
            o_tx_exp = 0; o_busy_exp = 1;
        end
        else if (i<9) begin
            o_tx_exp = i_data[i-1]; o_busy_exp = 1;
        end
        else begin
            o_tx_exp = 1; o_busy_exp = 1;
        end
        @(negedge i_clk);
        i_valid = 0;
        if (o_tx !== o_tx_exp || o_busy !== o_busy_exp) begin
            $display("ERROR!");
            //$stop;
        end
    end

    o_tx_exp = 1; o_busy_exp = 0;
    @(negedge i_clk);
    if (o_tx !== o_tx_exp || o_busy !== o_busy_exp) begin
        $display("ERROR!");
        //$stop;
    end

    i_data = 8'b1010_0101; i_valid = 1; i_par_en = 1; i_par_odd = 0;
    for (i = 0 ; i < 11 ; i = i + 1) begin
        if (i==0) begin
            o_tx_exp = 0; o_busy_exp = 1;
        end
        else if (i<9) begin
            o_tx_exp = i_data[i-1]; o_busy_exp = 1;
        end
        else if (i<10) begin
            o_tx_exp = ^i_data; o_busy_exp = 1;
        end
        else begin
            o_tx_exp = 1; o_busy_exp = 1;
        end
        @(negedge i_clk);
        i_valid = 0;
        if (o_tx !== o_tx_exp || o_busy !== o_busy_exp) begin
            $display("ERROR!");
            //$stop;
        end
    end

    o_tx_exp = 1; o_busy_exp = 0;
    @(negedge i_clk);
    if (o_tx !== o_tx_exp || o_busy !== o_busy_exp) begin
        $display("ERROR!");
        //$stop;
    end

    i_data = 8'b1010_0101; i_valid = 1; i_par_en = 1; i_par_odd = 1;
    for (i = 0 ; i < 11 ; i = i + 1) begin
        if (i==0) begin
            o_tx_exp = 0; o_busy_exp = 1;
        end
        else if (i<9) begin
            o_tx_exp = i_data[i-1]; o_busy_exp = 1;
        end
        else if (i<10) begin
            o_tx_exp = ~^i_data; o_busy_exp = 1;
        end
        else begin
            o_tx_exp = 1; o_busy_exp = 1;
        end
        @(negedge i_clk);
        i_valid = 0;
        if (o_tx !== o_tx_exp || o_busy !== o_busy_exp) begin
            $display("ERROR!");
            //$stop;
        end
    end

    o_tx_exp = 1; o_busy_exp = 0;
    @(negedge i_clk);
    if (o_tx !== o_tx_exp || o_busy !== o_busy_exp) begin
        $display("ERROR!");
        //$stop;
    end
    $stop;
end

initial begin
    $monitor("i_clk=%b,i_rst_n=%b,i_data=%b,i_valid=%b,i_par_en=%b,i_par_odd=%b,o_tx=%b,o_tx_exp=%b,o_busy=%b,o_busy_exp=%b",
                i_clk,i_rst_n,i_data,i_valid,i_par_en,i_par_odd,o_tx,o_tx_exp,o_busy,o_busy_exp);
end

endmodule //UART_TX_tb
