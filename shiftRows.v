// matrisimizin satırlarını AES algoritmasına uygun şekilde ;
// ilk satır 0 , ikinci satır 1, üçüncü satır 2, dördüncü satır 3 kez sola kaydırılır.
module shiftRows(
    input [127:0] in,
    output [127:0] shiftout
    );
     
    //ilk satır r=0 kaydırma yok
    assign shiftout[7:0]     = in[7:0];       // Byte 0
    assign shiftout[39:32]   = in[39:32];     // Byte 4
    assign shiftout[71:64]   = in[71:64];     // Byte 8
    assign shiftout[103:96]  = in[103:96];    // Byte 12
    
    //ikinci satır r=1 1 kere sola kaydırma
    assign shiftout[15:8]    = in[47:40];     // Byte 5
    assign shiftout[47:40]   = in[79:72];     // Byte 9
    assign shiftout[79:72]   = in[111:104];   // Byte 13
    assign shiftout[111:104] = in[15:8];      // Byte 1
    
    //üçüncü satır r=2 2 kere sola kaydırma
    assign shiftout[23:16]   = in[87:80];     // Byte 10
    assign shiftout[55:48]   = in[119:112];   // Byte 14
    assign shiftout[87:80]   = in[23:16];     // Byte 2
    assign shiftout[119:112] = in[55:48];     // Byte 6
    
    //dördüncü satır r=3 3 kere sola kaydırma
    assign shiftout[31:24]   = in[127:120];   // Byte 15
    assign shiftout[63:56]   = in[31:24];     // Byte 3
    assign shiftout[95:88]   = in[63:56];     // Byte 7
    assign shiftout[127:120] = in[95:88];     // Byte 11
    
endmodule
