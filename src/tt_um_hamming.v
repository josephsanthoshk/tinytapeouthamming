module tt_um_hamming (
    input  wire [7:0] ui_in,
    output reg  [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

reg [11:0] codeword;
reg error_detected;

// control
wire encode = uio_in[0];
wire decode = uio_in[1];

// data bits
wire d1 = ui_in[0];
wire d2 = ui_in[1];
wire d3 = ui_in[2];
wire d4 = ui_in[3];
wire d5 = ui_in[4];
wire d6 = ui_in[5];
wire d7 = ui_in[6];
wire d8 = ui_in[7];

// parity bits
wire p1 = d1 ^ d2 ^ d4 ^ d5 ^ d7;
wire p2 = d1 ^ d3 ^ d4 ^ d6 ^ d7;
wire p4 = d2 ^ d3 ^ d4 ^ d8;
wire p8 = d5 ^ d6 ^ d7 ^ d8;

// encoded 12-bit word
wire [11:0] encoded = {
    d8,d7,d6,d5,
    p8,
    d4,d3,d2,
    p4,
    d1,
    p2,
    p1
};


// syndrome calculation
wire s1 = codeword[0] ^ codeword[2] ^ codeword[4] ^ codeword[6] ^ codeword[8] ^ codeword[10];
wire s2 = codeword[1] ^ codeword[2] ^ codeword[5] ^ codeword[6] ^ codeword[9] ^ codeword[10];
wire s4 = codeword[3] ^ codeword[4] ^ codeword[5] ^ codeword[6] ^ codeword[11];
wire s8 = codeword[7] ^ codeword[8] ^ codeword[9] ^ codeword[10] ^ codeword[11];

wire [3:0] syndrome = {s8,s4,s2,s1};


reg [11:0] corrected;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        codeword <= 12'b0;
        corrected <= 12'b0;
        uo_out <= 8'b0;
        error_detected <= 0;
    end

    else if(ena) begin

        // encode mode
        if(encode) begin
            codeword <= encoded;
            uo_out <= ui_in;
            error_detected <= 0;
        end

        // decode mode
        if(decode) begin

            corrected = codeword;

            if(syndrome != 0) begin
                corrected[syndrome-1] = ~corrected[syndrome-1];
                error_detected <= 1;
            end
            else begin
                error_detected <= 0;
            end

            uo_out <= {
                corrected[11],
                corrected[10],
                corrected[9],
                corrected[8],
                corrected[6],
                corrected[5],
                corrected[4],
                corrected[2]
            };

            codeword <= corrected;
        end

    end
end


// error flag output
assign uio_out[7] = error_detected;

// unused outputs
assign uio_out[6:0] = 7'b0;

// enable only error flag pin
assign uio_oe = 8'b10000000;

endmodule
