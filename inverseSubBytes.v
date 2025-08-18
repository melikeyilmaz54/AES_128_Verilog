//128 bitlik giriş değerini inversesboxdan geçirir.
module inverseSubBytes(
    input [127:0] in,
    output [127:0] out
    );
    genvar i;
    generate
            for (i = 0; i < 128; i = i + 8) begin : sub_Bytes
            // Positional yerine named bağlantı daha güvenli:
            inverseSbox s (
                .in  (in [i+7 : i]),
                .out (out[i+7 : i])
            );
            end          //[i+7 : i]
    endgenerate
endmodule
