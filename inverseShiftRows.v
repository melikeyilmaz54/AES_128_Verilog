// matrisimizin satırlarını AES algoritmasına uygun şekilde ;
// ilk satır 0 , ikinci satır 1, üçüncü satır 2, dördüncü satır 3 kez sağa kaydırılır.
module inverseShiftRows(
    input [127:0] in,
    output [127:0] ishiftout
    );
    
    // Row0 (değişmez)
    assign ishiftout[127:120] = in[127:120]; // row0,col0
    assign ishiftout[95:88]   = in[95:88];   // row0,col1
    assign ishiftout[63:56]   = in[63:56];   // row0,col2
    assign ishiftout[31:24]   = in[31:24];   // row0,col3

    // Row1 (sağa 1 kaydırılmış)
    assign ishiftout[119:112] = in[23:16];   // row1,col0 <= eski col3,row1
    assign ishiftout[87:80]   = in[119:112]; // row1,col1 <= eski col0,row1
    assign ishiftout[55:48]   = in[87:80];   // row1,col2 <= eski col1,row1
    assign ishiftout[23:16]   = in[55:48];   // row1,col3 <= eski col2,row1

    // Row2 (sağa 2 kaydırılmış)
    assign ishiftout[111:104] = in[47:40];   // row2,col0 <= eski col2,row2
    assign ishiftout[79:72]   = in[15:8];    // row2,col1 <= eski col3,row2
    assign ishiftout[47:40]   = in[111:104]; // row2,col2 <= eski col0,row2
    assign ishiftout[15:8]    = in[79:72];   // row2,col3 <= eski col1,row2

    // Row3 (sağa 3 kaydırılmış)
    assign ishiftout[103:96]  = in[71:64];   // row3,col0 <= eski col1,row3
    assign ishiftout[71:64]   = in[39:32];   // row3,col1 <= eski col2,row3
    assign ishiftout[39:32]   = in[7:0];     // row3,col2 <= eski col3,row3
    assign ishiftout[7:0]     = in[103:96];  // row3,col3 <= eski col0,row3
endmodule
