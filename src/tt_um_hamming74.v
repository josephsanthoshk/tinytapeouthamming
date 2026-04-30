module tt_um_hamming74 (
    input  wire [7:0] ui_in,
    output reg  [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);



wire        mode = ui_in[7];
wire [3:0]  data = ui_in[3:0];
wire [6:0]  recv = ui_in[6:0];


wire _unused = &{uio_in};


wire p1 = data[0] ^ data[1] ^ data[3];   
wire p2 = data[0] ^ data[2] ^ data[3];   
wire p4 = data[1] ^ data[2] ^ data[3];   

wire [6:0] encoded = {
    data[3],  
    data[2],  
    data[1], 
    p4,      
    data[0],  
    p2,      
    p1      
};


wire s1 = recv[0] ^ recv[2] ^ recv[4] ^ recv[6];
wire s2 = recv[1] ^ recv[2] ^ recv[5] ^ recv[6];
wire s4 = recv[3] ^ recv[4] ^ recv[5] ^ recv[6];

wire [2:0] syndrome = {s4, s2, s1};

reg [6:0] corrected;
always @(*) begin
    corrected = recv;
    if (syndrome != 3'd0)
        corrected[syndrome - 1] = ~recv[syndrome - 1];
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uo_out <= 8'd0;
    end
    else if (ena) begin
        if (mode == 1'b0) begin
            uo_out <= {1'b0, encoded};         
        end
        else begin
            uo_out <= {(syndrome != 3'd0), corrected};  
        end
    end
end


assign uio_out = 8'b0;
assign uio_oe  = 8'b0;

endmodule
