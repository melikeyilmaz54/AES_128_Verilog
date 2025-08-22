//128 bitlik giriş değerini sboxdan geçirir.
module subBytes(//4 parça
    input [127:0] in,
    output [127:0] out
    );
    genvar i;
    generate
    for(i=0; i<128; i=i+8)begin:sub_Bytes //adlandırma
        sbox s (
                .sbin  (in [i+7 : i]),
                .sbout (out[i+7 : i])
            );
        end    
    endgenerate
endmodule
