//key ve girişi XOR işleminden geçirir.
`timescale 1ns / 1ps
module AddRoundKey(
    input [127:0] datain,
    input [127:0] key,
    output [127:0] dataout
);

assign dataout = key ^ datain;

endmodule
