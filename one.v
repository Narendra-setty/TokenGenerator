module token_generator (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       btn_get_token, // From the "Get Token" button
    output reg        new_token_valid,
    output reg  [3:0] new_token_value
);

    reg [3:0] token_counter = 4'd0;
    
    // --- Basic Button Debouncer ---
    reg [1:0] sync_btn;
    reg       btn_pressed_pulse;
    reg       btn_prev_state = 1'b0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_btn         <= 2'b0;
            btn_prev_state   <= 1'b0;
            btn_pressed_pulse <= 1'b0;
        end else begin
            // 2-flop synchronizer
            sync_btn <= {sync_btn[0], btn_get_token}; 
            
            // Edge detector (detects rising edge 0 -> 1)
            btn_prev_state   <= sync_btn[1];
            btn_pressed_pulse <= sync_btn[1] & ~btn_prev_state;
        end
    end
    // --- End Debouncer ---

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            new_token_valid <= 1'b0;
            // We'll start token numbers from 1
            token_counter   <= 4'd1; 
        end else begin
            new_token_valid <= 1'b0; // Default to low
            
            if (btn_pressed_pulse) begin
                new_token_valid <= 1'b1;
                new_token_value <= token_counter;
                
                // Increment and wrap counter
                if (token_counter == 4'd15) begin
                    token_counter <= 4'd1;
                end else begin
                    token_counter <= token_counter + 1;
                end
            end
        end
    end

endmodule