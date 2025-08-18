// matrisimizin satırlarını AES algoritmasına uygun şekilde ;
// ilk satır 0 , ikinci satır 1, üçüncü satır 2, dördüncü satır 3 kez sağa kaydırılır.
module inverseShiftRows(
    input [127:0] in,
    output [127:0] ishiftout
    );
    
    //ilk satır r=0 kaydırma yok
    assign ishiftout[7:0]     =  in[7:0];       // Byte 0
    assign ishiftout[39:32]   =  in[39:32];     // Byte 4
    assign ishiftout[71:64]   =  in[71:64];     // Byte 8
    assign ishiftout[103:96]  =  in[103:96];    // Byte 12

    //ikinci satır r=1 1 kez sağa kaydırma
    assign ishiftout[47:40]   =  in[15:8];     // Byte 1
    assign ishiftout[79:72]   =  in[47:40];    // Byte 5
    assign ishiftout[111:104] =  in[79:72];    // Byte 9
    assign ishiftout[15:8]    =  in[111:104];  // Byte 13
    
    //üçüncü satır r=2 2 kez sağa kaydırma
    assign ishiftout[55:48]   =  in[23:16];     // Byte 2
    assign ishiftout[87:80]   =  in[55:48];     // Byte 6
    assign ishiftout[119:112] =  in[87:80];     // Byte 10
    assign ishiftout[23:16]   =  in[119:112];   // Byte 14
    
    //dördüncü satır r=3 3 kez sağa kaydırma
    assign ishiftout[63:56]   =  in[31:24];    // Byte 3
    assign ishiftout[95:88]   =  in[63:56];    // Byte 7
    assign ishiftout[127:120] =  in[95:88];    // Byte 11
    assign ishiftout[31:24]   =  in[127:120];  // Byte 15
    
endmodule
