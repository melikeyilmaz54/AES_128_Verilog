//mixcolumns işlemini şifre çözerken sabit matrisiyle tekrar çarpma işlemi
module inverseMixColumns(
    input [127:0] imcin,
    output [127:0] imcout
    );
    
    //multiply(x,n): x'i 2^n ile çarpar (art arda n defa xtime).
    function [7:0] multiply(input [7:0] x, input integer n);
    integer i;
    begin
            for(i=0;i<n;i=i+1) begin
                if (x[7] == 1) x = ((x << 1) ^ 8'h1b);
                else           x =  (x << 1);
            end
            multiply = x;
    end
    endfunction
    
    function [7:0] gm0e; input [7:0] x; begin
        gm0e = multiply(x,3) ^ multiply(x,2) ^ multiply(x,1); // 8 + 4 + 2 = 0x0e
    end endfunction

    function [7:0] gm0d; input [7:0] x; begin
      gm0d = multiply(x,3) ^ multiply(x,2) ^ x;            // 8 + 4 + 1 = 0x0d
    end endfunction
    
    function [7:0] gm0b; input [7:0] x; begin
      gm0b = multiply(x,3) ^ multiply(x,1) ^ x;            // 8 + 2 + 1 = 0x0b
    end endfunction
    
    function [7:0] gm09; input [7:0] x; begin
      gm09 = multiply(x,3) ^ x;                             // 8 + 1 = 0x09
    end endfunction

        // -------- Col0 (bits 127:96) --------
    assign imcout[127:120] = gm0e(imcin[127:120]) ^ gm0b(imcin[119:112]) ^ gm0d(imcin[111:104]) ^ gm09(imcin[103:96]);
    assign imcout[119:112] = gm09(imcin[127:120]) ^ gm0e(imcin[119:112]) ^ gm0b(imcin[111:104]) ^ gm0d(imcin[103:96]);
    assign imcout[111:104] = gm0d(imcin[127:120]) ^ gm09(imcin[119:112]) ^ gm0e(imcin[111:104]) ^ gm0b(imcin[103:96]);
    assign imcout[103:96]  = gm0b(imcin[127:120]) ^ gm0d(imcin[119:112]) ^ gm09(imcin[111:104]) ^ gm0e(imcin[103:96]);
    
    // -------- Col1 (bits 95:64) --------
    assign imcout[95:88]   = gm0e(imcin[95:88])   ^ gm0b(imcin[87:80])   ^ gm0d(imcin[79:72])   ^ gm09(imcin[71:64]);
    assign imcout[87:80]   = gm09(imcin[95:88])   ^ gm0e(imcin[87:80])   ^ gm0b(imcin[79:72])   ^ gm0d(imcin[71:64]);
    assign imcout[79:72]   = gm0d(imcin[95:88])   ^ gm09(imcin[87:80])   ^ gm0e(imcin[79:72])   ^ gm0b(imcin[71:64]);
    assign imcout[71:64]   = gm0b(imcin[95:88])   ^ gm0d(imcin[87:80])   ^ gm09(imcin[79:72])   ^ gm0e(imcin[71:64]);
    
    // -------- Col2 (bits 63:32) --------
    assign imcout[63:56]   = gm0e(imcin[63:56])   ^ gm0b(imcin[55:48])   ^ gm0d(imcin[47:40])   ^ gm09(imcin[39:32]);
    assign imcout[55:48]   = gm09(imcin[63:56])   ^ gm0e(imcin[55:48])   ^ gm0b(imcin[47:40])   ^ gm0d(imcin[39:32]);
    assign imcout[47:40]   = gm0d(imcin[63:56])   ^ gm09(imcin[55:48])   ^ gm0e(imcin[47:40])   ^ gm0b(imcin[39:32]);
    assign imcout[39:32]   = gm0b(imcin[63:56])   ^ gm0d(imcin[55:48])   ^ gm09(imcin[47:40])   ^ gm0e(imcin[39:32]);
    
    // -------- Col3 (bits 31:0) --------
    assign imcout[31:24]   = gm0e(imcin[31:24])   ^ gm0b(imcin[23:16])   ^ gm0d(imcin[15:8])    ^ gm09(imcin[7:0]);
    assign imcout[23:16]   = gm09(imcin[31:24])   ^ gm0e(imcin[23:16])   ^ gm0b(imcin[15:8])    ^ gm0d(imcin[7:0]);
    assign imcout[15:8]    = gm0d(imcin[31:24])   ^ gm09(imcin[23:16])   ^ gm0e(imcin[15:8])    ^ gm0b(imcin[7:0]);
    assign imcout[7:0]     = gm0b(imcin[31:24])   ^ gm0d(imcin[23:16])   ^ gm09(imcin[15:8])    ^ gm0e(imcin[7:0]);

endmodule
   
