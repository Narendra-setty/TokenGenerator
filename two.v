module fifo_queue #(
    parameter DATA_WIDTH = 4,
    parameter DEPTH      = 8,
    parameter PTR_WIDTH  = 3 
)(
    input  wire clk,
    input  wire rst_n,
    
    input  wire  wr_en,
    input  wire [DATA_WIDTH-1:0] din,
    
    input  wire                 rd_en,
    output wire [DATA_WIDTH-1:0] dout,
    
    output wire                 full,
    output wire                 empty
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [PTR_WIDTH:0]    wr_ptr = 0;
    reg [PTR_WIDTH:0]    rd_ptr = 0;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr[PTR_WIDTH-1:0]] <= din;
                wr_ptr <= wr_ptr + 1;
            end
            
            if (rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1;
            end
        end
    end
    
    assign dout = mem[rd_ptr[PTR_WIDTH-1:0]];
    
    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0]) && 
                   (wr_ptr[PTR_WIDTH] != rd_ptr[PTR_WIDTH]);

endmodule