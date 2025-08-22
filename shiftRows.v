// matrisimizin satırlarını AES algoritmasına uygun şekilde ;
// ilk satır 0 , ikinci satır 1, üçüncü satır 2, dördüncü satır 3 kez sola kaydırılır.
module shiftRows(//ÇALIŞIYOR
    input [127:0] in,
    output [127:0] shiftout
    );
     
    assign shiftout[127:120] = in[127:120]; // b00
    assign shiftout[ 95: 88] = in[ 95: 88]; // b01
    assign shiftout[ 63: 56] = in[ 63: 56]; // b02
    assign shiftout[ 31: 24] = in[ 31: 24]; // b03

    // 2. satır (1 sola kaydırılır)
    assign shiftout[119:112] = in[ 87: 80]; // b11 -> b10
    assign shiftout[ 87: 80] = in[ 55: 48]; // b12 -> b11
    assign shiftout[ 55: 48] = in[ 23: 16]; // b13 -> b12
    assign shiftout[ 23: 16] = in[119:112]; // b10 -> b13

    // 3. satır (2 sola kaydırılır)
    assign shiftout[111:104] = in[ 47: 40]; // b22 -> b20
    assign shiftout[ 79: 72] = in[ 15:  8]; // b23 -> b21
    assign shiftout[ 47: 40] = in[111:104]; // b20 -> b22
    assign shiftout[ 15:  8] = in[ 79: 72]; // b21 -> b23

    // 4. satır (3 sola kaydırılır)
    assign shiftout[103: 96] = in[  7:  0]; // b33 -> b30
    assign shiftout[ 71: 64] = in[103: 96]; // b30 -> b31
    assign shiftout[ 39: 32] = in[ 71: 64]; // b31 -> b32
    assign shiftout[  7:  0] = in[ 39: 32]; // b32 -> b33

    
endmodule
