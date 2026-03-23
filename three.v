module seven_seg_driver (
    input  wire [3:0] data_in,     // Binary data (0-15)
    output reg  [6:0] segments_out // 7-segment output (a,b,c,d,e,f,g)
);

    // 7-segment encoding for 0-9, A-F (active-low)
    //        gfedcba
    localparam D0 = 7'b1000000; // 0
    localparam D1 = 7'b1111001; // 1
    localparam D2 = 7'b0100100; // 2
    localparam D3 = 7'b0110000; // 3
    localparam D4 = 7'b0011001; // 4
    localparam D5 = 7'b0010010; // 5
    localparam D6 = 7'b0000010; // 6
    localparam D7 = 7'b1111000; // 7
    localparam D8 = 7'b0000000; // 8
    localparam D9 = 7'b0010000; // 9
    localparam DA = 7'b0001000; // A
    localparam DB = 7'b0000011; // b
    localparam DC = 7'b1000110; // C
    localparam DD = 7'b0100001; // d
    localparam DE = 7'b0000110; // E
    localparam DF = 7'b0001110; // F

    always @(*) begin
        case (data_in)
            4'h0: segments_out = D0;
            4'h1: segments_out = D1;
            4'h2: segments_out = D2;
            4'h3: segments_out = D3;
            4'h4: segments_out = D4;
            4'h5: segments_out = D5;
            4'h6: segments_out = D6;
            4'h7: segments_out = D7;
            4'h8: segments_out = D8;
            4'h9: segments_out = D9;
            4'hA: segments_out = DA;
            4'hB: segments_out = DB;
            4'hC: segments_out = DC;
            4'hD: segments_out = DD;
            4'hE: segments_out = DE;
            4'hF: segments_out = DF;
            default: segments_out = 7'b1111111; // Off
        endcase
    end
endmodule