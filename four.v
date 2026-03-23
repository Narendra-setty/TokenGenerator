module queue_system_top (
    input  wire       clk,
    input  wire       rst_n,
    
    // Physical buttons
    input  wire       btn_get_token,    // Customer button
    input  wire       btn_next_customer, // Teller button
    
    // Physical displays
    output wire [6:0] seg_current_token, // 7-seg for "Now Serving"
    output wire [6:0] seg_next_token     // 7-seg for "Next"
);

    // --- Wires to connect modules ---
    wire        new_token_valid;
    wire [3:0]  new_token_value;
    
    wire        fifo_wr_en;
    wire        fifo_rd_en;
    wire [3:0]  fifo_dout;
    wire        fifo_full;
    wire        fifo_empty;

    // --- Registers for display ---
    reg  [3:0]  current_token_reg = 4'd0;
    
    // --- Button Debouncer for Teller ---
    // (This is a simplified version for the teller button)
    reg [1:0] sync_btn_next;
    reg       btn_next_pulse;
    reg       btn_next_prev = 1'b0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_btn_next  <= 2'b0;
            btn_next_prev  <= 1'b0;
            btn_next_pulse <= 1'b0;
        end else begin
            sync_btn_next <= {sync_btn_next[0], btn_next_customer};
            btn_next_prev <= sync_btn_next[1];
            btn_next_pulse <= sync_btn_next[1] & ~btn_next_prev;
        end
    end

    // --- Control Logic ---
    
    // Write to FIFO only if the generator has a new token AND FIFO is not full
    assign fifo_wr_en = new_token_valid && !fifo_full;
    
    // Read from FIFO only if teller presses button AND FIFO is not empty
    assign fifo_rd_en = btn_next_pulse && !fifo_empty;
    
    // Update the "Current Token" display register ONLY when we read
    // from the FIFO.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_token_reg <= 4'd0;
        end else if (fifo_rd_en) begin
            current_token_reg <= fifo_dout; // Latch the token from FIFO
        end
    end

    // --- Module Instantiations ---
    
    // 1. Token Generator
    token_generator u_gen (
        .clk(clk),
        .rst_n(rst_n),
        .btn_get_token(btn_get_token),
        .new_token_valid(new_token_valid),
        .new_token_value(new_token_value)
    );
    
    // 2. FIFO Queue
    fifo_queue #(
        .DATA_WIDTH(4),
        .DEPTH(8)
    ) u_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(fifo_wr_en),
        .din(new_token_value),
        .rd_en(fifo_rd_en),
        .dout(fifo_dout),
        .full(fifo_full),
        .empty(fifo_empty)
    );
    
    // 3. Display Drivers
    seven_seg_driver u_disp_current (
        .data_in(current_token_reg),
        .segments_out(seg_current_token)
    );
    
    seven_seg_driver u_disp_next (
        // "Next token" is whatever is at the front of the queue.
        // If queue is empty, show 0.
        .data_in(fifo_empty ? 4'd0 : fifo_dout), 
        .segments_out(seg_next_token)
    );

endmodule