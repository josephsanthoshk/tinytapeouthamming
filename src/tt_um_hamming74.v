module tt_um_hamming74 (
    input  wire [7:0] ui_in,
    output reg  [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

wire mode = ui_in[7];      // 0 = encode, 1 = decode

wire [3:0] data = ui_in[3:0];
wire [6:0] recv = ui_in[6:0];

reg [6:0] code;
reg error_flag;


// ---------- ENCODER ----------
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


// ---------- DECODER ----------
wire s1 = recv[0] ^ recv[2] ^ recv[4] ^ recv[6];
wire s2 = recv[1] ^ recv[2] ^ recv[5] ^ recv[6];
wire s4 = recv[3] ^ recv[4] ^ recv[5] ^ recv[6];

wire [2:0] syndrome = {s4,s2,s1};

reg [6:0] corrected;


always @(posedge clk or negedge rst_n) begin

    if(!rst_n) begin
        code <= 0;
        error_flag <= 0;
        uo_out <= 0;
    end

    else if(ena) begin

        if(mode == 0) begin
            // encode
            code <= encoded;
            uo_out[6:0] <= encoded;
            uo_out[7] <= 0;
            error_flag <= 0;
        end

        else begin
            // decode
            corrected = recv;

            if(syndrome != 0) begin
                corrected[syndrome-1] = ~corrected[syndrome-1];
                error_flag <= 1;
            end
            else
                error_flag <= 0;

            uo_out[6:0] <= corrected;
            uo_out[7] <= error_flag;
        end

    end
end


assign uio_out = 8'b0;
assign uio_oe  = 8'b0;

endmodule
