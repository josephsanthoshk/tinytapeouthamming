module tt_um_hamming74 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

wire mode = ui_in[7];

wire d1 = ui_in[0];
wire d2 = ui_in[1];
wire d3 = ui_in[2];
wire d4 = ui_in[3];

wire [6:0] recv = ui_in[6:0];


// -------- ENCODER --------

wire p1 = d1 ^ d2 ^ d4;
wire p2 = d1 ^ d3 ^ d4;
wire p4 = d2 ^ d3 ^ d4;

wire [6:0] encoded = {d4,d3,d2,p4,d1,p2,p1};


// -------- DECODER --------

wire s1 = recv[0] ^ recv[2] ^ recv[4] ^ recv[6];
wire s2 = recv[1] ^ recv[2] ^ recv[5] ^ recv[6];
wire s4 = recv[3] ^ recv[4] ^ recv[5] ^ recv[6];

wire [2:0] syndrome = {s4,s2,s1};

reg [6:0] corrected;

always @* begin
    corrected = recv;
    if(syndrome != 0)
        corrected[syndrome-1] = ~corrected[syndrome-1];
end


wire error_flag = |syndrome;


// -------- OUTPUT --------

assign uo_out = mode ? {error_flag,corrected} : {1'b0,encoded};

assign uio_out = 8'b0;
assign uio_oe  = 8'b0;

endmodule
