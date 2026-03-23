`timescale 1ns / 1ps

module tb_queue_system;

    // --- 7-Segment Values for Checking ---
    // Copied from your driver for easy verification
    //        gfedcba
    localparam D0 = 7'b1000000; // 0
    localparam D1 = 7'b1111001; // 1
    localparam D2 = 7'b0100100; // 2
    localparam D3 = 7'b0110000; // 3
    localparam D4 = 7'b0011001; // 4
    
    // --- Testbench Signals ---
    reg        clk;
    reg        rst_n;
    reg        btn_get_token;
    reg        btn_next_customer;

    wire [6:0] seg_current_token;
    wire [6:0] seg_next_token;
    
    // Clock period
    localparam CLK_PERIOD = 10; // 10ns = 100MHz clock

    // --- Instantiate the Device Under Test (DUT) ---
    queue_system_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .btn_get_token(btn_get_token),
        .btn_next_customer(btn_next_customer),
        .seg_current_token(seg_current_token),
        .seg_next_token(seg_next_token)
    );

    // --- Clock Generator ---
    always begin
        clk = 1'b0;
        #(CLK_PERIOD / 2);
        clk = 1'b1;
        #(CLK_PERIOD / 2);
    end

    // --- Helper Task for Simulating a Button Press ---
    // (This holds the button for 5 cycles to beat the debouncer)
    task press_button;
        input button_reg; // The 'reg' to control
        begin
            @(posedge clk);
            button_reg = 1'b1;
            repeat (5) @(posedge clk); // Hold for 5 cycles
            button_reg = 1'b0;
            @(posedge clk);
        end
    endtask

    // --- Main Test Stimulus ---
    initial begin
        // For viewing waveforms in a simulator
        $dumpfile("tb_queue_system.vcd");
        $dumpvars(0, tb_queue_system);

        // 1. Initialize and Reset
        $display("Time=%0t: [TEST] Starting Simulation... Resetting system.", $time);
        btn_get_token     = 1'b0;
        btn_next_customer = 1'b0;
        rst_n             = 1'b0; // Assert active-low reset
        
        repeat (3) @(posedge clk);
        rst_n             = 1'b1; // De-assert reset
        
        #(CLK_PERIOD * 2); // Wait for things to stabilize
        
        $display("Time=%0t: [CHECK] Reset complete. Current: %h, Next: %h", $time, seg_current_token, seg_next_token);
        if (seg_current_token == D0 && seg_next_token == D0) $display("... PASS: Displays are at 0.");
        else $display("... FAIL: Displays did not reset to 0.");

        // 2. Customer 1 gets Token #1
        $display("Time=%0t: [ACTION] Customer 1 gets token.", $time);
        press_button(btn_get_token);
        #(CLK_PERIOD * 2); // Wait for FIFO to update
        $display("Time=%0t: [CHECK] Current: %h, Next: %h", $time, seg_current_token, seg_next_token);
        if (seg_current_token == D0 && seg_next_token == D1) $display("... PASS: Current is 0, Next is 1.");
        else $display("... FAIL: Expected Next=1.");

        // 3. Customer 2 gets Token #2
        $display("Time=%0t: [ACTION] Customer 2 gets token.", $time);
        press_button(btn_get_token);
        #(CLK_PERIOD * 2);
        $display("Time=%0t: [CHECK] (Queue loading) Current: %h, Next: %h", $time, seg_current_token, seg_next_token);
        if (seg_current_token == D0 && seg_next_token == D1) $display("... PASS: Current is 0, Next is still 1.");
        else $display("... FAIL: Next display should not have changed.");

        // 4. Teller calls next customer (Customer 1)
        $display("Time=%0t: [ACTION] Teller calls next customer.", $time);
        press_button(btn_next_customer);
        #(CLK_PERIOD * 2);
        $display("Time=%0t: [CHECK] Current: %h, Next: %h", $time, seg_current_token, seg_next_token);
        if (seg_current_token == D1 && seg_next_token == D2) $display("... PASS: Current is 1, Next is 2.");
        else $display("... FAIL: Expected Current=1, Next=2.");
        
        // 5. Customer 3 gets Token #3
        $display("Time=%0t: [ACTION] Customer 3 gets token.", $time);
        press_button(btn_get_token);
        #(CLK_PERIOD * 2);
        $display("Time=%0t: [CHECK] Current: %h, Next: %h", $time, seg_current_token, seg_next_token);
        if (seg_current_token == D1 && seg_next_token == D2) $display("... PASS: Current is 1, Next is still 2.");
        else $display("... FAIL: Next display should not have changed.");
        
        // 6. Teller calls next customer (Customer 2)
        $display("Time=%0t: [ACTION] Teller calls next customer.", $time);
        press_button(btn_next_customer);
        #(CLK_PERIOD * 2);
        $display("Time=%0t: [CHECK] Current: %h, Next: %h", $time, seg_current_token, seg_next_token);
        if (seg_current_token == D2 && seg_next_token == D3) $display("... PASS: Current is 2, Next is 3.");
        else $display("... FAIL: Expected Current=2, Next=3.");
        
        // 7. Teller calls next customer (Customer 3) - Queue will be empty
        $display("Time=%0t: [ACTION] Teller calls next customer.", $time);
        press_button(btn_next_customer);
        #(CLK_PERIOD * 2);
        $display("Time=%0t: [CHECK] (Queue empty) Current: %h, Next: %h", $time, seg_current_token, seg_next_token);
        if (seg_current_token == D3 && seg_next_token == D0) $display("... PASS: Current is 3, Next is 0 (empty).");
        else $display("... FAIL: Expected Current=3, Next=0.");
        
        // 8. Teller presses "Next" on an empty queue
        $display("Time=%0t: [ACTION] Teller presses 'Next' on EMPTY queue.", $time);
        press_button(btn_next_customer);
        #(CLK_PERIOD * 2);
        $display("Time=%0t: [CHECK] Current: %h, Next: %h", $time, seg_current_token, seg_next_token);
        if (seg_current_token == D3 && seg_next_token == D0) $display("... PASS: No change, as expected.");
        else $display("... FAIL: Displays changed when queue was empty.");
        
        // 9. Customer 4 gets Token #4
        $display("Time=%0t: [ACTION] Customer 4 gets token.", $time);
        press_button(btn_get_token);
        #(CLK_PERIOD * 2);
        $display("Time=%0t: [CHECK] Current: %h, Next: %h", $time, seg_current_token, seg_next_token);
        if (seg_current_token == D3 && seg_next_token == D4) $display("... PASS: Current is 3, Next is 4.");
        else $display("... FAIL: Expected Next=4.");

        // End Simulation
        $display("Time=%0t: [TEST] Simulation Finished.", $time);
        $finish;
    end

endmodule